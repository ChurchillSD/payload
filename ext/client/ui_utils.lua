common = require('__shared/common')
waypoints = require("__shared/waypoints")

local M = {}

function M.initialise_UI()
    if payload_waypoints == nil then
        payload_waypoints = waypoints.get_waypoints()
    end

    if payload_capturepoints == nil then
        print("Going in here")
        payload_capturepoints = waypoints.get_cps()
    end
    print(payload_capturepoints)
    -- Extract just the numbers from the cps array
    local cp_waypoint_numbers = {}
    for i = 1, #payload_capturepoints do
        cp_waypoint_numbers[i] = payload_capturepoints[i][1]
    end

    -- Get waypoint numbers and distances between each waypoint
    local waypoint_distances = {}
    waypoint_distances = M.get_distances(payload_waypoints)

    -- Send waypoint info to UI to generate track HUD element
    local data = {
        waypoint_distances = waypoint_distances,
        cp_waypoint_numbers = cp_waypoint_numbers,
    }

    local dataJson = json.encode(data)

    WebUI:ExecuteJS('init_UI(' .. dataJson .. ');')
end

function M.update_payload_UI(payload_total_distance)
    local data = {
        dist_moved = payload_total_distance,
    }

    local dataJson = json.encode(data)

    WebUI:ExecuteJS('update_UI(' .. dataJson .. ');')
end


function M.get_distances(waypoints)
-- Finds the distances from last waypoints
    local waypoint_distances = {}

    for i = 1, #waypoints do
        local dist = 0
        -- If first waypoint then distance from previous is 0
        if i == 1 then
            print("dist 0")
            dist = 0
        else
            local last_waypoint = waypoints[i-1]
            local current_waypoint = waypoints[i]
            
            dist = last_waypoint:Distance(current_waypoint)
        end

        waypoint_distances[i] = dist
    end

    return waypoint_distances
end

return M