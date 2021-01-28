
waypoints = require("__shared/waypoints")

local M = {}

-- payload_GUID = "67E1E7E3-0E50-11DE-84F5-B01842D7E41E" -- Car

-- payload_GUID = "86109A07-8794-11E0-9345-9992712BCB5C" -- Bag

-- payload_GUID = "044E1D7D-5F11-4F8A-A574-7887E29EF128" -- Luxury Car
-- payload_GUID = "67E1E7E3-0E50-11DE-84F5-B01842D7E41E" -- Civilian Car 01
--payload_GUID = "044E1D7D-5F11-4F8A-A574-7887E29EF128" -- Car on fire next to tree
-- payload_GUID = "C412F8F3-3E85-11E0-BCB1-8B4B61244BA9" -- Vending Machine
-- payload_GUID = "86109A07-8794-11E0-9345-9992712BCB5C" -- Bag
-- payload_GUID = "86109A07-8794-11E0-9345-9992712BCB5C" -- Bag
payload_basespeed = 1.2 -- Measured in dist per second
payload_speed_bonus = 0.12 -- Measured in dist per second
payload_max_pushers = 5 -- Maximum people pushing the cart before payload speed is capped
payload_push_radius = 5 -- Area around the payload that counts as pushing it.

payload_total_dist_moved = 0
payload_entity = nil
payload_transform = nil

waypoint_index = 1
capturepoint_index = 0
payload_waypoints = nil
payload_capturepoints = nil
payload_spawnpoints = nil
payload_total_dist = nil

-- {"A", "B", "C", "D", "E", "F", "G"}
-- 1: Owned by US, 2: Owned by RU
cp_current_capture_state = {2, 2, 2, 2, 2, 2, 2}

-- This has to be hardcoded: TicketManager:GetTicketCount() isn't working!
initial_tickets = 350
ru_tickets = initial_tickets
us_time = nil
us_max_time = nil

function calculate_total_dist()
    local prev = payload_waypoints[1]
    payload_total_dist = 0
    for i = 2, #payload_waypoints do
        payload_total_dist = payload_total_dist + prev:Distance(payload_waypoints[i])
        prev = payload_waypoints[i]
    end
end

function M.create_payload(client_or_server, updated_transform)
    -- Initialise all variables
    ru_tickets = initial_tickets
    us_time = nil
    waypoint_index = 1
    capturepoint_index = 0

    -- Get the waypoints for the current map
    payload_waypoints = waypoints.get_waypoints()
    payload_capturepoints = waypoints.get_cps()

    if payload_waypoints ~= nil then
        calculate_total_dist()
        -- Creating entity
        -- local payloadData = ResourceManager:SearchForInstanceByGuid(Guid(payload_GUID))

        local dataContainer = ResourceManager:SearchForDataContainer("Props/Vehicles/LuxuryCar_01/LuxuryCar_01_MP")
        print(dataContainer)
        local payload_blueprint = ObjectBlueprint(dataContainer)

        if payload_blueprint ~= nil then
            payload_transform = LinearTransform()
            
            -- If transform has been passed in to function use that instead.
            if updated_transform ~= nil then
                payload_transform = updated_transform
            else 
                -- Set default position of payload to starting position
                payload_transform.trans = payload_waypoints[1] -- Start position
            end
            
            -- Create payload entity at position of payload transfrom
            -- payload_entity = EntityManager:CreateEntity(payloadData, payload_transform)
            payload_entity = EntityManager:CreateEntitiesFromBlueprint(payload_blueprint, payload_transform)
            
            -- Make on Client or Server depending on who called this function
            if payload_entity ~= nil then
                if client_or_server == 'Client' then
                    for i, entity in pairs(payload_entity.entities) do
                        entity:Init(Realm.Realm_Client, true)
                    end
                    -- payload_entity:Init(Realm.Realm_Client, true)
                else
                    for i, entity in pairs(payload_entity.entities) do
                        entity:Init(Realm.Realm_Server, true)
                    end
                end
            end
        else
            print("The enitiy you are looking for does not exist")
            print("Yoda: Lost an enitiy Master Obi-Wan has. How embarrassing.")
        end

        -- Payload mod is active, return true
        return true
    end

    -- Payload mod doesn't work for this map, return False
    return false
end

-- Move towards Vec3
function move_towards_lin(from, to, max)
    if to:Distance(from) < max then
        return to
    end
    local dir = (to - from):Normalize()
    local new_vec = from + (dir * max)
    return new_vec
end

function M.update_payload_server(num_players_near, simulationDeltaTime)
    local prev_wp = payload_waypoints[waypoint_index]
    local next_wp = payload_waypoints[waypoint_index + 1]
    local dist_per_sec = payload_basespeed -- Base payload distance to move each tick.

    -- Payload speed changes based on num players near cart.
    if num_players_near > payload_max_pushers then
        num_players_near = payload_max_pushers
    end

    if num_players_near > 0 and us_time == nil then
        us_time = waypoints.get_initial_time()
        us_max_time = us_time
    end

    dist_per_sec = payload_basespeed + (num_players_near * payload_speed_bonus)

    local previous_payload_trans = payload_transform.trans:Clone()

    -- Get new trans for the payload
    payload_transform.trans = move_towards_lin(payload_transform.trans, next_wp, (dist_per_sec * simulationDeltaTime)) -- payload_transform.trans:MoveTowards(next_wp, delta)

    -- Update total distance moved
    payload_total_dist_moved = payload_total_dist_moved + (payload_transform.trans:Distance(previous_payload_trans))

    -- Check if we have reached the next waypoint and update waypoint index
    if payload_transform.trans == next_wp then
        -- Check if we are not at the last waypoint
        local last_waypoint = false
        if waypoint_index ~= #payload_waypoints - 1 then
            waypoint_index = waypoint_index + 1
        else
            last_waypoint = true
        end

        if payload_capturepoints == nil then
            payload_capturepoints = waypoints.get_cps()
        end

        -- Update tickets and time
        local old_cp_index = capturepoint_index
        local total_cps = #payload_capturepoints
        for i, cp in ipairs(payload_capturepoints) do
            if cp[1] <= waypoint_index then
                capturepoint_index = i
            end
        end

        if last_waypoint then
            capturepoint_index = #payload_capturepoints
        end

        if old_cp_index ~= capturepoint_index then
            -- Capture point has been taken

            -- Update US time
            us_time = us_time + payload_capturepoints[capturepoint_index][4]
            us_max_time = us_time
            -- Capture the flag!
            local cp_indexes = {"A", "B", "C", "D", "E", "F", "G"}
            local iterator = EntityManager:GetIterator('ServerCapturePointEntity')
            local entity = iterator:Next()
            while entity ~= nil do
                entity = CapturePointEntity(entity)

                local name = tostring(entity.name)

                local cp_letter = string.sub(name, string.len(name))

                if cp_letter == cp_indexes[capturepoint_index] then
                    local entity_data = CapturePointEntityData(entity.data)
                    entity_data:MakeWritable()
                    entity.team = TeamId.Team1

                    -- Let the client which point has just been captured
                    NetEvents:Broadcast('update_captured_cps', capturepoint_index)
                    break
                end

                entity = iterator:Next()
            end

        end

        ru_tickets = math.ceil(initial_tickets * (1 - (capturepoint_index / total_cps)))
    end
end

function M.update_tickets(deltaTime)
    -- Call this function every engine update
    local us_tickets = initial_tickets

    if PlayerManager:GetPlayerCount() > 0 then
        if us_time ~= nil and us_max_time ~= nil and us_tickets > 0 and ru_tickets > 0 then
            us_time = us_time - deltaTime
            us_tickets = math.ceil((us_time / us_max_time) * initial_tickets)
        end
    else
        us_time = waypoints.get_initial_time()
        us_max_time = us_time
    end

    if us_tickets < 0 then
        us_tickets = 0
        us_time = nil
    end

    -- Game ended reset payload mod
    if us_tickets < 0 or ru_tickets < 0 then
        NetEvents:Send('reset_payload')
    end

    if ru_tickets ~= nil then
        TicketManager:SetTicketCount(TeamId.Team2, ru_tickets)
        TicketManager:SetTicketCount(TeamId.Team1, us_tickets)
    end
end

function M.move_payload(client_or_server, transform)
    -- Perform raycast on client to stick payload to ground
    if client_or_server == "Client" then

        -- Get current pos and make it 1 unit above its current pos.
        local from = transform.trans:Clone()
        from.y = from.y + 0.5

        -- Get current pos and set y to 0 - i.e a point way below it
        local to = transform.trans:Clone()
        to.y = 0

        -- Raycast from the point above the ground to the point below the ground.
        local ground = RaycastManager:Raycast(from, to, RayCastFlags.DontCheckCharacter)

        -- Update the server to the new payload position.
        transform.trans = ground.position
        NetEvents:Send('PayloadPosition', ground.position)
    end
    
    -- IF payload exists move it
    if payload_entity ~= nil then

        for i, entity in pairs(payload_entity.entities) do
            if string.ends(entity.typeInfo.name, "StaticModelEntity") then
                local spatial_entity = SpatialEntity(entity)

                -- Move the payload
                spatial_entity.transform = transform
                spatial_entity:FireEvent('Disable')
                spatial_entity:FireEvent('Enable')
                break
            end
        end
        -- if client_or_server == "Server" then
        --     local spatial_entity = SpatialEntity(payload_entity.entities[1])
        -- else
        --     for i, entity in pairs(payload_entity.entities) do
        --         print(tostring(i) .. tostring(entity))
        --     end
        --     local spatial_entity = SpatialEntity(payload_entity.entities[1])
        -- end
        -- entity:Init(Realm.Realm_Client, true)
        -- To move the entity, we must first cast it to a SpatialEntity
        -- local spatial_entity = SpatialEntity(entity)


        -- Update payload Transform
        payload_transform = transform:Clone()
    else
        -- Create new payload at updated position.
        transform_new = LinearTransform()
        transform_new.trans = transform.trans
        M.create_payload(client_or_server, transform_new)
    end
end

function M.reset_payload_vars()
    payload_total_dist_moved = 0
    payload_entity = nil
    payload_transform = nil

    waypoint_index = 1
    payload_waypoints = nil
    payload_capturepoints = nil
    cp_current_capture_state = {2, 2, 2, 2, 2, 2, 2}
end

return M
