obj
	MapObject
		Cliff
			icon='Icons/Map/Cliff.dmi'
			edge_replace=list("Cliff Bottom Left","Cliff Bottom Middle","Cliff Bottom Right")
			edge_state="block"
			cast_replace=list("Cliff Top Right","Cliff Top Middle","Cliff Top Left")

		CliffTop
			icon='Icons/Map/Turf.dmi'
			icon_state="grass"

			New()
				..()
				icon_state=pick("grass","grass1","grass2","grass3","grass4")

		//New()
		//	..()
		//	if(cast_replace && findtext(cast_replace,icon_state))
		//		cast_state="[cast_replace]-[icon_state]"
