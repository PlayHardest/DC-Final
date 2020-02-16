mob
	proc
		HealthAdjust(value=0)
			HP+=value
			HP=max(0,min(MaxHP,HP))
			DisplayHPbar.Resize(HP,MaxHP)
			if(client)
				HPbar.setValue(HP/MaxHP)
				if(value>=0)	HPbar.setValue(HP/MaxHP,0,2)
			if(!HP)	DeathCheck(hurtby)

		EnergyAdjust(value=0)
			if(Energy+value<0)
				return 0
			else
				Energy+=value
				Energy=max(0,min(MaxEnergy,Energy))
				DisplayKibar.Resize(Energy,MaxEnergy)
				if(client)	Kibar.setValue(Energy/MaxEnergy,1)
				return 1



		AddHud()
			set waitfor=0
			while(!client.view_width)
				sleep(1)
			combotrack=Object_Pool(/hudobj/ComboTracker,creation_params=list(null,client,list(),0),_new=1)
			HUDframe=Object_Pool(/hudobj/HUDFrame,creation_params=list(null,client,list(),1),_new=1)
			HPbar=Object_Pool(/obj/HudobjHelper/AMaskBar,creation_params=list("icon"='Icons/UI/HUD.dmi',"base_state"="health","width"=289,"height"=8,"orientation"=EAST))
			Kibar=Object_Pool(/obj/HudobjHelper/AMaskBar,creation_params=list("icon"='Icons/UI/HUD.dmi',"base_state"="energy","width"=143,"height"=4,"orientation"=EAST))
			HUDframe.vis_contents+=HPbar
			HUDframe.vis_contents+=Kibar
			DisplayFrame=Object_Pool(/image/EnemyHUD/Frame,creation_params=list("loc"=src))
			DisplayHPbar=Object_Pool(/image/EnemyHUD/HP,creation_params=list("loc"=src))
			DisplayKibar=Object_Pool(/image/EnemyHUD/Ki,creation_params=list("loc"=src))
			HealthAdjust(0)
			EnergyAdjust(0)
			if(client.options.combo_guide)	combotrack.show()
			ShowComboProgress()

		ShowComboProgress()
			set waitfor=0
			if(client?.options.combo_guide)
				var/combostring
				if(attackstring.len)
					combostring=jointext(attackstring,"|")
					if(finisher)
						combostring="[combostring]-f"
				animate(combotrack,icon_state=combostring,time=2)


		ShowStatus(mob/m)
			if(!m.client)	return
			if(!(m in viewingstats))
				viewingstats+=m
				m<<DisplayFrame
				m<<DisplayKibar
				m<<DisplayHPbar
				showingstatus=1


		HideStatus(delay=50)
			set waitfor=0
			showingstatus=0
			for(var/i=1 to delay)
				if(showingstatus)
					break
				sleep(1)
			if(showingstatus)	return
			for(var/mob/m in viewingstats)
				viewingstats-=m
				m.client.images-=DisplayFrame
				m.client.images-=DisplayKibar
				m.client.images-=DisplayHPbar



image
	var
		duration=0
		width=0

	proc
		Create()

		Resize(curval,maxval,_time=1)
			var/percent=curval/maxval
			var/new_width=floor(width*percent)
			var/buffer=ceil(width-new_width)/2
			var/matrix/M=matrix()
			M.Scale(percent,1)
			M.Translate(-buffer,0)
			animate(src,transform=M,time=_time)


	EnemyHUD
		pixel_x=-11
		pixel_y=-30
		plane=10

		Create(list/params)
			for(var/s in params)
				vars[s] = params[s]

		Frame
			icon='Icons/UI/EnemyStats.dmi'
			name="frame"
			icon_state="frame"

		HP
			icon='Icons/UI/EnemyHP.dmi'
			name="health"
			icon_state="hp"
			pixel_w=32
			width=62

		Ki
			icon='Icons/UI/EnemyKi.dmi'
			name="energy"
			icon_state="energy"
			pixel_w=34
			width=58

obj
	proc
		BuildComponents()

	HudobjHelper
		ComboProgress
			//99,199,77
			plane=2
			icon='Icons/UI/ComboTrackerFill.dmi'
			icon_state="fill"
			width=223

		AMaskBar//root object -- KEEP_TOGETHER
			appearance_flags = KEEP_TOGETHER
			mouse_opacity = 0
			var
				obj/fg
				obj/bg
				obj/fill
				obj/fill2
				obj/mask

			Create(list/params)
				for(var/s in params)
					vars[s] = params[s]
				BuildComponents()
				vis_contents.Add(mask,fg)

			Del()
				vis_contents.Remove(mask,fg)
				bg.vis_contents-=fill
				if(fill2)	bg.vis_contents-=fill2
				mask.vis_contents-=bg
				..()

			BuildComponents()
				fg=Object_Pool(/obj/HudobjHelper/MaskingParts/foreground,creation_params=list(null,'Icons/UI/HUD.dmi',base_state),_new=1)
				bg=Object_Pool(/obj/HudobjHelper/MaskingParts/background,creation_params=list(null,'Icons/UI/HUD.dmi',base_state),_new=1)
				if(base_state in trailbars)
					fill2=Object_Pool(/obj/HudobjHelper/MaskingParts/fill2,creation_params=list(null,'Icons/UI/HUD.dmi',base_state),_new=1)
				fill=Object_Pool(/obj/HudobjHelper/MaskingParts/fill,creation_params=list(null,'Icons/UI/HUD.dmi',base_state),_new=1)
				mask=Object_Pool(/obj/HudobjHelper/MaskingParts/mask,creation_params=list(null,'Icons/UI/HUD.dmi',base_state),_new=1)
				if(fill2)	bg.vis_contents+=fill2
				bg.vis_contents+=fill
				mask.vis_contents+=bg

			proc
				setValue(ratio=1.0,_time=0,_fill=1)
					ratio=min(max(ratio,0),1)
					var/fx=0,fy=0
					switch(orientation)
						if(EAST)	fx=-1
						if(WEST)	fx=1
						if(SOUTH)	fy=1
						if(NORTH)	fy=-1
					var/invratio = 1-ratio
					var/epx=width*invratio*fx
					var/epy=height*invratio*fy

					if(_fill==1)
						if(_time)
							animate(fill,pixel_w=epx,pixel_z=epy,time=_time)
						else
							fill.pixel_w=epx
							fill.pixel_z=epy
					else if(_fill==2)
						if(_time)
							animate(fill2,pixel_w=epx,pixel_z=epy,time=_time)
						else
							fill2.pixel_w=epx
							fill2.pixel_z=epy


		MaskingParts
			layer=FLOAT_LAYER
			plane=FLOAT_PLANE

			mask
				base_state="mask"

			background//BLEND_MULTIPLY KEEP_TOGETHER
				appearance_flags = KEEP_TOGETHER
				blend_mode = BLEND_MULTIPLY
				base_state="bg"

			fill
				base_state="fill"

			fill2
				base_state="fill2"

			foreground
				base_state="fg"

			New(loc,i,is)
				icon=i
				icon_state="[is]-[base_state]"
				..()


		proc
			Resize(curval,maxval,_time=1)
				var/percent=curval/maxval
				var/new_width=floor(width*percent)
				var/buffer=floor(width-new_width)/2
				var/matrix/M=matrix()
				M.Scale(percent,1)
				M.Translate(-buffer,0)
				animate(src,transform=M,time=_time)


hudobj
	ComboTracker
		icon='Icons/UI/ComboTracker.dmi'
		icon_state="z combo"
		anchor_x="CENTER"
		anchor_y="CENTER"
		width=223
		height=52
		alpha=220
		screen_y=-64


	HUDFrame
		screen_y=-8
		anchor_x="WEST"
		anchor_y="NORTH"
		width=320
		height=48