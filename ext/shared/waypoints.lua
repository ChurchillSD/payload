local M = {}

mp_subway_waypoints = {
    Vec3(68.460938, 64.001755, 257.929688),
    Vec3(51.451172, 64.837692, 224.428711),
    Vec3(51.941666, 65.006683, 213.125977),
}

function M.get_waypoints()
    if (SharedUtils:GetLevelName() == "Levels/MP_Subway/MP_Subway" or  SharedUtils:GetLevelName() == "MP_Subway") and SharedUtils:GetCurrentGameMode() == "ConquestSmall0" then
        waypoints = mp_subway_waypoints
    end
    return waypoints
end

return M