common = require('__shared/common')
waypoints = require("__shared/waypoints")

local M = {}

function get_team_name()
    local client_player = PlayerManager:GetLocalPlayer()
    local team_name = "US"

    if client_player ~= nil then 
        if client_player.teamId == 1 then
            team_name = "US"
        else
            team_name = "RU"
        end
    end

    return team_name
end

function get_payload_world_to_screen()
    local payload_world_to_screen = Vec2(-1, -1)

    if payload_transform ~= nil then
        -- Make the esp marker 1m above the current payload position
        local payload_marker_transform = payload_transform.trans:Clone()
        payload_marker_transform.y = payload_marker_transform.y + 3

        print(payload_marker_transform)
        payload_world_to_screen = ClientUtils:WorldToScreen(payload_marker_transform)
    end

    -- Payload not on screen
    if payload_world_to_screen == nil then
        payload_world_to_screen = Vec2(-1, -1)
    end

    return payload_world_to_screen
end

function get_distance_from_player_to_payload()
    local dist_to_payload = 0
    local localPlayer = PlayerManager:GetLocalPlayer()
    
    if localPlayer ~= nil then
        if localPlayer.soldier ~= nil and localPlayer.soldier.alive then
            -- Get players dist from payload
            local player_trans = localPlayer.soldier.worldTransform.trans
            dist_to_payload = player_trans:Distance(payload_transform.trans)
        end
    end

    return dist_to_payload
end


NetEvents:Subscribe('update_ui', function(payload_total_dist_moved, payload_blocked, attackers_near_cart, time_left)

    local payload_world_to_screen = get_payload_world_to_screen()
    local team_name = get_team_name()

    local dist_to_payload = get_distance_from_player_to_payload()

    local ui_info = {
        ["dist_moved"] = payload_total_dist_moved, 
        ["payload_blocked"] = payload_blocked,
        ["attckers_pushing"] = attackers_near_cart,
        ["team_name"] = team_name,
        ["time_left"] = time_left,
        ["payload_x"] = payload_world_to_screen.x,
        ["payload_y"] = payload_world_to_screen.y,
        ["dist_to_payload"] = dist_to_payload
    }

    local dataJson = json.encode(ui_info)

    WebUI:ExecuteJS('update_UI(' .. dataJson .. ');')
end)

function M.initialise_UI()
    if payload_waypoints == nil then
        payload_waypoints = waypoints.get_waypoints()
    end

    if payload_capturepoints == nil then
        payload_capturepoints = waypoints.get_cps()
    end
    -- Extract just the numbers from the cps array
    local cp_waypoint_numbers = {}
    for i = 1, #payload_capturepoints do
        cp_waypoint_numbers[i] = payload_capturepoints[i][1]
    end

    -- Get waypoint numbers and distances between each waypoint
    local waypoint_distances = {}
    waypoint_distances = M.get_distances(payload_waypoints)

    local team_name = get_team_name()

    -- Send waypoint info to UI to generate track HUD element
    local data = {
        ["waypoint_distances"] = waypoint_distances,
        ["cp_waypoint_numbers"] = cp_waypoint_numbers,
        ["team_name"] = team_name
    }

    local dataJson = json.encode(data)

    WebUI:ExecuteJS('init_UI(' .. dataJson .. ');')
end

function M.get_distances(waypoints)
-- Finds the distances from last waypoints
    local waypoint_distances = {}

    for i = 1, #waypoints do
        local dist = 0
        -- If first waypoint then distance from previous is 0
        if i == 1 then
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