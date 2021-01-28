local M = {}

function M.get_team_name()
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

function M.get_spawn_cp_index(team_name)
    local furthest_spawnable_index = 0
    local team_id = 1

    if team_name == "US" then
        team_id = 1
        -- If US go from A - G
        for i = 1, #cp_current_capture_state do
            if cp_current_capture_state[i] == team_id then
                -- If cp is on map
                if payload_capturepoints[i] ~= nil then
                    -- if cp set to be spawnable
                    if payload_capturepoints[i][5] == true then
                        furthest_spawnable_index = i
                    end
                end
            end
        end
    else
        team_id = 2
        -- If RU go from G - A
        for i = #cp_current_capture_state, 1,-1 do
            if cp_current_capture_state[i] == team_id then
                -- If cp is on map
                if payload_capturepoints[i] ~= nil then
                    -- if cp set to be spawnable
                    if payload_capturepoints[i][5] == true then
                        furthest_spawnable_index = i
                    end
                end
            end
        end
    end

    return furthest_spawnable_index
end

return M