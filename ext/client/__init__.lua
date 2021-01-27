common = require('__shared/common')
ui_utils = require("ui_utils")

NetEvents:Subscribe('msg_move_payload', function(data)
    common.move_payload('Client', data)
end)

NetEvents:Subscribe('reset_payload', function(data)
    common.reset_payload_vars()
end)

Events:Subscribe('Level:Loaded', function(levelName, gameMode)
    print("Initialise payload UI")
    common.create_payload('Client')
    -- Ask the server for a payload update
    NetEvents:Send('PayloadPositionRequest')
    ui_utils.initialise_UI()
end)

Events:Subscribe('Extension:Loaded', function()
    print("Loading payload UI")
    WebUI:Init()
end)
