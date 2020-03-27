//projectile base speed is 25
var
	list
		missile_build=list(
			"ki blast"=list("name"="Ki Blast","Owner"=null,"_homing"=0,"power"=0.5,"effect"=5,"duration"=10,"bound_height"=10,"bound_width"=10,"bound_x"=11,"bound_y"=9,"travel_distance"=600,"step_size"=25,"icon"='Icons/Attacks/32x32.dmi',"icon_state"="ki blast","bump_movement_action"="End","end_movement_action"="","mid_air"=1),
			"homing ki blast"=list("name"="Homing Ki Blast","Owner"=null,"_homing"=2,"power"=0.5,"effect"=1,"duration"=15,"bound_height"=10,"bound_width"=10,"bound_x"=11,"bound_y"=9,"travel_distance"=600,"step_size"=20,"icon"='Icons/Attacks/32x32.dmi',"icon_state"="ki blast","bump_movement_action"="End","end_movement_action"="","mid_air"=1),
			"kiknockback"=list("name"="Ki Blast","Owner"=null,"_homing"=0,"power"=0.7,"effect"=2,"duration"=300,"bound_height"=13,"bound_width"=12,"bound_x"=11,"bound_y"=9,"travel_distance"=600,"step_size"=25,"icon"='Icons/Attacks/32x32.dmi',"icon_state"="kb blast","bump_movement_action"="End","end_movement_action"="","mid_air"=1)
			)

		beam_build=list(
			"beam"=list("name"="Beam","Owner"=null,"power"=1,"hits"=6,"effect"=1,"duration"=15,"bound_width"=13,"bound_height"=32,"bound_x"=10,"beam_y_offset"=-7,"travel_distance"=800,"step_size"=25,"icon"='Icons/Attacks/32x32.dmi',"base_state"="beam","bump_movement_action"="Hit","end_movement_action"="","mid_air"=1)
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
			sleep()
			//active_proj.Activate(src,"center")


obj
	proc
		SizeAdjust(b_w_res=0)
			switch(dir)
				if(EAST,WEST)
					var/bw=bound_width,bh=bound_height//inverses the bound_height, bound_width, bound_x and bound_y values
					bound_height=bw
					bound_width=bh
					if(!b_w_res)
						pixel_y=beam_y_offset
						bound_x=0
			if(b_w_res)
				switch(dir)
					if(SOUTH,EAST,WEST)
						base_layer=5
					else base_layer=3


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
					world<<"head was created"

				Move()
					..()
					body.Execute()
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
					//h_box=Object_Pool(/obj/Hitbox,creation_params=list("Owner"=src,"Params"=attack_info[a_type]))
					world<<"body was created"


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
					world<<"origin was created"
					//Activate(Owner,getstep=0)

				Execute()
					active++
					for(var/mob/m in bounds(src)-Owner)
						if(GetDist(Owner,m,1)>0)
							if(Owner.bound_height>=abs(Owner._height-m._height))//if m is within the same height range as the caller
								if(active>=6)
									m.TakeDamage(Owner,power,2,200,"Energy")
								else
									m.TakeDamage(Owner,power,5,duration,"Energy")

				Del()
					del body.h_box
					head.travel_distance=0
					for(var/o in parts)
						del o
					..()

				Activate()
					set waitfor=0
					..()
					sleep()
					body.Activate(src,1)
					sleep()
					head.Activate(body,1)

			Activate(atom/movable/M,getstep=0)//M is the mob the the projectile will spawn by
				set waitfor=0
				dir=M.dir
				if(!getstep)
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