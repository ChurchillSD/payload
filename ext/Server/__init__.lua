common = require('__shared/common')

time_ui_update = 0

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

    time_ui_update = time_ui_update + simulationDeltaTime

    if time_ui_update > 0.1 then
        NetEvents:Broadcast('update_ui', payload_total_dist_moved)
        time_ui_update = 0
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

Events:Subscribe('Player:Chat', function(player, recipientMask, message)
    -- Capture all the points
    local iterator = EntityManager:GetIterator('ServerCapturePointEntity')
    local entity = iterator:Next()
    while entity ~= nil do
        entity = CapturePointEntity(entity)
        
        local entity_data = CapturePointEntityData(entity.data)
        entity_data:MakeWritable()

        -- entity_data.initialOwnerTeam = TeamId.Team1

        entity.team = TeamId.Team1
        entity.isControlled = true
        entity.flagVelocity = 0.000000
        entity.flagLocation = 100
        entity.flagHome = 100
        entity.isCaptureEnabled = true
        entity.cooldownTimer = 0.000000
        entity.team1CooldownPenalty = 0.000000
        entity.team2CooldownPenalty = 0.000000

        print("Ordinal")
        print(entity.name)
        print(entity_data.spawnMenuListOrdinal)
        
        entity = iterator:Next()
    end
end)