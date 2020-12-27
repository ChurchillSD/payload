local M = {}

mp_subway_waypoints = {
    Vec3(68.460938, 64.001755, 257.929688),
    Vec3(51.451172, 64.837692, 224.428711),
    Vec3(51.941666, 65.006683, 213.125977),
    Vec3(33.117165, 66.355301, 203.879898),
    Vec3(2.720718, 69.782074, 195.614212),
    Vec3(-17.376080, 66.672722, 158.306732)
}

mp_subway_cps = {
    {1, Guid("5C3EEC89-4314-4714-8423-1D10A0270458")},
    {2, Guid("2A95E4F4-9A86-44BF-9285-07B75A05B137")},
    {3, Guid("03611A2B-666A-45E7-B1D6-FFB87F2370FD")}
}

mp_013_waypoints = {
    Vec3(-15.961914, 214.941208, 43.548828),
    Vec3(-24.517578, 214.941208, 53.376953),
    Vec3(-37.094727, 214.909958, 58.472656),
    Vec3(-73.790085, 221.526184, 58.072266)
}

mp_013_cps = nil

function M.get_waypoints()
    waypoints = nil

    local levelName = SharedUtils:GetLevelName()
    local gameMode = SharedUtils:GetCurrentGameMode()

    -- MP_Lake NOT METRO! TODO: Make sure this is MP lake not default metro
    if (levelName == "Levels/MP_Subway/MP_Subway" or levelName == "MP_Subway") and gameMode == "ConquestSmall0" then
        waypoints = mp_subway_waypoints
    elseif (levelName == "Levels/MP_013/MP_013" or levelName == "MP_013") and gameMode == "ConquestSmall0" then
        waypoints = mp_013_waypoints
    end

    return waypoints
end


function M.get_cps()
    cps = nil

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

return M