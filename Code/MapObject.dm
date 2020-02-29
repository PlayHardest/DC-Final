obj
	MapObject
		Cliff
			icon='Icons/Map/Cliff.dmi'

		CliffTop
			icon='Icons/Map/Turf.dmi'
			icon_state="grass"

			New()
				..()
				icon_state=pick("grass","grass1","grass2","grass3","grass4")
