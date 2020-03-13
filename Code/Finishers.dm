mob
	proc
		Finisher(s)
			finisher=1
			finisher_confirm=0
			combo_status=""
			currentcombo=""
			switch(s)
				if("basic light")
					ComboEnd(light_combo)
				if("basic heavy")
					ComboEnd(heavy_combo)
				if("basic launch")
					ComboEnd(launch_combo)
				if("basic kiblast")
					ComboEnd(kiblast_combo)

		ComboEnd(combo)
			switch(combo)
				if("default light")
					DefaultLightFinish()
				if("default heavy")
					DefaultHeavyFinish()
				if("default launch")
					DefaultLaunchFinish()
				if("default ki blast")
					DefaultBlastFinish()

		DefaultBlastFinish()
			sleep(0)
			if(!lasthit)
				finisher=0
				return
			if(target!=lasthit)	GetTarget(lasthit)
			lasthit.Flinch(30)
			finisher=2//if finisher is equal to 2 then dont cancel animations; The next attack performed will signal the end of the finisher
			KiBlast("kiknockback")


		DefaultLightFinish()
			set waitfor=0
			sleep(0)
			if(!lasthit)
				finisher=0
				return
			if(target!=lasthit)	GetTarget(lasthit)
			lasthit.Flinch(30)
			finisher=2//if finisher is equal to 2 then dont cancel animations; The next attack performed will signal the end of the finisher
			a_state=3
			attack_anim=1
			Attack("kb")



		DefaultHeavyFinish()
			set waitfor=0
			sleep(0)
			if(!lasthit)
				finisher=0
				return
			if(target!=lasthit)	GetTarget(lasthit)
			lasthit.Flinch(30)
			a_state=1
			attack_anim=1
			Attack("stun nudge")
			for(var/i=10;i>0;i--)
				if(finisher_confirm||!finisher)	break
				sleep(1)
			if(!finisher_confirm||!finisher)
				finisher=0
				return
			sleep(4)
			if(!finisher)
				finisher_confirm=0
				return
			finisher=2
			attacking=0
			end_movement_action="knockback"
			bump_movement_action="End"
			if(target?.hyper_move)	UnTarget()
			if(target)
				Move_To(target,_speed=20,t_dist=60)
			else
				finisher=0
			finisher_confirm=0



		DefaultLaunchFinish()
			set waitfor=0
			sleep(0)
			if(!lasthit)
				finisher=0
				return
			if(target!=lasthit)	GetTarget(lasthit)
			lasthit.Flinch(30)
			finisher=2//if finisher is equal to 2 then dont cancel animations; The next attack performed will signal the end of the finisher
			a_state=3
			attack_anim=1
			if(mid_air)
				Attack("ground")
			else
				Attack("launch")