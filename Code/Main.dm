/*
	These are simple defaults for your project.
 */

world
	fps = 25		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default
	mob=/mob/Player
	view = 6		// show up to 6 tiles outward from center (13x13 view)

	New()
		..()
		GlobalCount()

var
	game_version="0.2a"

// Make objects move 8 pixels per tick when walking

mob
	var
		tmp
			static
				numofmobs=0

	Login()
		client.focus=src
		LocationUpdate()
		ingame=1
		step_size=GetSpeed()
		setPosition(rand(700,705),rand(1150,1155),1)
		global.player_list+=client
		PrntToClients(src,"Welcome to Dragon Chronicles v[game_version]\nPress alt+2 to see the instructions\nPress alt+1 to open the output console")
		src<<"Type /setcounter to change your counter type"
		AddHud()
		render_target="player/[client.ckey]"


	Logout()
		..()
		del client.chatbox
		del client.textbox
		del client.fullscreen
		for(var/datum/s in client.menu)
			s.destroy=1
			del s
		global.player_list-=src
		del src


turf
	icon='Icons/Map/Turf.dmi'
	New()
		..()
		icon+=rgb(rand(1,255),rand(1,255),rand(1,255))

world
	maxx=50
	maxy=50
	maxz=1


client
	perspective=EDGE_PERSPECTIVE