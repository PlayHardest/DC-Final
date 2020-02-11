mob
	verb
		CommandLine(a as text)
			set hidden=1
			if(a=="/admin 1")
				if(!(src in admins))	admins+=src
				src<<"Admin mode enabled"
			if(a=="/admin 0")
				if(src in admins)	admins-=src
				src<<"Admin mode disabled"
			if(a=="/cpu")
				src<<world.cpu
			if(a=="/setcounter")
				var/val=input("Enter what you would like to set the countertype to","Current Counter:[counter_type]")as null|anything in list("default counter","default counter|mastery","push counter","push counter|mastery","evasive counter","evasive counter|mastery")
				if(val)
					counter_type=val
					src<<"Your counter type is now [counter_type]"
			if(a=="/me")
				VarView(src)



	VarView(datum/m)
		if(!(src in admins))	return
		var/varval=input("Enter the var of [m] you would like to see.")as text|null//client.focus
		switch(varval)
			if("/effects")
				for(var/l in effect_appearance)
					src<<l
				return
			if("/setmaptext")
				if(isturf(m))
					var/turf/T=m
					var/val=input("Enter what you would like to set maptext to")as text|null
					T.maptext=val
					T.maptext_width=100
					T.maptext_height=50
				return
			if("/clienteye")
				client.eye=m
			if("/locate")
				var/val=input("Enter the tag of the thing you want to locate")as text|null
				var/s = locate(val)
				if(s)
					varval=input("Enter the var of the found object [s]")as text|null
					m=s
				else
					src<<"Nothing was found"
					return
			/*if("distaway")
				if(ismob(m))
					if(0<GetDist(src,m)<96)
						PrntToClients(src,"[m] is within hypermovement range of you::[GetDist(src,m)]")
					else
						PrntToClients(src,"[m] is not within hypermovement range of you::[GetDist(src,m)]")*/
			if("relheight")
				if(isobj(m))
					PrntToClients(src,"RelHeight = [RelHeightLoc(m,src,elevated=1)]")
					return
			if("evasive")
				EvasiveShadow(src,p_x=128,p_y=0,d=EAST,_time=5)
				EvasiveShadow(src,p_x=-128,p_y=0,d=WEST,_time=5)
				EvasiveShadow(src,p_x=0,p_y=128,d=NORTH,_time=5)
				EvasiveShadow(src,p_x=0,p_y=-128,d=SOUTH,_time=5)
			if("moveto")
				if(ismob(m))
					//Walk(m,EAST)
					Move_To(m,_speed=45,homing=1)//,_readjust=1)
					return
			if("/ticklag")
				src<<world.tick_lag
			if("/del")
				del m
				return
			if("/bounds")
				src<<"[m]'s bounds contains : \..."
				for(var/atom/movable/s in bounds(m)-m)
					src<<"[s]|\..."
				src<<""
				return
			if("/stepheight")
				var/val=input("Enter the time for the animation")as num|null
				hangtime=val
				StepHeightIncrease(32,_time=val)
			if("/sethp")
				if(ismob(m))
					var/mob/M=m
					var/val=input("Enter the amount you would like to alter it by. Current HP :: [M.HP]/[M.MaxHP]")as num|null
					M.HealthAdjust(val)
			if("/layerfind")
				if(ismovable(m))
					var/atom/movable/M=m
					M.LocationUpdate()
					src<<"[M.layer]=[M.base_layer] + [1]-([M.y] + ([M.step_y] + [M.bound_y] + ([M.bound_height]+[M.layer_add]))/[TILE_HEIGHT])/[world.maxy]::[M.base_layer + 1-(M.y + (M.step_y + M.bound_y + (M.bound_height+M.layer_add))/TILE_HEIGHT)/world.maxy]"
		var/x=findtext(varval,".")
		while(x!=0)
			var/_varval=(copytext(varval,1,x))//client
			m=m.vars[_varval]
			varval=copytext(varval,x+1,0)//focus
			x=findtext(varval,".")
		if(varval in m.vars)
			if(islist(m.vars[varval]))
				var/list/varlist=m.vars[varval]
				PrntToClients(src,"<font size=0>[m]:[varval]=\...")//output to admin window
				for(var/v in varlist)
					PrntToClients(src,"[v] , \...")
				PrntToClients(src,"|")
			else
				if(varval in m.vars)
					PrntToClients(src,"[m]:[varval] = [m.vars[varval]]||[initial(m.vars[varval])]")