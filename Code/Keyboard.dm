Controls
	var
		l_attack=K_ATTACK1
		h_attack=K_ATTACK2
		ki_blast=K_BLAST
		block=K_BLOCK
		menu=K_ESC


mob
	key_down(k, client/c)
		StateMachine()
		c.currentkey=k
		if(c?.menu_view)
			c.MenuKey(k)
			return
		if(k==c.controls.menu)
			c.OpenMenu()
		if(c?.active_textbox)
			c.keyinput(k)
			return
		if(finisher==1 || attacking && !lasthit || hurtby?.lasthit==src || lasthit?.hyper_move)
			if(k==c.controls.jump)	HyperMove()
			return
		if(finisher)
			if(finisher==2)
				if(k==c.controls.jump)
					if(target?.kb||lasthit?.kb)
						Chase()
			return
		if(k==c.controls.jump && chase)
			travel_distance=0
			return
		if(c.keys["alt"])
			if(k=="return")
				src<< output(null,"browser1:ToggleFullscreen")
			else if(k=="1")
				winshow(c,"adminoutputpanel",1)
			else if(k=="2")
				winshow(c,"controls",1)
		if(k=="return")
			if(!c.active_textbox)
				c.textbox.Activate()
		if(!directional_keys.len)
			KeyDir()
		//if(!hotkeys_keys.len)
		//	hotkeys_keys=list(client.controls.skill1,client.controls.skill2,client.controls.skill3,client.controls.skill4,client.controls.skill5,client.controls.skill6,client.controls.skill7,client.controls.skill8)
		if(dead)	return
		if(k==c.lastpressed)
			if(k in directional_keys)
				if(ingame)
					Run_Toggle()
		if(ingame)
			if(k==c.controls.jump && !attacking && !chase && !travel_distance)
				Jump()
			if(k==c.controls.block)
				Block()
			if(k==c.controls.ki_blast)
				KiBlast(kiblast_type)
			if(k==c.controls.l_attack)
				GenAttack("light")
			if(k==c.controls.h_attack)
				GenAttack("heavy")
			if(k in directional_keys)
				MoveLoop()
			//if(k=="v")
			//	Pursue()
		else
			if(k==c.controls.up)
				if(c.keys["[c.controls.block]"])
					Charge()
		if(k=="u")
			UnTarget()
		if(c.lastpressed)
			c.lastpressed=null


	key_up(k, client/c)
		StateMachine()
		c.currentkey=null
		if(finisher||dead)	return
		if(k==c.controls.block && block)
			Unblock()
		if(charge)
			if(k==c.controls.block||k==c.controls.up)
				StopCharge()
		//if(ingame)
		if(k in directional_keys)
			var/stillrun=0
			for(var/s in directional_keys)
				if(client.keys[s])
					stillrun=1
					break
			if(run && !stillrun)
				Run_Toggle()
		c.lastpressed=k
		KeyTimeout(k)