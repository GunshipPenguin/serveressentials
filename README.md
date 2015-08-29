# Server Essentials

Minetest mod by GunshipPenguin

A collection of useful commands and features for use by Minetest server administrators.

### List of commands:

+ /ping
  + Required privileges: None
  + Pong!

+ /clearinv
  + Required privileges: None
  + Clears your inventory.

+ /godmode
  + Required privileges: godmode
  + Toggles godmode for yourself (infinite health and breath).

+ /kill \< playerName \>
  + Required privileges: kill
  + Kills specified player.

+ /killme
  + Required Privileges: None
  + Kills self.

+ /heal \[ playerName \]
  + Required privileges: heal
  + Heals specified player, if no player is specified, heals self.

+ /motd
  + Required privileges: none
  + Displays server motd.
	
+ /broadcast
  + Required privileges: broadcast
  + Broadcasts message to entire server.

+ /top
  + Required privileges: top
  + Teleports you ontop of the highest non air node directly above you.

+ /gettime
  + Required privileges: none
  + Gets current time of day.

+ /spawn
  + Required privileges: spawn
  + Only available if static_spawnpoint is set in minetest.conf. Teleports
player to static spawnpoint.

+ /setspeed <speed> \[ playerName \]
  + Required privileges: setspeed
  + Sets speed of player. One represents normal walking speed, 2 represents
twice normal speed, etc. If no player name is specified, sets your own speed.

+ /whatisthis
  + Required privileges: None
  + Gets itemstring of currently wielded item.

+ /whois \< playerName \>
  + Required privileges: whois
  + Gets network information of specified player.

### Other features:

See settings.lua to configure these features.

+ Auto afk kicking:
  + Automatically kick afk players after a set amount of time. Players
with the canafk privilege can remain afk indefenetly.

+ First time join message:
  + Shows a message when a player joins the server for the first time.

+ Chat spam kicking:
  + Automatically kick players who send chat messages that are greater than a certian length.
