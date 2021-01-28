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
    if payload_transform ~= nil then
        -- Get players near cart on both team
        local attackers_near_cart = players_near_cart(1) -- Us
        local defenders_near_cart = players_near_cart(2) -- Ru
        local payload_blocked = false;

        -- If no defenders near and at least one attacker near cart, then move cart
        if (attackers_near_cart > 0) and (defenders_near_cart == 0) then
            -- Update payload transform from waypoints
            common.update_payload_server(attackers_near_cart, simulationDeltaTime)

            -- Move payload on Client then Server
            NetEvents:Broadcast('msg_move_payload', payload_transform)
            common.move_payload('Server', payload_transform)
        end

        -- Is payload blocked by defenders
        if (defenders_near_cart > 0) and (attackers_near_cart > 0) then
            payload_blocked = true
        else
            payload_blocked = false
        end

        -- Update UI 10 times a sec I think lol
        time_ui_update = time_ui_update + simulationDeltaTime
        if time_ui_update > 0.1 then
            NetEvents:Broadcast('update_ui', payload_total_dist_moved, payload_blocked, attackers_near_cart, us_time)
            time_ui_update = 0
        end

        -- Update the payload tickets
        common.update_tickets(deltaTime)
    end
end)

-- Create the payload
Events:Subscribe('Level:Loaded', function(levelName, gameMode)
    NetEvents:Broadcast('reset_payload')
    common.reset_payload_vars()

    print("Creating payload")
    local payload_active = common.create_payload('Server')

    if payload_active then
        print("Payload mod enabled.")
        ServerUtils:SetCustomGameModeName("Payload")

        no_pre_round()
        -- TODO - Subscribe events HERE
    end
end)

-- Client asking for the payload position
NetEvents:Subscribe('PayloadPositionRequest', function(player, data)
    -- Send the client the latest payload position
    NetEvents:SendTo("msg_move_payload", player, payload_transform)
end)

-- Get raycast result from client and update payload position
NetEvents:Subscribe('PayloadPosition', function(player, data)
    -- Check to make sure data recived is good.
    if data.x == payload_transform.trans.x and data.z == payload_transform.trans.z then
        common.move_payload('Server', payload_transform)
    end
end)

-- Moves the player
NetEvents:Subscribe('MovePlayer', function(player, new_pos, client_player)
    if client_player ~= nil then
        -- Move the player to the new position
        client_player.soldier:SetPosition(new_pos)
    else
        print("Could not find current player!")
    end
end)

-- =================================================================================
-- BreeArnold No PreRound - https://community.veniceunleashed.net/t/no-preround/1860
-- =================================================================================
Events:Subscribe('Partition:Loaded', function(partition)
	for _, instance in pairs(partition.instances) do
		if instance:Is('PreRoundEntityData') then
			instance = PreRoundEntityData(instance)
			instance:MakeWritable()
			instance.enabled = false
		end
	end
end)

function no_pre_round()

	-- This is for Conquest tickets etc.
	local ticketCounterIterator = EntityManager:GetIterator("ServerTicketCounterEntity")
	
	local ticketCounterEntity = ticketCounterIterator:Next()
	while ticketCounterEntity do

		ticketCounterEntity = Entity(ticketCounterEntity)
		ticketCounterEntity:FireEvent('StartRound')
		ticketCounterEntity = ticketCounterIterator:Next()
	end
	
	-- This is for Rush tickets etc.
	local lifeCounterIterator = EntityManager:GetIterator("ServerLifeCounterEntity")
	
	local lifeCounterEntity = lifeCounterIterator:Next()
	while lifeCounterEntity do

		lifeCounterEntity = Entity(lifeCounterEntity)
		lifeCounterEntity:FireEvent('StartRound')
		lifeCounterEntity = lifeCounterIterator:Next()
	end
	
	-- This is for TDM tickets etc.
	local killCounterIterator = EntityManager:GetIterator("ServerKillCounterEntity")
	
	local killCounterEntity = killCounterIterator:Next()
	while killCounterEntity do

		killCounterEntity = Entity(killCounterEntity)
		killCounterEntity:FireEvent('StartRound')
		killCounterEntity = killCounterIterator:Next()
	end
	
	-- This is needed so you are able to move
	local inputRestrictionIterator = EntityManager:GetIterator("ServerInputRestrictionEntity")
	
	local inputRestrictionEntity = inputRestrictionIterator:Next()
	while inputRestrictionEntity do

		inputRestrictionEntity = Entity(inputRestrictionEntity)
		inputRestrictionEntity:FireEvent('Disable')
		
		inputRestrictionEntity = inputRestrictionIterator:Next()
	end
	
	-- This Entity is needed so the round ends when tickets are reached
	local roundOverIterator = EntityManager:GetIterator("ServerRoundOverEntity")
	
	local roundOverEntity = roundOverIterator:Next()
	while roundOverEntity do

		roundOverEntity = Entity(roundOverEntity)
		roundOverEntity:FireEvent('RoundStarted')
		
		roundOverEntity = roundOverIterator:Next()
	end
	
	-- This EventGate needs to be closed otherwise Attacker can't win in Rush 
	local eventGateIterator = EntityManager:GetIterator("EventGateEntity")
	
	local eventGateEntity = eventGateIterator:Next()
	while eventGateEntity do

		eventGateEntity = Entity(eventGateEntity)
		if eventGateEntity.data.instanceGuid == Guid('253BD7C1-920E-46D6-B112-5857D88DAF41') then
			eventGateEntity:FireEvent('Close')
		end
		eventGateEntity = eventGateIterator:Next()
	end
end
