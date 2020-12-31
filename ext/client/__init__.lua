common = require('__shared/common')

NetEvents:Subscribe('msg_move_payload', function(data)
    common.move_payload('Client', data)
end)

Events:Subscribe('Extension:Loaded', function()
    print("Loading payload UI")
    WebUI:Init()
end)