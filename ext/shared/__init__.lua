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
        for _, cp in pairs(payload_capturepoints) do
            local wp_index = cp[1]
            local cp_guid = cp[2]

            local cp_obj_data = ReferenceObjectData(ResourceManager:SearchForInstanceByGuid(cp_guid))
            
            local cp_trans = payload_waypoints[wp_index]

            -- Checking for offset
            if cp[3] ~= nil then
                -- Adding offset to the cp
                cp_trans = cp_trans + cp[3]
            end

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
    end

end)