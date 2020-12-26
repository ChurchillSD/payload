
waypoints = require("__shared/waypoints.lua")

local M = {}

payload_GUID = "86109A07-8794-11E0-9345-9992712BCB5C" -- Bag
payload_basespeed = 1.2 -- Measured in dist per second
payload_speed_bonus = 0.12 -- Measured in dist per second
payload_max_pushers = 5 -- Maximum people pushing the cart before payload speed is capped
payload_push_radius = 5 -- Area around the payload that counts as pushing it.

payload_entity = nil
payload_transform = nil

waypoint_index = 1
payload_waypoints = nil

function M.create_payload(client_or_server, updated_transform)
    -- Get the waypoints for the current map
    if payload_waypoints == nil then
        payload_waypoints = waypoints.get_waypoints()
    end

    if payload_waypoints ~= nil then
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

    end
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
    local prev_wp = waypoints[waypoint_index]
    local next_wp = waypoints[waypoint_index + 1]
    local dist_per_sec = payload_basespeed -- Base payload distance to move each tick.

    -- Payload speed changes based on num players near cart.
    if num_players_near > payload_max_pushers then
        num_players_near = payload_max_pushers
    end

    dist_per_sec = payload_basespeed + (num_players_near * payload_speed_bonus)

    -- Get new trans for the payload
    payload_transform.trans = move_towards_lin(payload_transform.trans, next_wp, (dist_per_sec * simulationDeltaTime)) -- payload_transform.trans:MoveTowards(next_wp, delta)

    -- Check if we have reached the next waypoint and update waypoint index
    if payload_transform.trans == next_wp then
        if waypoint_index == #waypoints - 1 then
            print("We're at the last waypoint.")
        else
            waypoint_index = waypoint_index + 1
        end
    end

end

function M.move_payload(client_or_server, transform)

    -- IF payload exists delete it.
    if payload_entity ~= nil then
        payload_entity:Destroy()
    end

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
    
    -- Create new payload at updated position.
    transform_new = LinearTransform()
    transform_new.trans = transform.trans
    M.create_payload(client_or_server, transform_new)
end

return M