
local M = {}

payload_GUID = "86109A07-8794-11E0-9345-9992712BCB5C" -- Bag
payload_start_pos = Vec3(58.085938, 65.002731, 229.448242)
payload_entity = nil
payload_transform = nil

function M.create_payload(client_or_server, transform_changy)
    -- print("Called create payloadddd")
    -- print(SharedUtils:GetLevelName())
    if (SharedUtils:GetLevelName() == "Levels/MP_Subway/MP_Subway" or  SharedUtils:GetLevelName() == "MP_Subway") and SharedUtils:GetCurrentGameMode() == "ConquestSmall0" then
        -- print("Creating Payload")
        -- Creating entity
        local payloadData = ResourceManager:SearchForInstanceByGuid(Guid(payload_GUID))

        if payloadData ~= nil then
            payload_transform = LinearTransform()
            payload_transform.trans = payload_start_pos
            print(type(payload_transform))

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

function M.move_payload(client_or_server, transform)
    if payload_entity ~= nil then
        --print("DESTROY!")
        payload_entity:Destroy()
    end
    
    -- print("Transform.trans: ")
    -- print(transform)
    -- print(transform.trans)
    transform_new = LinearTransform()
    transform_new.trans = transform.trans

    M.create_payload(client_or_server, transform_new)
end

return M