--[[
Server Essentials mod for Minetest by GunshipPenguin
To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is
distributed without any warranty.
]]

players = {}
checkTimer = 0
dofile(minetest.get_modpath("serveressentials") .. "/settings.lua")

minetest.register_privilege("godmode", "Player can use godmode with the /godmode command")
minetest.register_privilege("broadcast", "Player can use /broadcast command")
minetest.register_privilege("kill", "Player can kill other players with the /kill command")
minetest.register_privilege("heal", "Player can heal other players with the /heal command")
minetest.register_privilege("top", "Player can use the /top command")
minetest.register_privilege("setspeed", "Player can set player speeds with the /setspeed command")
minetest.register_privilege("whois", "Player can view other player's network information with the /whois command")
minetest.register_privilege("disallowednodes", "Player can place nodes in the DISALLOWED_NODES table")
minetest.register_privilege("chatspam", "Player can send chat messages longer than MAX_CHAT_MSG_LENGTH without being kicked")

if AFK_CHECK then
	minetest.register_privilege("canafk", "Player can remain afk without being kicked")
end

if REMOVE_BONES then
	minetest.register_abm({
		nodenames = {"bones:bones"},
		interval = REMOVE_BONES_TIME,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			minetest.remove_node(pos)
		end
	})
end

if minetest.setting_get("static_spawnpoint") then
	minetest.register_privilege("spawn", "Player can teleport to static spawnpoint using /spawn command")
	
	minetest.register_chatcommand("spawn", {
		params = "",
		description = "Teleport to static spawnpoint",
		privs = {spawn = true}, 
		func = function(playerName, param)
			local spawnPoint = minetest.setting_get("static_spawnpoint") 
			minetest.get_player_by_name(playerName):setpos(minetest.string_to_pos(spawnPoint))
			return
		end
	})
end

minetest.register_chatcommand("ping", {
	params = "",
	description = "Pong!",
	privs = {},
	func = function(playerName, text)
		minetest.chat_send_player(playerName, "Pong!")
	end
})

minetest.register_chatcommand("motd", {
	params = "", 
	description = "Display server motd",
	privs = {}, 
	func = function(playerName, text)
		local motd = minetest.setting_get("motd")
		if motd == nil or motd == "" then
			minetest.chat_send_player(playerName, "Motd has not been set")
		else
			minetest.chat_send_player(playerName, motd)
		end
	end 
})


minetest.register_chatcommand("clearinv", {
	params = "";
	description = "Clear your inventory",
	privs = {},
	func = function(playerName, text)
		local inventory = minetest.get_player_by_name(playerName):get_inventory()
		inventory:set_list("main", {})
	end,
})

minetest.register_chatcommand("broadcast", {
	params = "<text>",
	description = "Broadcast message to server",
	privs = {broadcast = true},
	func = function(playerName, text)
		minetest.chat_send_all(BROADCAST_PREFIX .. " " ..  text)
		return
	end,
})

minetest.register_chatcommand("kill", {
	params = "<playerName>",
	description = "kill specified player",
	privs = {kill = true},
	func = function(playerName, param)
		
		if #param==0 then
			minetest.chat_send_player(playerName, "You must supply a player name")
		elseif players[param] then
			minetest.chat_send_player(playerName, "Killing player " .. param)
			minetest.get_player_by_name(param):set_hp(0)
		else
			minetest.chat_send_player(playerName, "Player " .. param .. " cannot be found")
		end
		return
	end
})

minetest.register_chatcommand("top", {
	params = "",
	description = "Teleport to topmost block at your current position",
	privs = {top = true},
	func = function(playerName, param)
		currPos = minetest.get_player_by_name(playerName):getpos()
		currPos["y"] = math.ceil(currPos["y"]) + 0.5
		
		while minetest.get_node(currPos)["name"] ~= "ignore" do
			currPos["y"] = currPos["y"] + 1
		end
		
		currPos["y"] = currPos["y"] - 0.5

		while minetest.get_node(currPos)["name"] == "air" do
			currPos["y"] = currPos["y"] - 1
		end
		currPos["y"] = currPos["y"] + 0.5
		
		minetest.get_player_by_name(playerName):setpos(currPos)
		return
	end
})

minetest.register_chatcommand("killme", {
	params = "",
	description = "Kill yourself",
	func = function(playerName, param)
		minetest.chat_send_player(playerName, "Killing Player " .. playerName)
		minetest.get_player_by_name(playerName):set_hp(0)
		return
	end
})

minetest.register_chatcommand("heal", {
	params = "[playerName]",
	description = "Heal specified player, heals self if run without arguments",
	privs = {heal = true},
	func = function(playerName, param)
		
		if #param==0 then
			minetest.chat_send_player(playerName, "Healing player " .. playerName)
			minetest.get_player_by_name(playerName):set_hp(20)
		elseif players[playerName] and param and players[param] then
			minetest.chat_send_player(playerName, "Healing player " .. param)
			minetest.get_player_by_name(param):set_hp(20)
		else
			minetest.chat_send_player(playerName, "Player " .. param .. " cannot not be found")
		end
		return
	end
})

minetest.register_chatcommand("gettime", {
	params = "", 
	description = "Get the current time of day", 
	privs = {},
	func = function(playerName, param)
		minetest.chat_send_player(playerName, "Current time of day is: " .. tostring(math.ceil(minetest.get_timeofday()*24000)))
		return
	end
})

minetest.register_chatcommand("godmode", {
	params = "",
	description = "Toggle godmode",
	privs = {godmode = true},
	func = function(playerName, param)
		players[playerName]["godMode"] = not players[playerName]["godMode"];
		if players[playerName]["godMode"] then
			minetest.chat_send_player(playerName, "Godmode is now on")
		else
			minetest.chat_send_player(playerName, "Godmode is now off")
		end
		return
	end
})

minetest.register_chatcommand("setspeed", {
	params = "<speed> [playerName]",
	description = "Set your or somebody else's walking speed",
	privs = {setspeed = true},
	func = function(playerName, param)
		param = string.split(param, " ")
		
		if #param==0 or tonumber(param[1]) == nil then
			minetest.chat_send_player(playerName, "You must supply proper a speed")
		elseif players[playerName] and players[param[2]] then
			minetest.chat_send_player(playerName, "Setting player " .. param[2] .. "'s walking speed to " .. tostring(param[1]) .. " times normal speed")
			minetest.chat_send_player(param[2], "Your walking speed has been set to " .. param[1] .. " times normal speed")
			minetest.get_player_by_name(param[2]):set_physics_override({speed=tonumber(param[2]), jump=1.0, gravity=1.0})
		elseif players[playerName] and not param[2] then
			minetest.chat_send_player(playerName, "Setting player " .. playerName .. "'s walking speed to " .. tostring(param[1]) .. " times normal speed.")
			minetest.get_player_by_name(playerName):set_physics_override({speed=tonumber(param[1]), jump=1.0, gravity=1.0})
		else
			minetest.chat_send_player(playerName, "Player ".. param[2] .. " cannot be found")
		end
		return
	end
})

minetest.register_chatcommand("whatisthis", {
	params = "",
	description = "Get itemstring of wielded item",
	func = function(playerName, param)
		minetest.chat_send_player(playerName, minetest.get_player_by_name(playerName):get_wielded_item():to_string())
		return
	end
})

minetest.register_chatcommand("whois", {
	params = "<playerName>",
	description = "Get network information of player",
	privs = {whois = true},
	func = function(playerName, param)
		if not param or not players[param] then
			minetest.chat_send_player(playerName, "Player " .. param .. " was not found")
			return
		end
		playerInfo = minetest.get_player_information(param)
		minetest.chat_send_player(playerName, param .. " - IP address - " .. playerInfo["address"])
		minetest.chat_send_player(playerName, param .. " - Avg rtt - " .. playerInfo["avg_rtt"])
		minetest.chat_send_player(playerName, param .. " - Connection uptime (seconds) - " .. playerInfo["connection_uptime"])
		return
	end
})

minetest.register_on_joinplayer(function(player)
	players[player:get_player_name()] = {
		lastAction = minetest.get_gametime(),
		godmode = false
	}
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)


minetest.register_on_newplayer(function(player)
	if SHOW_FIRST_TIME_JOIN_MSG then
		minetest.after(0.1, function()
			minetest.chat_send_all(player:get_player_name() .. FIRST_TIME_JOIN_MSG)
		end)
	end
end)

minetest.register_on_placenode(function(pos, newNode, placer, oldnode, itemStack, pointed_thing)

	for _,nodeName in pairs(DISALLOWED_NODES) do
		if nodeName == newNode["name"] then
			if minetest.check_player_privs(placer:get_player_name(), {disallowednodes=true}) then
				return
			else
				minetest.remove_node(pos)
				minetest.chat_send_player(placer:get_player_name(), "You cannot place the node " .. newNode["name"])
			end
		end
	end
	return
end)

minetest.register_on_chat_message(function(name, message)
	if KICK_CHATSPAM and not minetest.check_player_privs(name, {chatspam=true}) and string.len(message) > MAX_CHAT_MSG_LENGTH then
		minetest.kick_player(name, "You were kicked because you sent a chat message longer than " .. MAX_CHAT_MSG_LENGTH .. " characters. This is to prevent chat spamming.")
	end
	return 
end)

minetest.register_globalstep(function(dtime)
	
	--Loop through all connected players
	for _,player in ipairs(minetest.get_connected_players()) do
		local playerName = player:get_player_name()
		
		if players[playerName] then --Only continue if the player has an entry in the players table
		
			--Check for afk players
			if AFK_CHECK and not minetest.check_player_privs(playerName, {canafk=true}) then
				checkTimer = checkTimer + dtime
				if checkTimer > AFK_CHECK_INTERVAL then
					checkTimer = 0
					
					--Kick player if he/she has been inactive for longer than MAX_INACTIVE_TIME seconds
					if players[playerName]["lastAction"] + MAX_AFK_TIME < minetest.get_gametime() then 
						minetest.kick_player(playerName, "Kicked for inactivity")
					end
					
					--Warn player if he/she has less than WARN_TIME seconds to move or be kicked
					if players[playerName]["lastAction"] + MAX_AFK_TIME - AFK_WARN_TIME < minetest.get_gametime() then
						minetest.chat_send_player(playerName, "Warning, you have " .. tostring(players[playerName]["lastAction"] + MAX_AFK_TIME - minetest.get_gametime()) .. " seconds to move or be kicked")
					end
				end
				
				--Check if this player is doing an action
				for _,keyPressed in pairs(player:get_player_control()) do
					if keyPressed then
						players[playerName]["lastAction"] = minetest.get_gametime()
					end
				end
			end
			
			--Check if player has godmode turned on
			if players[playerName]["godMode"] then
				player:set_hp(20)
				player:set_breath(11)
			end
		end
	end
end)
