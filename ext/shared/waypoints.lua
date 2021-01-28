local M = {}

-- MP Lake

mp_subway_initial_time = 60 * 8

mp_subway_waypoints = {
    Vec3(63.617180, 64.236229, 243.782471),
    Vec3(53.322258, 64.798630, 221.321259),
    Vec3(44.146484, 65.040817, 198.960938),
    Vec3(32.866211, 64.316208, 183.958984),
    Vec3(19.489258, 63.547657, 166.253906),
    Vec3(8.068357, 63.771381, 142.112564),
    Vec3(-7.074216, 65.318192, 126.896484),
    Vec3(-14.440430, 64.982224, 111.188477),
    Vec3(-24.660156, 63.537891, 89.281250),
    Vec3(-28.607420, 65.819138, 82.574203),
    Vec3(-40.990341, 68.321091, 67.886719),
    Vec3(-46.996094, 68.450035, 55.419922),
    Vec3(-48.850586, 68.450043, 46.552734),
    Vec3(-47.883789, 68.455856, 35.113281),
    Vec3(-47.373764, 68.944160, 21.098633),
    Vec3(-50.951904, 69.880753, 8.688473),
    Vec3(-58.056641, 69.360184, 0.241210),
    Vec3(-71.017578, 69.111130, 0.749023),
    Vec3(-78.626007, 69.111145, -0.509766),
    Vec3(-86.134766, 69.036911, -6.958268)
}

-- {Waypoint_index, GUID, Offset, Time added when captured, spawnable}
mp_subway_cps = {
    {6, Guid("5C3EEC89-4314-4714-8423-1D10A0270458"), Vec3(0, 0, 0), 60 * 2},
    {12, Guid("2A95E4F4-9A86-44BF-9285-07B75A05B137"), Vec3(0, 0,-20), 60 * 2},
    {20, Guid("03611A2B-666A-45E7-B1D6-FFB87F2370FD"), Vec3(0, 0, 0), 60 * 2}
}

-- MP_013

mp_013_initial_time = 60 * 8

mp_013_waypoints = {
    Vec3(-15.961914, 214.941208, 43.548828),
    Vec3(-24.517578, 214.941208, 53.376953),
    Vec3(-37.094727, 214.909958, 58.472656),
    Vec3(-73.790085, 221.526184, 58.072266)
}

mp_013_cps = nil

function M.get_initial_time()
    initial_time = nil

    local levelName = SharedUtils:GetLevelName()
    local gameMode = SharedUtils:GetCurrentGameMode()
    -- MP_Lake NOT METRO! TODO: Make sure this is MP lake not default metro
    if (levelName == "Levels/MP_Subway/MP_Subway" or levelName == "MP_Subway") and gameMode == "ConquestSmall0" then
        initial_time = mp_subway_initial_time
    elseif (levelName == "Levels/MP_013/MP_013" or levelName == "MP_013") and gameMode == "ConquestSmall0" then
        initial_time = mp_013_initial_time
    end

    return initial_time
end

function M.get_cps()
    local cps = nil

    local levelName = SharedUtils:GetLevelName()
    local gameMode = SharedUtils:GetCurrentGameMode()
    -- MP_Lake NOT METRO! TODO: Make sure this is MP lake not default metro
    if (levelName == "Levels/MP_Subway/MP_Subway" or levelName == "MP_Subway") and gameMode == "ConquestSmall0" then
        cps = mp_subway_cps
    elseif (levelName == "Levels/MP_013/MP_013" or levelName == "MP_013") and gameMode == "ConquestSmall0" then
        cps = mp_013_cps
    end

    return cps
end

function M.get_waypoints()
    local waypoints = nil

    local levelName = SharedUtils:GetLevelName()
    local gameMode = SharedUtils:GetCurrentGameMode()
    -- MP_Lake NOT METRO! TODO: Make sure this is MP lake not default metro
    if (levelName == "Levels/MP_Subway/MP_Subway" or levelName == "MP_Subway") and gameMode == "ConquestSmall0" then
        waypoints = mp_subway_waypoints
        -- waypoints = mp_subway_waypoints_test
    elseif (levelName == "Levels/MP_013/MP_013" or levelName == "MP_013") and gameMode == "ConquestSmall0" then
        waypoints = mp_013_waypoints
    end

    return waypoints
end

return M
