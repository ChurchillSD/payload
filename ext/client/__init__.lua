common = require('__shared/common')

NetEvents:Subscribe('msg_move_payload', function(data)
    common.move_payload('Client', data)
end)

-- Create the payload
-- Events:Subscribe('Level:Loaded', function(levelName, gameMode)
--     --print("create payload")
--     --common.create_payload('Client')
-- end)
