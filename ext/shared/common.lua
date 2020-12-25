
waypoints = require("__shared/waypoints.lua")

local M = {}

payload_GUID = "86109A07-8794-11E0-9345-9992712BCB5C" -- Bag
-- payload_GUID = "7BE361E8-605D-11E0-AA6C-B4A65D6212CD" -- Fences crash clients :(
payload_entity = nil
payload_transform = nil

waypoint_index = 1
payload_waypoints = nil

function M.create_payload(client_or_server, transform_changy)
    if payload_waypoints == nil then
        payload_waypoints = waypoints.get_waypoints()
    end
    -- print("Called create payloadddd")
    -- print(SharedUtils:GetLevelName())
    if (SharedUtils:GetLevelName() == "Levels/MP_Subway/MP_Subway" or  SharedUtils:GetLevelName() == "MP_Subway") and SharedUtils:GetCurrentGameMode() == "ConquestSmall0" then
        -- print("Creating Payload")
        -- Creating entity
        local payloadData = ResourceManager:SearchForInstanceByGuid(Guid(payload_GUID))

        if payloadData ~= nil then
            payload_transform = LinearTransform()
            payload_transform.trans = payload_waypoints[1] -- Start position

            if transform_changy ~= nil then
                payload_transform = transform_changy
            end
            
            payload_entity = EntityManager:CreateEntity(payloadData, payload_transform)
        
            if payload_entity ~= nil then

                if client_or_server == 'Client' then
                    -- print("Maky on client")
                    payload_entity:Init(Realm.Realm_Client, true)
                else
                    -- print("Makey on Serbruh")
                    payload_entity:Init(Realm.Realm_Server, true)
                end

            end
        else
            print("The enitiy you are looking for does not exist")
            print("Yoda: It seems Obi-wan has lost a star system.")
        end

    end
end

function move_towards_lin(from, to, max)
    if to:Distance(from) < max then
        return to
    end
    local dir = (to - from):Normalize()
    local new_vec = from + (dir * max)
    return new_vec
end


function M.update_payload_server(num_players_near)
    local prev_wp = waypoints[waypoint_index]
    local next_wp = waypoints[waypoint_index + 1]
    local delta = 0.025
    payload_transform.trans = move_towards_lin(payload_transform.trans, next_wp, delta) -- payload_transform.trans:MoveTowards(next_wp, delta)

    if payload_transform.trans:Distance(next_wp) < delta then
        if waypoint_index == #waypoints - 1 then
            print("We're at the last waypoint you bum")
        else
            waypoint_index = waypoint_index + 1
        end
    end

    -- payload_transform.trans.y =  65.002731 + (((payload_transform.trans.y - 65.002731) + 0.01) % 1)
end

function M.move_payload(client_or_server, transform)
    if payload_entity ~= nil then
        --print("DESTROY!")
        payload_entity:Destroy()
    end

    if client_or_server == "Client" then
        -- Do two raycasts, up and down
        
        local from = transform.trans:Clone()
        from.y = from.y + 1
        local to = transform.trans:Clone()
        to.y = 0
        local ground = RaycastManager:Raycast(from, to, RayCastFlags.DontCheckCharacter)

        transform.trans = ground.position
        NetEvents:Send('PayloadPosition', ground.position)
    end
    
    -- print("Transform.trans: ")
    -- print(transform)
    -- print(transform.trans)
    transform_new = LinearTransform()
    transform_new.trans = transform.trans

    M.create_payload(client_or_server, transform_new)
end

return M