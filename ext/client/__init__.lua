common = require('__shared/common')
ui_utils = require("ui_utils")

time_esp_update = 0

NetEvents:Subscribe('msg_move_payload', function(data)
    common.move_payload('Client', data)
end)

NetEvents:Subscribe('reset_payload', function(data)
    print("Here?")
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

Events:Subscribe('Engine:Update', function(deltaTime, simulationDeltaTime)
    local updates_per_second = 60
    -- Update ESP intervals
    time_esp_update = time_esp_update + simulationDeltaTime
    if time_esp_update > (1/updates_per_second) then
        ui_utils.update_payload_esp()
        time_esp_update = 0
    end
end)


