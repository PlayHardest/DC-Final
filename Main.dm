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
		client.chatbox = new/hudobj/chatbox(null,client,show=1)
		client.chatbox.filters +=filter(type="drop_shadow", x=0, y=-1,size=0, offset=0, color=rgb(3,3,3,170)) //filter(type="outline",size=1)
		client.textbox = new/hudobj/textbox(null,client,show=1)
		client.textbox.filters +=filter(type="drop_shadow", x=0, y=-1,size=0, offset=0, color=rgb(3,3,3,170))
		player_list+=client
		PrntToClients(src,"Welcome to Dragon Chronicles v1.0\nPress alt+2 to see the instructions")
		AddHud()
		render_target="player/[client.ckey]"


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