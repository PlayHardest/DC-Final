//projectile base speed is 25
var
	list
		missile_build=list(
			"ki blast"=list("name"="Ki Blast","Owner"=null,"_homing"=0,"power"=0.5,"effect"=5,"duration"=10,"bound_height"=10,"bound_width"=10,"bound_x"=11,"bound_y"=9,"travel_distance"=600,"step_size"=25,"icon"='Icons/Attacks/32x32.dmi',"icon_state"="ki blast","bump_movement_action"="End","end_movement_action"="","mid_air"=1),
			"homing ki blast"=list("name"="Homing Ki Blast","Owner"=null,"_homing"=2,"power"=0.5,"effect"=1,"duration"=15,"bound_height"=10,"bound_width"=10,"bound_x"=11,"bound_y"=9,"travel_distance"=600,"step_size"=20,"icon"='Icons/Attacks/32x32.dmi',"icon_state"="ki blast","bump_movement_action"="End","end_movement_action"="","mid_air"=1),
			"kiknockback"=list("name"="Ki Blast","Owner"=null,"_homing"=0,"power"=0.7,"effect"=2,"duration"=300,"bound_height"=13,"bound_width"=12,"bound_x"=11,"bound_y"=9,"travel_distance"=600,"step_size"=25,"icon"='Icons/Attacks/32x32.dmi',"icon_state"="kb blast","bump_movement_action"="End","end_movement_action"="","mid_air"=1)
			)

		beam_build=list(
			"beam"=list("name"="Beam","Owner"=null,"width"=32,"power"=1,"hits"=6,"effect"=1,"duration"=15,"bound_width"=13,"bound_height"=32,"bound_x"=10,"beam_y_offset"=-7,"travel_distance"=800,"step_size"=25,"icon"='Icons/Attacks/32x32.dmi',"base_state"="beam","bump_movement_action"="Hit","end_movement_action"="","mid_air"=1)
			)
	//_homing = 1 :: true homing
	//_homing = 2 :: homing with variance
mob
	proc
		KiBlast(a_type)//attack_info string
			set waitfor=0
			if(attacking||!a_type)	return
			if(!(a_type in kiattackcost))	return//checks for the presence of the ki attack in the costs list and only allows the user to proceed if its there
			if(!finisher)//if the user is not using a finisher ki blast only allow them to continue if they have the required ki for the attack
				if(!EnergyAdjust(kiattackcost[a_type]))	return
			if(!finisher && !chase && (a_type in can_combo))
				attackstring+=a_type
				GetCombo(attackstring)
				ShowComboProgress()//update the combo display to indicate the current combo progress upon button press
			if(a_type in invincible_attack)
				invincible=1
			ingame=0
			attacking=1
			a_state = a_state < 2 ? a_state+1 : 1
			no_state=1
			if(kiattackstates[a_type] in kia_states)
				icon_state="[kiattackstates[a_type]][a_state]"
			else
				icon_state="[kiattackstates[a_type]]"
			//--determine which effect to show--
			sleep(kistatestart[icon_state])
			MakeProjectile(a_type)
			var/exit=0//set the special exit flag to 0
			if(!attackduration[a_type])	CRASH("A duration has not been specified for the attack : [a_type]")
			for(var/i=1 to attackduration[a_type])//wait out the recovery frames
				if(!attacking||(hurtby?.lasthit==src)||!active_proj)//exit them if these conditions are met
					attacking=0
					exit=1
					break
				sleep(1)
			if(mid_air)	hangtime=10
			no_state=0
			icon_state="idle"
			if(hurtby?.lasthit!=src)	ingame=1//if the user is not being attacked return functionality
			if(a_type in invincible_attack)
				invincible=0
			if(!lasthit)//if the attack whiffed
				attackstring=list()//then reset the combo counter
				finisher=0
			if(!exit)
				attacking=0//if the special exit was not utilised to reset attacking
			else//finishers can only be triggered when a special exit was utilised
				if(!finisher && lasthit)//and someone was hit with the last attack of your combo
					if(combo_status=="complete")
						Finisher(currentcombo)
			ShowComboProgress()//update it again to show current combo progress upon completion of recovery frames



		MakeProjectile(_name)
			if(!_name||!(_name in missile_build))	return
			var/list/l=missile_build[_name]
			l["Owner"]=src
			active_proj=Object_Pool(/obj/Projectiles/Missiles,creation_params=l)
			active_proj.active=1
			sleep()
			active_proj.Activate(src,"center")


		Beam(a_type)
			set waitfor=0
			if(attacking||!a_type)	return
			if(!(a_type in kiattackcost))	return
			MakeBeam(a_type)

		MakeBeam(_name)
			if(!_name||!(_name in beam_build))	return
			var/list/l=beam_build[_name]
			l["Owner"]=src
			active_proj=Object_Pool(/obj/Projectiles/Beams/Origin,creation_params=l)
			sleep(1)
			active_proj.head.Execute()
			//active_proj.Activate(src,"center")


obj
	appearance_flags=PIXEL_SCALE

	Projectiles
		can_enter=0
		density=1
		base_layer=MOB_LAYER

		var
			tmp
				_homing=0
		Beams
			Head
				Create(list/Params)//Create the head
					for(var/v in Params)//assign the vars
						vars[v]=Params[v]
					if(!Owner||!origin)	del src//destroy if no owner or origin
					icon_state="[base_state]head"//set its icon_state
					dir=Owner.dir
					ShadowCreate()//create shadow
					SizeAdjust()//adjust bounds
					Params["head"]=src//adjust creation parameters so this object will be recognized as the head
					body=Object_Pool(/obj/Projectiles/Beams/Body,creation_params=Params)//create the body

				Execute()
					active=1
					//sleep(world.tick_lag)
					if(!Owner.target)
						if(!Owner.detect_range)	Owner.detect_range=Object_Pool(/obj/Detection,creation_params=list("Owner"=Owner,"bound_width"=500,"bound_height"=70))
						var/mob/m=Owner.detect_range.Activate(500,120)
						if(m)	Owner.GetTarget(m)
					if(Owner.target?.hyper_move)	Owner.UnTarget()
					body.invisibility=0
					if(Owner.target)
						Owner.dir=GetDir(Owner,Owner.target)
						Move_To(Owner.target/*,_rotation=1*/,_speed=step_size,homing=_homing,_readjust=(_homing>1?1:0),t_dist=travel_distance,height_adjust=1)
						//rotating it breaks the shadow
					else
						Walk(travel_distance,dir,step_size)

				Move()
					body.BeamBodyStretch(src)
					..()
					//body.Execute()
					body.BeamBodyStretch(src)
					origin.Execute()

				Bump(atom/O)
					..()
					switch(bump_movement_action)
						if("Hit")
							hits--
							if(ismob(O))
								var/mob/M=O
								travel_distance+=step_size
								if(hits<=0)
									M.TakeDamage(Owner,power,2,200,"Energy")
									bump_movement_action=""
									travel_distance=0
									walking=0
									angle_move=0
								else
									M.TakeDamage(Owner,power,effect,duration,"Energy")
						if("End")
							travel_distance=0
							walking=0
							angle_move=0
							if(ismob(O))
								var/mob/M=O
								M.TakeDamage(Owner,power,effect,duration,"Energy")
							bump_movement_action=""



				EndAutoMovement()
					sleep(0)
					step_size=GetSpeed()
					shadow?.SwitchMode(world.tick_lag)
					move_x=0
					move_y=0
					walking=0
					angle_move=0
					travel_distance=0
					//switch(end_movement_action)
					//	if()
					end_movement_action=""
					bump_movement_action=""
					del origin


			Body
				density=0
				invisibility=1

				Create(list/Params)//Create the body
					for(var/v in Params)//assign the vars
						vars[v]=Params[v]
					if(!Owner||!origin||!head)	del src//destroy if no owner or origin or head
					icon_state="[base_state]body"//set its icon_state
					dir=Owner.dir
					//ShadowCreate()//create shadow
					SizeAdjust()//adjust bounds
					origin.body=src//update the origin
					origin.parts+=src
					origin.Activate(Owner)
					Params["body"]=src
					origin.h_box=Object_Pool(/obj/Hitbox/BeamBody,creation_params=Params)

				Activate(atom/movable/M,getstep=0,_gx,_gy)
					..()


			Origin
				density=0

				Create(list/Params)//Create the origin
					for(var/v in Params)//assign the vars
						vars[v]=Params[v]
					if(!Owner)	del src//destroy if no owner
					icon_state="[base_state]origin"//set its icon_state
					dir=Owner.dir
					SizeAdjust(1)
					Params["origin"]=src//adjust creation parameters so this object will be recognized as the origin
					head=Object_Pool(/obj/Projectiles/Beams/Head,creation_params=Params)//create the head
					parts+=head//populate the parts
					name="[name] Origin"
					//Activate(Owner,getstep=0)

				Execute()
					if(!head.active)	return
					h_box.phase_through=99
					h_box.phase_tag=1
					h_box.setPosition(src)
					for(var/mob/m in bounds(h_box)-Owner)
						if(GetDist(Owner,m,1)>0)
							if(bound_height>=abs(_height-m._height))//if m is within the same height range as the caller
								h_box.phased_mobs+=m
					head.LocationUpdate()
					var/x_add=head.gx-gx,y_add=head.gy-gy
					h_box.step_size=ceil(GetDist(src,head))
					h_box.Move(loc,dir,step_x + x_add,step_y + y_add)

				Del()
					head.travel_distance=0
					for(var/o in parts)
						del o
					..()

				Activate()
					set waitfor=0
					..()
					sleep()
					body.Activate(src,0)
					head.Activate(src,0)

			Activate(atom/movable/M,getstep=0,_gx,_gy)//M is the mob the the projectile will spawn by
				set waitfor=0
				if(!M)	CRASH("No spawn loc supplied for [src]")
				dir=M.dir
				if(!getstep)
					if(_gx||_gy)
						setPosition(_gx,_gy,M.z,__height=M._height)
					else
						setPosition(M,__height=M._height)
				else
					GetStep(M,M.dir,keepdir=1,bufferdist=0)




		Missiles
			Bump(atom/O)
				..()
				switch(bump_movement_action)
					if("End")
						travel_distance=0
						walking=0
						angle_move=0
						if(ismob(O))
							var/mob/M=O
							M.TakeDamage(Owner,power,effect,duration,"Energy")
				bump_movement_action=""

			EndAutoMovement()
				sleep(0)
				step_size=GetSpeed()
				shadow?.SwitchMode(world.tick_lag)
				move_x=0
				move_y=0
				walking=0
				angle_move=0
				travel_distance=0
				//switch(end_movement_action)
				//	if()
				end_movement_action=""
				bump_movement_action=""
				del src


			Create(list/Params)
				for(var/v in Params)
					vars[v]=Params[v]
				if(!Owner)	del src
				ShadowCreate()
				//Activate(Owner)


			Activate(mob/M,_loc="center")//M is the mob the the projectile will spawn by
				set waitfor=0
				dir=Owner.dir
				power*=Owner.GetMultiplier()
				Center(M,_loc,mid_air)
				sleep(world.tick_lag)
				if(!Owner.target)
					if(!Owner.detect_range)	Owner.detect_range=Object_Pool(/obj/Detection,creation_params=list("Owner"=Owner,"bound_width"=500,"bound_height"=70))
					var/mob/m=Owner.detect_range.Activate(500,120)
					if(m)	Owner.GetTarget(m)
				if(Owner.target?.hyper_move)	Owner.UnTarget()
				if(Owner.target)
					Owner.dir=GetDir(Owner,Owner.target)
					Move_To(Owner.target/*,_rotation=1*/,_speed=step_size,homing=_homing,_readjust=(_homing>1?1:0),t_dist=travel_distance,height_adjust=1)
					//rotating it breaks the shadow
				else
					Walk(travel_distance,dir,step_size)


	proc
		SizeAdjust(b_w_res=0)
			switch(dir)
				if(EAST,WEST)
					var/bw=bound_width,bh=bound_height//inverses the bound_height, bound_width, bound_x and bound_y values
					bound_height=bw
					bound_width=bh
					if(!b_w_res)
						pixel_y+=beam_y_offset
						bound_x=0
			if(b_w_res)
				switch(dir)
					if(SOUTH,EAST,WEST)
						base_layer=5
					else base_layer=3


		BeamBodyStretch(obj/o)
			if(!o)	return
			var/newsize=GetDist(src,o)
			var/multiplier=newsize/width
			var/difference=newsize-width
			var/offset=abs(difference/2)
			var/matrix/m=matrix()
			var/offset_x=0, offset_y=0, scale_x=1, scale_y=1, trans_x=0, trans_y=0//=(o.gx-gx)/2, offset_y=(o.gy-gy)/2
			//t_x=ceil(t_x/width)
			//t_y=ceil(t_y/width)
			switch(dir)
				if(NORTH)
					scale_y=multiplier
					offset_y=offset//assign the amount we must reposition the scaled beam body by
					offset_x=ceil((o.gx-gx)*(width/max(1,GetDist(src,o))))//find the x axis displacement by multiplying the gx difference by the ratio which represents
					//body length : distance between src and target object
				if(SOUTH)
					scale_y=multiplier
					offset_y=-offset
					offset_x=ceil((o.gx-gx)*(width/max(1,GetDist(src,o))))
				if(EAST)
					scale_x=multiplier
					offset_x=offset
					offset_y=ceil((o.gy-gy)*(width/max(1,GetDist(src,o))))
				if(WEST)
					scale_x=multiplier
					offset_x=-offset
					offset_y=ceil((o.gy-gy)*(width/max(1,GetDist(src,o))))
			switch(dir)//now for displacing the src for after it has stretched or been rotated
				if(NORTH)
					trans_y=origin.bound_height-1//move the src forward from the origin's location
					if(o.angle_move)	trans_x=o.angle_move>0 ? ceil(o.move_x):ceil(-o.move_x)//move the src in the direction of the angle, given that positive angles
					//move in a clockwise direction from the currents direction's angular perspective, while negative angles move in an anti-clockwise direction
				if(SOUTH)
					trans_y=-origin.bound_height-1
					if(o.angle_move)	trans_x=o.angle_move>0 ? ceil(-o.move_x):ceil(o.move_x)
				if(EAST)
					trans_x=origin.bound_width-1
					if(o.angle_move)	trans_y=o.angle_move>0 ? ceil(-o.move_y):ceil(o.move_y)
				if(WEST)
					trans_x=-origin.bound_width-1
					if(o.angle_move)	trans_y=o.angle_move>0 ? ceil(o.move_y):ceil(-o.move_y)

			if(o.angle_move)
				angle_move=o.angle_move
				m.Turn(angle_move)
				o.transform=m
				origin.transform=m
			m=matrix()
			m.Scale(scale_x,scale_y)
			m.Translate(offset_x + trans_x,offset_y + trans_y)
			animate(src,transform=m,time=0)
			animate(transform=m.Turn(o.angle_move),time=0,flags=ANIMATION_LINEAR_TRANSFORM)






	/*proc
		Stretch(atom/movable/obj1)
			if(obj1)//&& (obj1.z==z) && z>=1)
				if(base_state in no_stretch)
					if(head.trailmake)
						var/visual_fx/O=Recycle()
						O.appearance=appearance
						O.setPosition(head,head.dir)
						allparts+=O

					M.Scale(x_s,y_s)
					M.Translate(x1 + trans_x ,y1 + trans_y)
					animate(src,transform=M,time=0)
					if(obj1.move_x || obj1.move_y)
						animate(src,transform=M.Turn(-obj1.angle_move),time=0,flags=ANIMATION_LINEAR_TRANSFORM)// + ANIMATION_END_NOW )
						M=head.transform
						animate(head,transform=M.Turn(-obj1.angle_move),time=0,flags=ANIMATION_LINEAR_TRANSFORM)// + ANIMATION_END_NOW )
						M=origin.transform
						animate(origin,transform=M.Turn(-obj1.angle_move),time=0,flags=ANIMATION_LINEAR_TRANSFORM)// + ANIMATION_END_NOW )
					if(head.steps>size/2)	alpha=255
					head.alpha=255
					origin.alpha=255
			else
				del src*/