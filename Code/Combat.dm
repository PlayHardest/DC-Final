mob
	proc
		Block()
			block=world.timeofday//set the block flag to world.timeofday to easier facilitate counters
			ingame=0//disable functionality
			blockhit=world.timeofday

		Unblock(delay=1)
			block=0//disable the block flag
			if(mid_air)	unblock_delay=unblock_delay ? unblock_delay : 2
			if(unblock_delay && delay)	sleep(unblock_delay)//if there is delay for the unblock sleep the val
			if(!flinching && !travel_distance)	ingame=1//if not in an incapacitated state return functionality
			unblock_delay=0//reset the unblock_delay
			blockhit=0


		GetTarget(mob/m)
			if(!m||m==src)	return
			if(target==m)
				UnTarget()
				return
			if(target)
				UnTarget()
			target=m
			src<<m.Target
			targ_image=m.Target

		UnTarget()
			if(target)
				target=null
				if(client)
					client.images-=targ_image
					targ_image=null


		GenAttack(attack="light")
			if(!attackstring.len)
				end_movement_action=attack
				bump_movement_action="End"
				if(!target)
					if(!detect_range)	detect_range=Object_Pool(/obj/Detection,creation_params=list("Owner"=src,"bound_width"=96,"bound_height"=48))
					var/mob/m=detect_range.Activate(96,48)
					if(!m)	m=detect_range.Activate(72,72,"center")
					if(m)	GetTarget(m)
				if(target?.hyper_move)	UnTarget()
				if(target && (GetDist(src,target)<96))
					Move_To(target,_speed=20,homing=1,t_dist=40,height_adjust=1)
				else
					Walk(40,dir,20)
			else
				if(attack=="light")
					LightAttack()
				else
					HeavyAttack()

		LightAttack()
			if(attacking||!ingame)	return//if you are already attacking dont proceed
			a_state = a_state < 2 ? a_state+1 : 1//assign an animation state to the attack, here it will be a punch
			attack_anim=1//set the flag for an attacking animation
			Attack("light")//send the attack info to the Attack() proc to create the hitbox

		HeavyAttack()
			if(attacking||!ingame)	return//if you are already attacking dont proceed
			a_state = max(a_state,3)
			a_state = a_state < 4 ? a_state+1 : 3//assign an animation state to the attack, here it will be a punch
			attack_anim=1//set the flag for an attacking animation
			Attack("heavy")//send the attack info to the Attack() proc to create the hitbox


		Attack(a_type)//attack_info string
			set waitfor=0
			if(attacking||!a_type)	return
			if(!finisher && !chase && (a_type in can_combo))
				attackstring+=a_type
				GetCombo(attackstring)
				ShowComboProgress()//update the combo display to indicate the current combo progress upon button press
			if(a_type in invincible_attack)
				invincible=1
			ingame=0
			attacking=attack_priority[a_type]//set the priority for frame data/clash situations
			if(animation_states[attackstates[a_state]])
				last_frame_static=abs(attackduration[a_type] - animation_states[attackstates[a_state]])//get the amount of extra
			//ticks to freeze on the last frame of the attack animation for by calculating the abs value of the max attackduration - the amount of states the animation
			//lasts for
			//--determine which effect to show--
			h_box=Object_Pool(/obj/Hitbox,creation_params=list("Owner"=src,"Params"=attack_info[a_type]))//create the hitbox
			var/exit=0//set the special exit flag to 0
			if(!attackduration[a_type])	CRASH("A duration has not been specified for the attack : [a_type]")
			for(var/i=1 to attackduration[a_type])//wait out the recovery frames
				if(!attacking||(hurtby?.lasthit==src)||!h_box)//exit them if these conditions are met
					exit=1
					if(play_anim)
						cancel_anim=1//if the animation is still playing exit it
					break
				sleep(1)
			if(mid_air)	hangtime=10
			if(h_box)//if the hitbox is still active destroy it
				del h_box
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


		GrabAttack(a_type)//attack_info string
			set waitfor=0
			if(attacking||!a_type)	return
			if(a_type in invincible_attack)
				invincible=1
			ingame=0
			attacking=attack_priority[a_type]//set the priority for frame data/clash situations
			//--determine which effect to show--
			h_box=Object_Pool(/obj/Hitbox/GrabBox,creation_params=list("Owner"=src,"Params"=attack_info[a_type]))//create the hitbox
			//sleep(1)
			while(h_box.active)
				if(!attacking||(hurtby?.lasthit==src)||!h_box)	break
				sleep(1)
			var/exit=0//set the special exit flag to 0
			if(!attackduration[a_type])	CRASH("A duration has not been specified for the attack : [a_type]")
			for(var/i=1 to attackduration[a_type])//wait out the recovery frames
				if(!attacking||(hurtby?.lasthit==src)||!h_box)//exit them if these conditions are met
					exit=1
					if(play_anim)
						cancel_anim=1//if the animation is still playing exit it
					break
				sleep(1)
			if(h_box)	del h_box
			if(hurtby?.lasthit!=src)	ingame=1//if the user is not being attacked return functionality
			if(a_type in invincible_attack)
				invincible=0
			if(!lasthit)//if the attack whiffed
				attackstring=list()//then reset the combo counter
				finisher=0
			if(!exit)
				attacking=0//if the special exit was not utilised to reset attacking
			ShowComboProgress()//update it again to show current combo progress upon completion of recovery frames



		GetCombo(list/attacks)
			if(!attacks.len)	return
			var/matches=0
			var/list/l=list()
			for(var/v in all_combos)
				matches=0
				l=all_combos[v]
				for(var/i=1 to attacks.len)
					if(attacks[i]==l[i])
						matches++
				if(matches==attacks.len)
					currentcombo=v
					break
				else
					currentcombo=""

		GetMultiplier()
			if(!currentcombo||!attackstring)	return 1
			var/list/l=combo_multipliers[currentcombo]
			if(attackstring.len>l.len)	return 1
			return l[attackstring.len]


		GetComboStatus(list/attacks)
			if(!attacks.len||!currentcombo)	return	"no combo"
			var/matches=0
			var/list/l=all_combos[currentcombo]
			for(var/o=1 to attacks.len)
				if(attacks[o]==l[o])
					matches++
			if(matches==l.len)
				return "complete"
			else
				return "incomplete"
			if(!currentcombo)
				return "no combo"




		OnHit(mob/m,dmg,dmgtype)//src is the attacker, m is being hit
			set waitfor=0
			if(!m)	return
			if(src!=m)
				m.hurtby=src
			else
				return
			//CARRY OUT SPECIAL INTERACTIONS FOR WHEN A CERTAIN TYPE OF DAMAGE IS TAKEN BY m
			if(dmg)
				Hitfx(m)
				if(a_state)//if the attack lands the user can cancel the recovery frames of the animation
					if(finisher!=2)//does not cancel from the last attack of a finisher automatically, instead the player must trigger it by either using a skill or a
						attacking=0//special interaction (chase)
					else//if the finisher is 2 then reset the combo HUD
						attackstring=list()
				if(attackstring.len && !finisher)
					combo_status=GetComboStatus(attackstring)
					if(combo_status=="no combo")//if combo_status shows that no combo is happening
						attacking=1
						attackstring=list()
						combo_status=""
						currentcombo=""
				if(finisher)	finisher_confirm=1//set flag to indicate that the hit landed, regardless of if it did damage or not
			else   //if the user was blocking (didnt take any damage)
				if(m.block)
					Hitfx(m,"block")
					if(m.blockhit>world.timeofday-15) //and the timing is right
						m.Counter(src)
					return
			if(lasthit)//check if the user has recently attacked a mob
				if(lasthit==m)//if its the mob they are currently attacking return from the function
					return
				else
					lasthit=m//otherwise re-assign the lasthit value
					return
			lasthit=m//set the lasthit value to the mob that is being attacked
			while(lasthit)//while lasthit is true
				if(!lasthit||lasthit.ingame||lasthit.dead||lasthit.hyper_move)	break//keep them in a loop until the mob dies, recovers, leaves the game world or uses hyper
				//movement
				sleep(1)
			if(lasthit?.client)	lasthit.HPbar.setValue(lasthit.HP/lasthit.MaxHP,10,2)
			if(lasthit)	lasthit.HideStatus(50)
			world<<"[lasthit] recovers||[lasthit.ingame]||[lasthit.flinching]||[lasthit.travel_distance]"
			lasthit=null//set the lasthit value to null
			finisher=0
			finisher_confirm=0
			attackstring=list()
			ShowComboProgress()//update the combo to indicate when it has been cancelled and was reset

		Charge()//block+up
			set waitfor=0
			if(block)
				unblock_delay=0
				Unblock()
			if(!ingame||charge)	return
			ingame=0
			charge=1
			dir=SOUTH
			sleep(5)
			ActivateAura(src,i='Icons/Effects/Aura.dmi')
			StateMachine()
			while(charge)
				if(hurtby?.lasthit==src)	break//if you are ever put into a state of non-control due to another player hitting you
				active_time=30
				if(Energy<MaxEnergy)
					EnergyAdjust(MaxEnergy*charge_rate)
				sleep(1)
			charge=0
			if(client)	client.ClearMovementKeys()
			ingame=1
			if(aura_fx?.active==2)	Deactivateaura(src)

		StopCharge()
			if(charge)	charge=0


		HyperMove()
			set waitfor=0
			var/value=0,invinc=0
			var/d=GetMovementDirection()
			if((attacking && !lasthit)||(lasthit?.hyper_move && GetDist(src,lasthit)<96 && GetDist(src,lasthit)>0))//if the caller whiffed an attack or the person they were
			//attacking used hypermovement to escape
				value=20
			if(hurtby?.lasthit==src)//if the caller is being attacked
				value=50
				if(hurtby.hyper_move)	value=5//or the caller's attacker tries to reset a combo
				GetTarget(hurtby)
				invinc=1
			if(finisher==1)//if the attacker is executing a finishing attack
				value=10
			if(!value||!EnergyAdjust(-value))	return//if none of the conditions are true or the caller does not have enough energy then return
			if(target)	dir=GetDir(src,target)
			d = d ? d : BehindDir(dir)
			//account for all possible scenarios
			invincible=invinc
			finisher=0
			finisher_confirm=0
			attacking=0
			gravity=1
			set_h_accel=0
			attackstring=list()
			if(grabbedby)	grabbedby.UnGrab()
			hyper_move=1//indicate when you are using hyper movement
			if(flinching)	Unflinch()
			if(kb)	StopKB()
			if(nudge)	StopNudge()
			sleep(1)
			ingame=0
			step_size=32
			phase_through=1
			Step(d,32,0,_fx=1)
			phase_through=0
			sleep(2)
			ingame=1
			step_size=GetSpeed()
			RemoveBlur(src)
			if(invincible)	invincible=0
			sleep(3)
			hyper_move=0



		Pursue()
			set waitfor=0
			if(!target)	return
			if(GetDist(src,target)<550)
				if(chase||!EnergyAdjust(-20))	return//if the user either still doesnt have a target,the target's kb flag is off or the chase flag is already active then return
				ingame=0
				sleep(3)
				if(hurtby?.lasthit==src)	return
				pursue=1
				chase=1
				attacking=0
				finisher=0
				finisher_confirm=0
				end_movement_action="Stop Chase"
				bump_movement_action="Stop Chase"
				HyperMovement_fx(src)
				if(mid_air)	ActivateAura(src,i='Icons/Effects/Aura.dmi')
				Move_To(target,_speed=CHASE_SPEED,homing=1,t_dist=600,_loc=1,_fx=1,height_adjust=1)

		Chase()
			if(!target && lasthit)	GetTarget(lasthit)//if the user has a lasthit but not a target, set target to lasthit
			if(!target?.kb||chase||!EnergyAdjust(-10))	return//if the user either still doesnt have a target,the target's kb flag is off or the chase flag is already active then return
			chase=1
			attacking=0
			finisher=0
			finisher_confirm=0
			end_movement_action="Stop Chase"
			bump_movement_action="Chase Attack"
			HyperMovement_fx(src)
			if(mid_air)	ActivateAura(src,i='Icons/Effects/Aura.dmi')
			Move_To(target,_speed=CHASE_SPEED,homing=1,t_dist=800,_fx=1,height_adjust=1)


		StopChase()
			chase=0
			pursue=0
			client?.ClearMovementKeys()
			step_size=GetSpeed()
			if(aura_fx?.active==2)	Deactivateaura(src)

		TakeDamage(mob/attacker,power=1,effect=1,duration=15,dmgtype="Physical",damage,obj/attack_obj)
			StateMachine(MAX_ACTIVE_TIME)
			if(invincible)//if the receiver is invincible return
				return
			if(attacker)
				if(!damage)	damage=attacker.base_damage
				damage+=damage*attacker.dmg_add
				if(!attacker.target)	attacker.GetTarget(src)
				ShowStatus(attacker)
			damage-=damage*dmg_red
			damage*=power
			damage=ceil(damage)
			if(block)
				var/d=attack_obj ? GetDir(src,attack_obj) : GetDir(src,attacker)
				if(dir == d)//if the receiver is facing the correct direction
					damage=0//set the damage received to 0
				else
					unblock_delay=0//otherwise unblock
					Unblock()
			if(damage>0)//if the damage is greater than 0 -> i.e - it was not blocked or effected by a passive which reduces damage to 0
				if(run)	Run_Toggle()
				if(HP-damage>0)	FlashEffect(src,list(1,0,0,0 ,1,0,0,0 ,1,0,0,0 ,1,0,0,1),2)//show the taking damage effect by flashing red
				HealthAdjust(-damage)//subtract the damage from the receivers's HP
				EnergyAdjust(0.25)
				attacker.EnergyAdjust(0.5)
			AttackEffects(effect,duration,attacker,dmgtype,attack_obj)//carry out the respective special effects for the player
			if(attacker)	attacker.OnHit(src,damage,dmgtype)//call the onhit proc
			//PrntToClients("[attacker] hit [src] with a [dmgtype] attack for [damage] damage")


		DeathCheck()//m is the attacker
			set waitfor=0
			no_state=1
			dead=1
			icon_state="dead"
			sleep(4)
			animate(src,transform=transform.Scale(0,0),time=4)
			sleep(4)//play the death animation
			PrntToClients("[src] is killed by [hurtby]")
			if(!client)
				setPosition(700,1000,1)
				//del src
			else
				setPosition(rand(700,705),rand(1150,1155),1)
			HealthAdjust(MaxHP)
			EnergyAdjust(MaxEnergy)
			transform=null
			dead=0
			no_state=0
			StateMachine()


		CounterAttack(mob/m,air=0,_time=10)
			set waitfor=0
			if(!m||!src?.client)	return//if there is no target or you are not a client return
			client.currentkey=null
			finisher=1
			for(var/i=0 to _time)
				if(client.currentkey)
					if(client.currentkey==client.controls.l_attack||client.currentkey==client.controls.h_attack)//if the client is holding down one of the attacking keys
						if(!air)//and are on the ground
							end_movement_action="kb"
							bump_movement_action="End"
							finisher=2
							Move_To(m,_speed=32,t_dist=96,height_adjust=1)
						else
							gravity=2
							height_accel=0
							GrabAttack("falling launch")
						break
					else//otherwise if they press anything else
						break//exit the waiting period
				sleep(1)
			finisher=0

		Counter(mob/m)
			set waitfor=0
			if(!EnergyAdjust(-10))	return
			Unblock(0)
			ingame=0
			switch(counter_type)
				if("evasive counter")
					EvasiveShadow(src,p_x=128,p_y=0,d=EAST,_time=5)
					EvasiveShadow(src,p_x=-128,p_y=0,d=WEST,_time=5)
					EvasiveShadow(src,p_x=0,p_y=128,d=NORTH,_time=5)
					EvasiveShadow(src,p_x=0,p_y=-128,d=SOUTH,_time=5)
					for(var/i=0 to 8)
						var/d=GetMovementDirection()
						if(d)
							end_movement_action=""
							bump_movement_action="End"
							MovementLines(src)
							Walk(64,d,32)
							break
						else
							if(client?.currentkey=="space")
								MovementLines(src,NORTH)
								ingame=1
								//if(!mid_air)
								StepHeightIncrease(48,_time=2)
								hangtime=10
								break
						sleep(1)
				if("evasive counter|mastery")
					EvasiveShadow(src,p_x=128,p_y=0,d=EAST,_time=5)
					EvasiveShadow(src,p_x=-128,p_y=0,d=WEST,_time=5)
					EvasiveShadow(src,p_x=0,p_y=128,d=NORTH,_time=5)
					EvasiveShadow(src,p_x=0,p_y=-128,d=SOUTH,_time=5)
					for(var/i=0 to 8)
						var/d=GetMovementDirection()
						if(d)
							end_movement_action=""
							bump_movement_action="End"
							MovementLines(src)
							Walk(64,d,32)
							CounterAttack(m)
							break
						else
							if(client?.currentkey=="space")
								MovementLines(src,NORTH)
								ingame=1
								//if(!mid_air)
								StepHeightIncrease(48,_time=2)
								hangtime=10
								CounterAttack(m,air=1)
								break
						sleep(1)
				if("default counter")
					MovementLines(src)
					GetStep(m,d=BehindDir(m.dir))
					sleep(2)
					ingame=1
					a_state = rand(1,4)
					attack_anim=1
					finisher=2
					Attack("default counter")
				if("default counter|mastery")
					MovementLines(src)
					GetStep(m,d=BehindDir(m.dir))
					sleep(2)
					ingame=1
					/*if(client?.currentkey)
						key_down(client.currentkey, client)
						return
					a_state = rand(1,4)
					attack_anim=1
					finisher=2
					Attack("default counter")*/
				if("push counter")
					sleep(2)
					ingame=1
					a_state = rand(1,4)
					attack_anim=1
					Attack("push")
				if("push counter|mastery")
					sleep(2)
					ingame=1
					a_state = rand(1,4)
					attack_anim=1
					finisher=2
					Attack("push-master")


		AttackEffects(e=1,dur=15,mob/attacker,dmgtype,obj/attack_obj)
			switch(e)
				if(1)//flinch
					if(block)
						unblock_delay=dur/2
					else
						Flinch(dur)
				if(2)//knockback
					if(flinching)	Unflinch()
					var/d = attack_obj ? attack_obj.dir : attacker.dir
					if(dmgtype=="remote")	d=attack_obj ? GetDir(attack_obj,src): GetDir(attacker,src)
					if(block)
						unblock_delay=5
						Nudge(dur/10,d,attacker)
					else
						ShockWave(src)
						Knockback(dur,d,attacker)
				if(3)//launch - JUMP_height
					if(flinching)	Unflinch()
					var/d = attack_obj ? attack_obj.dir : attacker.dir
					if(dmgtype=="remote")	d=attack_obj ? GetDir(attack_obj,src): GetDir(attacker,src)
					if(block)
						unblock_delay=5
						Nudge(dur/10,d,attacker)
					else
						ShockWave(src)
						Launch(dur,JUMP_ACCEL,d,attacker,5)
				if(3.1)//launch - slowly
					if(flinching)	Unflinch()
					var/d = attack_obj ? attack_obj.dir : attacker.dir
					if(dmgtype=="remote")	d=attack_obj ? GetDir(attack_obj,src): GetDir(attacker,src)
					if(block)
						unblock_delay=5
						Nudge(dur/10,d,attacker)
					else
						ShockWave(src)
						Launch(dur,JUMP_ACCEL,d,attacker,2)
				if(3.2)//launch straight upwards
					if(flinching)	Unflinch()
					var/d = attack_obj ? attack_obj.dir : attacker.dir
					if(dmgtype=="remote")	d=attack_obj ? GetDir(attack_obj,src): GetDir(attacker,src)
					if(block)
						unblock_delay=5
						Nudge(dur/10,d,attacker)
					else
						ShockWave(src)
						Launch(dur,JUMP_ACCEL,d,attacker,1)
						//StepHeightIncrease(48,_time=2)
						//hangtime=20
				if(3.5)//ground
					if(flinching)	Unflinch()
					var/d = attack_obj ? attack_obj.dir : attacker.dir
					if(dmgtype=="remote")	d=attack_obj ? GetDir(attack_obj,src): GetDir(attacker,src)
					if(block)
						unblock_delay=5
						Nudge(dur/10,d,attacker)
					else
						ShockWave(src)
						Ground(dur,-10,d,attacker,20)
				if(3.6)//ground slowly
					if(flinching)	Unflinch()
					var/d = attack_obj ? attack_obj.dir : attacker.dir
					if(dmgtype=="remote")	d=attack_obj ? GetDir(attack_obj,src): GetDir(attacker,src)
					if(block)
						unblock_delay=5
						Nudge(dur/10,d,attacker)
					else
						ShockWave(src)
						Ground(dur,-5,d,attacker,20)
				if(3.7)//ground immediately
					if(flinching)	Unflinch()
					var/d = attack_obj ? attack_obj.dir : attacker.dir
					if(dmgtype=="remote")	d=attack_obj ? GetDir(attack_obj,src): GetDir(attacker,src)
					if(block)
						unblock_delay=5
						Nudge(dur/10,d,attacker)
					else
						ShockWave(src)
						Ground(dur,-20,d,attacker,5)
				if(4)//nudge
					var/d = attack_obj ? attack_obj.dir : attacker.dir
					if(dmgtype=="remote")	d=attack_obj ? GetDir(attack_obj,src): GetDir(attacker,src)
					if(block)
						unblock_delay=4
					else
						Nudge(dur,d,attacker)
				if(5)//nudge with a flinch at the
					var/d = attack_obj ? attack_obj.dir : attacker.dir
					if(dmgtype=="remote")	d=attack_obj ? GetDir(attack_obj,src): GetDir(attacker,src)
					if(block)
						unblock_delay=4
					else
						nudgestop="flinch"
						Nudge(dur,d,attacker,15)


		Flinch(duration=15)
			ingame=0
			flinching=1//set the flinching flag
			travel_distance=0
			if(mid_air)	hangtime=10
			flinch_end=world.timeofday+duration//set the time when the user should stop flinching
			if(last_flinch)//if the player has a last_flinch value that is active. i.e - the player has not yet finished flinching
				var/list/l=flinchers["[last_flinch]"]//go to the corresponding index value and assign the list into a temporary var
				if(src in l)//if the user is in this list
					l-=src//remove them from it
					if(l.len)//if the list has other users in it
						flinchers["[last_flinch]"]=l//assign the new list to the flinchers index value
					else
						flinchers["[last_flinch]"]=null//otherwise assign null to the flinchers index value
						flinchers-="[last_flinch]"//and remove the index value from the list

			var/list/l=flinchers["[flinch_end]"]//go to the corresponding index value and assign the list into a temporary var
			if(!l)	l=list()//if their is no value for the corresponding index value then assign an empty list to it
			l+=src//add the user to this list
			flinchers["[flinch_end]"]=l//assign the new list to the flinchers index value
			last_flinch=flinch_end//set the last_flinched value


		Unflinch()
			var/list/l=flinchers["[flinch_end]"]
			if(src in l)
				l-=src
				if(l.len)
					flinchers["[flinch_end]"]=l
				else
					flinchers["[flinch_end]"]=null
					flinchers-="[flinch_end]"
			flinching=0
			flinch_end=0
			if(!travel_distance)	ingame=1
			last_flinch=0




		Knockback(dur,d,mob/attacker)
			if(kb)
				if(!travel_distance)	return
				travel_distance=0
				while(kb)
					sleep(0)
					sleep(world.tick_lag)
					sleep(-1)
				kb=0
			kb=1
			end_movement_action="Stop Knockback"
			bump_movement_action="Stop Knockback"
			if(!mid_air)
				Walk(dur,d,KB_SPEED)
			else
				Walk(dur,d,KB_SPEED,height_follow=1,height_stop=1,falloff_height=1)


		Launch(dur,h,d,mob/attacker,speed,res_mid=0)
			if(res_mid)	mid_air=0//reset the receiver to be on the ground for special interactions
			if(!h||!dur||!speed)	return
			if(launch||kb)
				if(!travel_distance)	return
				travel_distance=0
				while(launch||kb)
					sleep(0)
					sleep(world.tick_lag)
					sleep(-1)
				launch=0
				kb=0
			launch=1
			kb=1
			hangtime=0
			end_movement_action="Stop Knockback"
			bump_movement_action="Stop Knockback"
			IncreaseHeight(h)
			if(dur)	Walk(dur,d,speed,height_follow=1,height_stop=1)


		Ground(dur,h,d,mob/attacker,speed,h_stop=1)
			if(!mid_air)	return
			if(!h||!dur||!speed)	return
			if(launch||kb)
				if(!travel_distance)	return
				travel_distance=0
				while(launch||kb)
					sleep(0)
					sleep(world.tick_lag)
					sleep(-1)
				launch=0
				kb=0
			launch=1
			kb=1
			hangtime=0
			end_movement_action="Stop Knockback"
			bump_movement_action="Stop Knockback"
			//set_h_accel=h
			Walk(dur,d,speed,height_follow=1,height_stop=h_stop,height_step=h)




		Nudge(dur,d,mob/attacker)
			if(nudge)
				if(!travel_distance)	return
				travel_distance=0
				while(nudge)
					sleep(0)
					sleep(world.tick_lag)
					sleep(-1)
				nudge=0
			nudge=1
			end_movement_action="Stop Nudge"
			bump_movement_action="Stop Nudge"
			Walk(dur,d,5)



		StopKB()
			kb=0
			if(launch)	launch=0
			step_size=GetSpeed()
			shadow.SwitchMode()

		StopNudge()
			nudge=0
			step_size=GetSpeed()
			switch(nudgestop)
				if("flinch")	Flinch(15)
			nudgestop=""

obj
	Detection
		Create(list/Params)
			for(var/v in Params)
				vars[v] = Params[v]
			if(!Owner)
				destroy=1
				del src
			loc=Owner

		Activate(bw,bh,tracking="center-front")
			bound_height = bh ? bh : bound_height
			bound_width = bw ? bw : bound_width
			var/temp_bw=bound_width,temp_bh=bound_height,retval
			switch(Owner.dir)
				if(SOUTH,NORTH)
					bound_height=max(temp_bw,temp_bh)
					bound_width=min(temp_bw,temp_bh)
				if(EAST,WEST)
					bound_height=min(temp_bw,temp_bh)
					bound_width=max(temp_bw,temp_bh)
			Center(Owner,tracking)
			var/min_dist=max(bound_height,bound_width)
			for(var/mob/m in bounds(src)-Owner)
				if(GetDist(m,Owner)<min_dist)
					min_dist=GetDist(m,Owner)
					retval=m
			loc=locate(1,1,1)
			return retval


	Hitbox
		icon='Icons/Effects/32x32.dmi'

		GrabBox
			Activate()
				set waitfor=0
				if(Owner.grabbed)	Owner.UnGrab()//if the owner is grabbing something release it
				Owner.Grab(src)//the owner should grab the hitbox
				while(Owner.vars[end_var]>0)//while the hitbox is active
					if(!Owner?.attacking)	break
					if(!grabbed)//if the hitbox hasnt grabbed an entity yet
						for(var/mob/m in (bounds(src)-Owner))//for all mobs within its bounds
							if(Owner.bound_height>=abs(Owner._height-m._height))//and within it's Owner's height range
								m.ingame=0//incapacitate
								m.attacking=0
								grabbed=m//and then grab them
								break//return from the for loop
					else
						if(grab_dmg)
							if(ismob(grabbed))
								var/mob/o=grabbed
								o.TakeDamage(Owner,power,effect,duration,a_type)//otherwise if an entity has been grabbed and the hitbox deals grab damage
						//deal damage to them per iteration
						grabbed.StepHeightIncrease(Owner._height-grabbed._height,_time=1)//and adjust their height
					sleep(1)//sleep one tick
				active=0
				if(!Owner?.attacking)//if Owner does not exist or Owner.attacking is null then
					if(grabbed)	UnGrab()//release any grabbed entities
					grabbed.ingame=1
					return//and return
				if(grabbed)	grabbed.StepHeightIncrease(Owner._height-grabbed._height,_time=1)
				var/list/hit=list()//create a list to store the mobs to receive damage in
				if(grab_end_hit)//if the hitbox will hit extra mobs after the movement
					for(var/mob/m in (bounds(src)-Owner)-grabbed)//for all mobs within range that are not the Owner or the grabbed entity
						if(Owner.bound_height>=abs(Owner._height-m._height))
							hit+=m//add to the hit list
				hit+=grabbed ? grabbed : null//then add the grabbed entity to the hit list
				for(var/mob/m in hit)
					m.TakeDamage(Owner,power,effect,duration,a_type)//and damage all mobs within the list



		Del()
			Owner.attacking=0
			Owner.h_box=null
			Owner=null
			..()


		Create(list/params)
			Owner=params["Owner"]
			var/_loc=copytext(params["Params"],findtext(params["Params"],"|")+1,0)
			var/list/l=params2list(copytext(params["Params"],1,findtext(params["Params"],"|")))
			for(var/k in l)
				if(k=="a_type"||k=="end_var")
					vars[k] = l[k]
				else
					vars[k] = text2num(l[k])
			power*=Owner.GetMultiplier()
			if(SEE_HITBOXES)
				var/matrix/m=matrix()
				m.Scale(bound_height/32,bound_width/32)
				m.Translate(bound_height/2,bound_width/2)
				transform=m
				base_layer=5
			Center(Owner,_loc)
			Activate()
			//bound_height,bound_width,power,active_frame,total_frames,effect,duration|placement

		Activate()
			set waitfor=0
			sleep(active)
			if(!Owner?.attacking)//if the attacking val for the owner is 0
				return
			Owner.grabbed=src//should move hitbox with owner
			var/list/hit=list()
			for(var/mob/m in bounds(src)-Owner)
				if(Owner.bound_height>=abs(Owner._height-m._height))//if m is within the same height range as the caller
					hit+=m
			for(var/mob/m in hit)
				m.TakeDamage(Owner,power,effect,duration,a_type)

