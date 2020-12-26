common = require('__shared/common')

function players_near_cart(team_number)
    -- Loop through all players on the team provided to see if they're near the cart

    local players = PlayerManager:GetPlayersByTeam(team_number)
    local players_near = 0

    for i = 1, #players do
        local player = players[i]
        if player.hasSoldier then
            -- Get players dist from payload
            local player_trans = player.soldier.worldTransform.trans
            local dist_to_payload = player_trans:Distance(payload_transform.trans)

            -- If dist is within the payload pushing radius then add 1 player pushing
            if dist_to_payload < payload_push_radius then
                players_near = players_near + 1
            end
        end
    end
    return players_near
end

Events:Subscribe('Engine:Update', function(deltaTime, simulationDeltaTime)

    -- Get players near cart on both team
    local attackers_near_cart = players_near_cart(1) -- Us
    local defenders_near_cart = players_near_cart(2) -- Ru

    -- If no defenders near and at least one attacker near cart, then move cart
    if (attackers_near_cart > 0) and (defenders_near_cart == 0) then
        -- Update payload transform from waypoints
        common.update_payload_server(attackers_near_cart, simulationDeltaTime)

        -- Move payload on Client then Server
        NetEvents:Broadcast('msg_move_payload', payload_transform)
        common.move_payload('Server', payload_transform)
    end
end)

-- Create the payload
Events:Subscribe('Level:Loaded', function(levelName, gameMode)
    print("Creating payload")
    common.create_payload('Server')
end)

-- Get raycast result from client and update payload position
NetEvents:Subscribe('PayloadPosition', function(player, data)
    -- Check to make sure data recived is good.
    if data.x == payload_transform.trans.x and data.z == payload_transform.trans.z then
        common.move_payload('Server', payload_transform)
    end
end)