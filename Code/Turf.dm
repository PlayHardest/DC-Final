turf
	icon='Icons/Map/Turf.dmi'

	Grass
		icon='Icons/Map/Turf.dmi'
		icon_state="grass1"

		New()
			..()
			icon_state=pick("grass","grass1","grass2","grass3","grass4")
