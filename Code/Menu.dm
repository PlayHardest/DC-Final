client
	proc
		MenuKey(k)
			if(!k)	return
			if(k=="escape")	MenuReturn()
			if(k=="north")	ChangeActive(-1)
			if(k=="south")	ChangeActive(1)
			if(k=="return")	ActiveSelect()
			//if(k=="east")
			//if(k=="west")

		ActiveSelect()
			if(!menu_focus)	return
			lock_input()
			switch(menu_category)
				if("main")
					OptionMove(menu_focus.id,new_x=-view_width*32,t=3,_easing=BACK_EASING)//move all menu options off screen except the active one
					OptionMove(new_x=0,new_y=75,t=2,delay=0,range_start=menu_active,range_end=menu_active)//move only the selected option to the top of the screen
					sleep(10)
					menu_category=menu_focus.active//set the new category to what the focused option was pointing to
					//here is when you would populate the screen with the new menu info
			unlock_input()


		ChangeActive(change)
			menu_active = menu_active+change
			menu_active = menu_active > max_menu_value[menu_category] ? min_menu_value[menu_category] : (menu_active<min_menu_value[menu_category] ? max_menu_value[menu_category] : menu_active)
			if(!menu["[menu_category]-[menu_active]"])
				menu_active=1
				return
			menu_focus=menu["[menu_category]-[menu_active]"]
			switch(menu_category)
				if("main")
					OptionMove(new_x=0,t=3,delay=0,is="option")//move all options to neutral position
					OptionMove(new_x=32,t=3,delay=0,is="option-select",range_start=menu_active,range_end=menu_active)//move only the selected option to the active position

		OpenMenu(m_a=1)
			set waitfor=0
			lock_input()
			menu_view=1
			menu_active=m_a
			fullscreen.show()
			fullscreen.fade(150,10)
			menu["0"].show()
			OptionMove(new_x=-view_width*32,t=0,delay=0)
			OptionMove(new_x=0,t=10,delay=2,_easing=BACK_EASING)
			sleep(10)
			ChangeActive(0)
			unlock_input()

		MenuReturn()
			CloseCurrent()//close the currently open category's menu


		OptionMove(exception,new_x=-1#INF,new_y=-1#INF,t=5,delay=1,_easing=LINEAR_EASING,is,range_start=1,range_end=4)
			set waitfor=0
			for(var/i=range_start to range_end)
				if(i==exception)	continue
				//world<<"[menu["[menu_category]-[i]"]] is being moved"
				if(menu["[menu_category]-[i]"])
					if(is)	menu["[menu_category]-[i]"].icon_state=is
					if(new_x != -1#INF)	animate(menu["[menu_category]-[i]"],pixel_x=new_x,time=t,easing=_easing)
					if(new_y != -1#INF)	animate(menu["[menu_category]-[i]"],pixel_y=new_y,time=t,easing=_easing,flags=ANIMATION_PARALLEL)
					if(delay)	sleep(delay)
				else
					world<<"[menu["[menu_category]-[i]"]] does not exist at [menu_category]-[i] of menu list"

				//Cheesy pants (/client): OptionMove(1, -992, -1.#INF, 5, 1, 6, null, 1, 4)

		CloseCurrent()
			switch(menu_category)
				if("main")//if its the top level menu
					CloseMenu()//then close it
				if("-","inventory","skills","character")
					//get rid of the specific menu option content here
					lock_input()
					menu_focus=menu[menu_hierarchy_id[menu_category]]//find the title menu option
					menu_active=menu_focus.id
					if(menu_hierarchy[menu_category])	menu_category=menu_hierarchy[menu_category]
					OptionMove(new_y=-70*menu_focus.id,t=2,delay=0,range_start=menu_active,range_end=menu_active)//move the title menu option back to where it should be
					OptionMove(menu_active,new_x=0,t=5,delay=2,_easing=BACK_EASING)//move all of the other options back into place to create the main menu again
					unlock_input()

		CloseMenu()
			set waitfor=0
			lock_input()
			OptionMove(new_x=-view_width*32,_easing=BACK_EASING)
			sleep(5)
			menu["0"].hide()
			fullscreen.fade(0,10)
			sleep(10)
			fullscreen.hide()
			menu_view=0
			unlock_input()