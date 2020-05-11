mob
	Click()
		usr<<"[Get_Angle(usr,src,"source",anti_clockwise=0)]"


	Bump(atom/O)
		set waitfor=0
		..()
		switch(bump_movement_action)
			if("End")
				travel_distance=0
				walking=0
				angle_move=0
			if("Stop Knockback")
				travel_distance=0
				walking=0
				StopKB()
				end_movement_action=""
			if("Stop Nudge")
				travel_distance=0
				walking=0
				StopNudge()
				end_movement_action=""
			if("Stop Chase")
				travel_distance=0
				walking=0
				StopChase()
			if("Flinch(x)")
				travel_distance=0
				walking=0
				if(ismob(O))
					var/mob/M=O
					if(!M.block)
						M.Flinch(15)
			if("Chase Attack")
				travel_distance=0
				walking=0
				if(ismob(O))
					var/mob/M=O
					if(!M.block)
						M.Flinch(15)
					sleep(world.tick_lag)
					if(attacking)	return//if you are already attacking dont proceed
					a_state = rand(1,4)//assign an animation state to the attack, here it will be a punch
					attack_anim=1//set the flag for an attacking animation
					Attack("chaseatk")//send the attack info to the Attack() proc to create the hitbox

		bump_movement_action=""

	EndAutoMovement()
		sleep(0)
		if(!flinching)	ingame=1
		step_size=GetSpeed()
		shadow?.SwitchMode(world.tick_lag)
		move_x=0
		move_y=0
		no_state=0
		walking=0
		angle_move=0
		travel_distance=0
		switch(end_movement_action)
			if("light")
				LightAttack()
			if("heavy")
				HeavyAttack()
			if("kb")
				a_state = rand(1,4)//assign an animation state to the attack, here it will be a punch
				attack_anim=1//set the flag for an attacking animation
				Attack("kb")//send the attack info to the Attack() proc to create the hitbox
			if("Stop Knockback")
				StopKB()
			if("Stop Nudge")
				StopNudge()
			if("Stop Chase")
				StopChase()
			if("knockback")
				if(attacking)	return//if you are already attacking dont proceed
				a_state = rand(1,4)//assign an animation state to the attack, here it will be a punch
				attack_anim=1//set the flag for an attacking animation
				Attack("kb")//send the attack info to the Attack() proc to create the hitbox

		end_movement_action=""
		bump_movement_action=""

	New()
		..()
		++numofmobs
		_id=numofmobs
		render_target="mob_entity/[_id]"
		StateMachine(MAX_ACTIVE_TIME)
		ShadowCreate()
		if(!client)
			DisplayFrame=Object_Pool(/image/EnemyHUD/Frame,creation_params=list("loc"=src))
			DisplayHPbar=Object_Pool(/image/EnemyHUD/HP,creation_params=list("loc"=src))
			DisplayKibar=Object_Pool(/image/EnemyHUD/Ki,creation_params=list("loc"=src))
			Target=Object_Pool(/image/TargetIndicator,creation_params=list("loc"=src))
		HealthAdjust(0)
		EnergyAdjust(0)

	Man
		icon='Icons/Mobs/Base.dmi'
		bound_x=9
		bound_y=2
		bound_height=8
		bound_width=13
		HP=200
		MaxHP=200

		New()
			set waitfor=0
			..()
			setPosition(700,1000,1)
			/*sleep(60)
			world<<"attacking"
			sleep(5)
			for(var/i=1 to 4)
				world<<"attack [i]"
				HeavyAttack()
				sleep(4)*/

	Player
		icon='Icons/Mobs/Base.dmi'
		bound_x=9
		bound_y=2
		bound_height=8
		bound_width=13