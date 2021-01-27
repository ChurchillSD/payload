
waypoints = require("__shared/waypoints")

local M = {}

payload_GUID = "86109A07-8794-11E0-9345-9992712BCB5C" -- Bag
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
payload_total_dist = nil

-- This has to be hardcoded: TicketManager:GetTicketCount() isn't working!
initial_tickets = 350
ru_tickets = initial_tickets
us_time = nil

function calculate_total_dist()
    local prev = payload_waypoints[1]
    payload_total_dist = 0
    for i = 2, #payload_waypoints do
        payload_total_dist = payload_total_dist + prev:Distance(payload_waypoints[i])
        prev = payload_waypoints[i]
    end
end

function M.create_payload(client_or_server, updated_transform)
    -- Get the waypoints for the current map
    if payload_waypoints == nil then
        payload_waypoints = waypoints.get_waypoints()
    end

    if payload_waypoints ~= nil then
        calculate_total_dist()
        -- Creating entity
        local payloadData = ResourceManager:SearchForInstanceByGuid(Guid(payload_GUID))

        if payloadData ~= nil then
            payload_transform = LinearTransform()
            
            -- Set default position of payload to starting position
            payload_transform.trans = payload_waypoints[1] -- Start position
            
            -- If transform has been passed in to function use that instead.
            if updated_transform ~= nil then
                payload_transform = updated_transform
            end
            
            -- Create payload entity at position of payload transfrom
            payload_entity = EntityManager:CreateEntity(payloadData, payload_transform)
            
            -- Make on Client or Server depending on who called this function
            if payload_entity ~= nil then
                if client_or_server == 'Client' then
                    payload_entity:Init(Realm.Realm_Client, true)
                else
                    payload_entity:Init(Realm.Realm_Server, true)
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
        if waypoint_index ~= #payload_waypoints - 1 then
            waypoint_index = waypoint_index + 1
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

        if old_cp_index ~= capturepoint_index then
            -- Capture point has been taken

            -- Update US time
            us_time = us_time + payload_capturepoints[capturepoint_index][4]
            -- Capture the flag!
            -- TODO
        end

        ru_tickets = math.ceil(initial_tickets * (1 - (capturepoint_index / total_cps)))
    end
end

function M.update_tickets(deltaTime)
    -- Call this function every engine update


    local us_tickets = initial_tickets
    if us_time ~= nil then
        us_time = us_time - deltaTime
        if us_time < 5 * 60 then
            us_tickets = math.ceil((us_time / (5 * 60)) * initial_tickets)
        end
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
        from.y = from.y + 1

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
        -- To move the entity, we must first cast it to a SpatialEntity
        local spacial_payload = SpatialEntity(payload_entity)

        -- Move the bag
        spacial_payload.transform = transform
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
end

return M
