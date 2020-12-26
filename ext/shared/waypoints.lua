local M = {}

mp_subway_waypoints = {
    Vec3(68.460938, 64.001755, 257.929688),
    Vec3(51.451172, 64.837692, 224.428711),
    Vec3(51.941666, 65.006683, 213.125977),
    Vec3(33.117165, 66.355301, 203.879898),
    Vec3(2.720718, 69.782074, 195.614212),
    Vec3(-17.376080, 66.672722, 158.306732),
}

function M.get_waypoints()
    waypoints = nil

    -- MP_Lake NOT METRO! TODO: Make sure this is MP lake not default metro
    if (SharedUtils:GetLevelName() == "Levels/MP_Subway/MP_Subway" or  SharedUtils:GetLevelName() == "MP_Subway") and SharedUtils:GetCurrentGameMode() == "ConquestSmall0" then
        waypoints = mp_subway_waypoints
    end

    return waypoints
end

return M