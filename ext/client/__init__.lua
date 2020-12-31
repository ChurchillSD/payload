common = require('__shared/common')
ui_utils = require("ui_utils")

NetEvents:Subscribe('msg_move_payload', function(data)
    common.move_payload('Client', data)
end)

NetEvents:Subscribe('update_ui', function(data)
    ui_utils.update_payload_UI(data)
end)


Events:Subscribe('Extension:Loaded', function()
    print("Loading payload UI")
    WebUI:Init()

    ui_utils.get_waypoint_info()
end)