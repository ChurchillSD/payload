common = require('__shared/common')
require "math"

print('Hello Server friends!')

-- Events:Subscribe('Player:Chat', function(player, recipientMask, message)
--     payload_transform.trans.y =  60 + (((payload_transform.trans.y - 60) + 1) % 10)
--     NetEvents:Broadcast('msg_move_payload', payload_transform)
--     common.move_payload(payload_transform, 'Server')
-- end)

function sqrd(x)
    return x * x
end

function players_near_cart()
    -- Loop through all players to see if they're near the cart
    local dist_near = 5
    local players = PlayerManager:GetPlayersByTeam(1)
    local players_near = 0
    for i = 1, #players do
        local player = players[i]
        if player.hasSoldier then
            local player_trans = player.soldier.worldTransform.trans
            local dist_sq = sqrd(payload_transform.trans.x - player_trans.x) + sqrd(payload_transform.trans.y - player_trans.y) + sqrd(payload_transform.trans.z - player_trans.z)
            if dist_sq < sqrd(dist_near) then
                players_near = players_near + 1
            end
        end
    end
    return players_near
end

Events:Subscribe('Engine:Update', function(deltaTime, simulationDeltaTime)
    local near_cart = players_near_cart()
    if near_cart > 0 then
        common.update_payload_server(near_cart)
        NetEvents:Broadcast('msg_move_payload', payload_transform)
        common.move_payload('Server', payload_transform)
    end
end)

-- Create the payload
Events:Subscribe('Level:Loaded', function(levelName, gameMode)
    print("create payload")
    common.create_payload('Server')
end)

NetEvents:Subscribe('PayloadPosition', function(player, data)
    if data.x == payload_transform.trans.x and data.z == payload_transform.trans.z then
        common.move_payload('Server', payload_transform)
    end
end)