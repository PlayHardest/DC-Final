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
		player_list+=client
		src<<"Type /setcounter to change your counter type"
		AddHud()
		render_target="player/[client.ckey]"


	Logout()
		if(key)
			player_list[key]=null
			del src





client
	perspective=EDGE_PERSPECTIVE

	Del()
		del chatbox
		del textbox
		del fullscreen
		for(var/datum/s in menu)
			s.destroy=1
			del s
		..()


atom
	movable
		LocationFind(_z)//discover size of instance here
			switch(_z)
				if(1)
					MAP_X=80
					MAP_Y=80
			maxgx=MAP_X*TILE_WIDTH
			maxgy=MAP_Y*TILE_HEIGHT