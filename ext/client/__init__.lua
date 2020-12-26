common = require('__shared/common')

NetEvents:Subscribe('msg_move_payload', function(data)
    common.move_payload('Client', data)
end)