common = require('__shared/common')
waypoints = require("__shared/waypoints")

-- Placing capture points on the map as configured in waypoints lua
Events:Subscribe('Level:Loaded', function(levelName, gameMode)
    -- local b_instance = ResourceManager:SearchForInstanceByGuid(Guid("0EBE4C00-9840-4D65-49CB-019C23BBC66B"))

    if payload_capturepoints == nil then
        payload_capturepoints = waypoints.get_cps()
    end

    if payload_waypoints == nil then
        payload_waypoints = waypoints.get_waypoints()
    end

    if payload_capturepoints ~= nil then
        for _, cp in ipairs(payload_capturepoints) do
            local wp_index = cp[1]
            local cp_guid = cp[2]

            local cp_obj_data = ReferenceObjectData(ResourceManager:SearchForInstanceByGuid(cp_guid))
            
            local cp_trans = payload_waypoints[wp_index]

            -- Checking for offset
            if cp[3] ~= nil then
                -- Adding offset to the cp
                cp_trans = cp_trans + cp[3]
            end
            -- Put the flag in the ground to work around flag only moving client-side
            cp_trans.y = cp_trans.y - 1.5

            -- Changing location of waypoint
            cp_obj_data:MakeWritable()
            local cp_pos = LinearTransform(
                Vec3(1, 0, 0), 
                Vec3(0, 1, 0), 
                Vec3(0, 0, 1), 
                cp_trans
            )
        
            cp_obj_data.blueprintTransform = cp_pos
        end

        -- Set all capture points to non-capturable
        local iterator = EntityManager:GetIterator('ServerCapturePointEntity')
        local entity = iterator:Next()
        while entity ~= nil do
            entity = CapturePointEntity(entity)

            local name = tostring(entity.name)

            local cp_letter = string.sub(name, string.len(name) - 1)

            if cp_letter ~= "HQ" then
                -- This is a capture point, NOT an HQ :)

                local entity_data = CapturePointEntityData(entity.data)
                entity_data:MakeWritable()

                entity.team = TeamId.Team2
                entity.isControlled = true
                entity.isCaptureEnabled = false
            end

            entity = iterator:Next()
        end
    end

end)
