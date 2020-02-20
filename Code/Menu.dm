client
	proc
		MenuKey(k)
			if(!k)	return
			if(k=="escape")	CloseMenu()

		OpenMenu()
			set waitfor=0
			lock_input()
			menu_view=1
			fullscreen.show()
			fullscreen.fade(150,10)
			menu["0"].show()
			for(var/i=1 to 4)
				animate(menu["[i]"],pixel_x=-view_width*32,time=0)
			for(var/i=1 to 4)
				animate(menu["[i]"],pixel_x=0,time=10,easing=BACK_EASING)
				sleep(2)
			unlock_input()


		CloseMenu()
			set waitfor=0
			lock_input()
			for(var/i=1 to 4)
				animate(menu["[i]"],pixel_x=-view_width*32,time=5,easing=BACK_EASING)
				sleep(1)
			sleep(5)
			menu["0"].hide()
			fullscreen.fade(0,10)
			sleep(10)
			fullscreen.hide()
			menu_view=0
			unlock_input()