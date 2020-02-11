proc
	GlobalCount()
		set background=1
		while(1)
			if(flinchers["[world.timeofday]"])
				var/list/l=flinchers["[world.timeofday]"]
				for(var/mob/m in l)
					m.Unflinch()
			sleep(0)
			sleep(1)
			sleep(-1)

obj
	proc
		Execute()

mob
	Jump(jump_height=JUMP_ACCEL)
		if(!ingame)	return
		if(!mid_air)
			Jump_fx(src)
			IncreaseHeight(jump_height)//12
		else
			if(client)	client.ClearMovementKeys()
			gravity=2//StepHeightIncrease(5)//105 current limit for height
			if(run)	Run_Toggle()

	GetSpeed()
		var/retval
		if(run)
			retval= fly ? FLY_SPEED : run_speed
		else
			retval=walk_speed
		retval=retval+(speed_alter*retval)
		retval*=speed_multiplier
		return round(retval,1)

	Move()
		.=..()
		if(fly && run)
			if(hurtby?.target==src)//if the last person that hit you is targetting you
				if(dir & BehindDir(GetDir(src,hurtby)))//and you are running away from them
					boost_drain_delay=5//increase the rate at which your energy drains
				else//otherwise if you arent running away from them
					boost_drain_delay=10//restore the rate at which your energy drains
			else
				if(boost_drain_delay!=10)	boost_drain_delay=10
			if(world.timeofday>last_run_time+boost_drain_delay)
				last_run_time=world.timeofday
				if(!EnergyAdjust(-1))
					Run_Toggle(0)

	Run_Toggle(manual=1)
		set waitfor=0
		if(!ingame && !client && manual)	return
		fly = mid_air ? 1 : 0
		run = !run
		boost_drain_delay=10
		if(fly)
			if(run)
				ingame=0
				sleep(2)
				if(hurtby?.lasthit!=src)
					ingame=1
					if(run && EnergyAdjust(-1))
						fly=1
						last_run_time=world.timeofday
						ActivateAura(src,i='Icons/Effects/Aura.dmi')
						HyperMovement_fx(src)
					else
						fly=0
			else
				Deactivateaura(src)
		step_size=GetSpeed()


	CancelHeightIncrease()
		var/retval=0
		if(hangtime>0||(gravity==2 && run)||_height>=CEILING||(kb && !launch)||block||flinching||attacking||(run && fly)||charge||grabbedby)
			retval=1
		return retval

	DelayHeightDecrease()
		var/retval=0
		if(gravity>1)
			return retval
		if(flinching||!gravity||attacking||nudge||chase||(run && fly)||charge||block||grabbedby)
			height_accel=height_decline
			retval=1
		if(hangtime>0)
			shadow.SwitchMode()
			height_accel=height_decline
			hangtime=max(hangtime-1,0)
			retval=1
		if(set_h_accel)
			height_accel=set_h_accel
		return retval


	StateMachine(_time=30,over_ride=0)
		set waitfor=0
		if(!over_ride)
			active_time=min(MAX_ACTIVE_TIME,active_time+_time)
		else
			active_time=_time
		if(old_state)
			return
		var/ingame_keys=0
		if(!ActivateProc("StateMachine"))	return
		while(src)
			LocationUpdate()
			Gravity()
			if(client)
				if(!ingame||finisher)
					ingame_keys=1
				else
					if(ingame_keys)
						if(client.currentkey in directional_keys)
							key_down(client.currentkey, client)
						ingame_keys=0

			if(active_time<=0)
				active_time=0
				no_state=0
				old_state=""
				break
			if(!no_state)
				var/newstate="idle"
				if(attack_anim)
					attack_anim=0
					newstate=attackstates[a_state]
				else
					if(moved)
						if(run)
							newstate="run"
						else if(chase)
							newstate="dash"
						else
							newstate= mid_air ? "Flight-idle" : "move"
					if(mid_air)
						if(ascend)
							newstate="ascend"
						if(descend)
							newstate="descend"
						if(run)
							newstate="dash"
						if((run && fly)||chase)
							newstate="Flight"
					if(block)
						newstate="block"
					if(kb||launch)
						newstate="kb"
					if(charge)
						newstate="charge"
				if(newstate in animation_states)
					no_state=1
					old_state=newstate
					AnimationPlay(newstate,animation_speed[newstate],animation_states[newstate])
					active_time = active_time < animation_states[newstate] ? animation_states[newstate] : active_time
				else
					if(old_state!=newstate)
						old_state=newstate
						animate(src,icon_state=newstate,time=0)
			active_time--
			if (world.tick_usage > 90)
				lagstopsleep()//sleep(0.1)
			else
				sleep(1)
		ActivateProc("StateMachine",1)
