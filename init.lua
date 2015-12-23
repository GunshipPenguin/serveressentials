--[[
Server Essentials mod for Minetest by GunshipPenguin

To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is
distributed without any warranty.
--]]

players = {}
check_timer = 0
dofile(minetest.get_modpath("serveressentials") .. "/settings.lua")

minetest.register_privilege("godmode",
		"Player can use godmode with the /godmode command")
minetest.register_privilege("broadcast",
		"Player can use /broadcast command")
minetest.register_privilege("kill",
		"Player can kill other players with the /kill command")
minetest.register_privilege("heal",
		"Player can heal other players with the /heal command")
minetest.register_privilege("top",
		"Player can use the /top command")
minetest.register_privilege("setspeed",
		"Player can set player speeds with the /setspeed command")
minetest.register_privilege("whois",
		"Player can view other player's network information with the /whois command")
minetest.register_privilege("chatspam",
		"Player can send chat messages longer than MAX_CHAT_MSG_LENGTH without being kicked")

if AFK_CHECK then
	minetest.register_privilege("canafk",
		"Player can remain afk without being kicked")
end

if minetest.setting_get("static_spawnpoint") then
	minetest.register_privilege("spawn",
			"Player can teleport to static spawnpoint using /spawn command")

	minetest.register_chatcommand("spawn", {
		params = "",
		description = "Teleport to static spawnpoint",
		privs = {spawn = true},
		func = function(player_name, param)
			local spawn_func = function(player_name)
				local spawn_point = minetest.setting_get("static_spawnpoint")
				local player = minetest.get_player_by_name(player_name)
				player:setpos(minetest.string_to_pos(spawn_point))
				return
			end

			if SPAWN_DELAY > 0 then
				minetest.chat_send_player(player_name,
						"Teleporting you to spawn in " .. SPAWN_DELAY .. " seconds")
				minetest.after(SPAWN_DELAY, spawn_func, player_name)
			else
				minetest.chat_send_player(player_name, "Teleporting you to spawn")
				spawn_func(player_name)
			end
		end
	})
end

minetest.register_chatcommand("ping", {
	params = "",
	description = "Pong!",
	privs = {},
	func = function(player_name, text)
		minetest.chat_send_player(player_name, "Pong!")
	end
})

minetest.register_chatcommand("motd", {
	params = "",
	description = "Display server motd",
	privs = {},
	func = function(player_name, text)
		local motd = minetest.setting_get("motd")
		if motd == nil or motd == "" then
			minetest.chat_send_player(player_name, "Motd has not been set")
		else
			minetest.chat_send_player(player_name, motd)
		end
	end
})


minetest.register_chatcommand("clearinv", {
	params = "";
	description = "Clear your inventory",
	privs = {},
	func = function(player_name, text)
		local inventory = minetest.get_player_by_name(player_name):get_inventory()
		inventory:set_list("main", {})
	end,
})

minetest.register_chatcommand("broadcast", {
	params = "<text>",
	description = "Broadcast message to server",
	privs = {broadcast = true},
	func = function(player_name, text)
		minetest.chat_send_all(BROADCAST_PREFIX .. " " ..  text)
		return
	end,
})

minetest.register_chatcommand("kill", {
	params = "<player_name>",
	description = "kill specified player",
	privs = {kill = true},
	func = function(player_name, param)

		if #param==0 then
			minetest.chat_send_player(player_name, "You must supply a player name")
		elseif players[param] then
			minetest.chat_send_player(player_name, "Killing player " .. param)
			minetest.get_player_by_name(param):set_hp(0)
		else
			minetest.chat_send_player(player_name, "Player " .. param .. " cannot be found")
		end
		return
	end
})

minetest.register_chatcommand("top", {
	params = "",
	description = "Teleport to topmost block at your current position",
	privs = {top = true},
	func = function(player_name, param)
		curr_pos = minetest.get_player_by_name(player_name):getpos()
		curr_pos["y"] = math.ceil(curr_pos["y"]) + 0.5

		while minetest.get_node(curr_pos)["name"] ~= "ignore" do
			curr_pos["y"] = curr_pos["y"] + 1
		end

		curr_pos["y"] = curr_pos["y"] - 0.5

		while minetest.get_node(curr_pos)["name"] == "air" do
			curr_pos["y"] = curr_pos["y"] - 1
		end
		curr_pos["y"] = curr_pos["y"] + 0.5

		minetest.get_player_by_name(player_name):setpos(curr_pos)
		return
	end
})

minetest.register_chatcommand("killme", {
	params = "",
	description = "Kill yourself",
	func = function(player_name, param)
		minetest.chat_send_player(player_name, "Killing Player " .. player_name)
		minetest.get_player_by_name(player_name):set_hp(0)
		return
	end
})

minetest.register_chatcommand("heal", {
	params = "[player_name]",
	description = "Heal specified player, heals self if run without arguments",
	privs = {heal = true},
	func = function(player_name, param)

		if #param == 0 then
			minetest.chat_send_player(player_name, "Healing player " .. player_name)
			minetest.get_player_by_name(player_name):set_hp(20)
		elseif players[player_name] and param and players[param] then
			minetest.chat_send_player(player_name, "Healing player " .. param)
			minetest.get_player_by_name(param):set_hp(20)
		else
			minetest.chat_send_player(player_name, "Player " .. param .. " cannot not be found")
		end
		return
	end
})

minetest.register_chatcommand("gettime", {
	params = "",
	description = "Get the current time of day",
	privs = {},
	func = function(player_name, param)
		minetest.chat_send_player(player_name, "Current time of day is: " ..
				tostring(math.ceil(minetest.get_timeofday() * 24000)))
		return
	end
})

minetest.register_chatcommand("godmode", {
	params = "",
	description = "Toggle godmode",
	privs = {godmode = true},
	func = function(player_name, param)
		players[player_name]["god_mode"] = not players[player_name]["god_mode"];
		if players[player_name]["god_mode"] then
			minetest.chat_send_player(player_name, "Godmode is now on")
		else
			minetest.chat_send_player(player_name, "Godmode is now off")
		end
		return
	end
})

minetest.register_chatcommand("setspeed", {
	params = "<speed> [player_name]",
	description = "Set your or somebody else's walking speed",
	privs = {setspeed = true},
	func = function(player_name, param)
		param = string.split(param, " ")

		if #param == 0 or tonumber(param[1]) == nil then
			minetest.chat_send_player(player_name, "You must supply proper a speed")
		elseif players[player_name] and players[param[2]] then
			minetest.chat_send_player(player_name, "Setting player " ..
					param[2] ..
					"'s walking speed to " ..
					tostring(param[1]) ..
					" times normal speed")
			minetest.chat_send_player(param[2], "Your walking speed has been set to "
					.. param[1] ..
					" times normal speed")
			minetest.get_player_by_name(param[2]):set_physics_override({
					speed=tonumber(param[2]),
					jump=1.0,
					gravity=1.0
			})
		elseif players[player_name] and not param[2] then
			minetest.chat_send_player(player_name, "Setting player " ..
					player_name ..
					"'s walking speed to " ..
					tostring(param[1]) ..
					" times normal speed.")
			minetest.get_player_by_name(player_name):set_physics_override({
					speed=tonumber(param[1]),
					jump=1.0,
					gravity=1.0
			})
		else
			minetest.chat_send_player(player_name, "Player " ..
					param[2] ..
					" cannot be found")
		end
		return
	end
})

minetest.register_chatcommand("whatisthis", {
	params = "",
	description = "Get itemstring of wielded item",
	func = function(player_name, param)
		local player = minetest.get_player_by_name(player_name)
		minetest.chat_send_player(player_name, player:get_wielded_item():to_string())
		return
	end
})

minetest.register_chatcommand("whois", {
	params = "<player_name>",
	description = "Get network information of player",
	privs = {whois = true},
	func = function(player_name, param)
		if not param or not players[param] then
			minetest.chat_send_player(player_name, "Player " .. param .. " was not found")
			return
		end
		playerInfo = minetest.get_player_information(param)
		minetest.chat_send_player(player_name, param ..
				" - IP address - " .. playerInfo["address"])
		minetest.chat_send_player(player_name, param ..
				" - Avg rtt - " .. playerInfo["avg_rtt"])
		minetest.chat_send_player(player_name, param ..
				" - Connection uptime (seconds) - " .. playerInfo["connection_uptime"])
		return
	end
})

minetest.register_on_joinplayer(function(player)
	players[player:get_player_name()] = {
		last_action = minetest.get_gametime(),
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

minetest.register_on_chat_message(function(name, message)
	if KICK_CHATSPAM and not minetest.check_player_privs(name, {chatspam=true}) and
			string.len(message) > MAX_CHAT_MSG_LENGTH then
		minetest.kick_player(name,
				"You were kicked because you sent a chat message longer than " ..
				MAX_CHAT_MSG_LENGTH ..
				" characters. This is to prevent chat spamming.")
		return true
	end
	return
end)

minetest.register_globalstep(function(dtime)
	-- Loop through all connected players
	for _,player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()

		-- Only continue if the player has an entry in the players table
		if players[player_name] then

			-- Check for afk players
			if AFK_CHECK and not minetest.check_player_privs(player_name, {canafk=true}) then
				check_timer = check_timer + dtime
				if check_timer > AFK_CHECK_INTERVAL then
					check_timer = 0

					-- Kick player if he/she has been inactive for longer than MAX_INACTIVE_TIME seconds
					if players[player_name]["last_action"] + MAX_AFK_TIME <
							minetest.get_gametime() then
						minetest.kick_player(player_name, "Kicked for inactivity")
					end

					-- Warn player if he/she has less than WARN_TIME seconds to move or be kicked
					if players[player_name]["last_action"] + MAX_AFK_TIME - AFK_WARN_TIME <
							minetest.get_gametime() then
						minetest.chat_send_player(player_name, "Warning, you have " ..
								tostring(players[player_name]["last_action"] + MAX_AFK_TIME - minetest.get_gametime())
								.. " seconds to move or be kicked")
					end
				end

				-- Check if this player is doing an action
				for _,keyPressed in pairs(player:get_player_control()) do
					if keyPressed then
						players[player_name]["last_action"] = minetest.get_gametime()
					end
				end
			end

			-- Check if player has godmode turned on
			if players[player_name]["god_mode"] then
				player:set_hp(20)
				player:set_breath(11)
			end
		end
	end
end)
