var
	list
		admins=list()
		color_matrices=list("green"=list(0.24,0,0,0,0, 0,0.54,0,0,0, 0,0,0.28,0,0, 0,0,0,1,0),
							"orange yellow"=list(1,0,0,0,0, 0,0.68,0,0,0, 0,0,0.2,0,0, 0,0,0,1,0),
							"red"=list(0.89,0,0,0,0, 0,0.23,0,0,0, 0,0,0.27,0,0, 0,0,0,1,0)
							)
		//"" -- green
			//"" -- yellow/orange
			//"" -- pinkish red

		max_menu_value=list("main"=4)
		min_menu_value=list("main"=1)

		kiattackstates=list("ki blast"="kiblast","kiknockback"="finalflashfire")
		kistatestart=list("kiblast1"=3,"kiblast2"=3)
		kiattackcost=list("ki blast"=-2,"kiknockback"=-5)

		kia_states=list("kiblast")

		trailbars=list("health")
		attackstates=list("puncha","punchb","kicka","kickb")
		animation_states=list("puncha"=3,"punchb"=3,"kicka"=3,"kickb"=3)
		animation_speed=list("puncha"=1,"punchb"=1,"kicka"=1,"kickb"=1)

		all_combos=list("basic light"=list("light","light","light","light"),
						"basic heavy"=list("heavy","heavy","heavy","heavy"),
						"basic launch"=list("light","light","heavy","heavy"),
						"basic kiblast"=list("ki blast","ki blast","ki blast","ki blast")
						)

		menu_hierarchy=list("main"="","inventory"="main","character"="main","skills"="main","-"="main")
		menu_hierarchy_id=list("main"="","inventory"="main-2","character"="main-1","skills"="main-3","-"="main-4")
		//each button will know what screen it will point to and make load individually, however the preceeding menu will be stored here

		all_finishers=list("basic light"=list("default light"),
						   "basic heavy"=list("default heavy"),
						   "basic launch"=list("default launch"),
						   "basic kiblast"=list("default ki blast")
						   )

		combo_multipliers=list("basic light"=list(0.7,0.6,0.9,1),
							   "basic heavy"=list(1,0.8,1,1.2),
							   "basic launch"=list(0.7,0.6,0.8,0.8),
							   "basic kiblast"=list(0.3,0.3,0.3,0.5)
							  )

		invincible_attack=list("push","push-master","default counter","falling launch")

		attackduration=list("ki blast"=10,"kiknockback"=12,"light"=8,"heavy"=10,"launch"=10,"ground"=10,"kb"=10,"nudge"=9,"soft nudge"=9,"hard nudge"=9,"stun nudge"=9,"chaseatk"=15,"push"=10,"default counter"=10,
							"push-master"=10,"falling launch"=4)

		can_combo=list("light","heavy","ki blast")


		attack_info=list("light"="bound_height=20&bound_width=20&power=0.9&active=2&effect=1&duration=8&a_type=Physical|center-front",
						"heavy"="bound_height=20&bound_width=20&power=1&active=2&effect=1&duration=12&a_type=Physical|center-front",
						"launch"="bound_height=20&bound_width=20&power=0.9&active=2&effect=3&duration=2&a_type=Physical|center-front",
						"falling launch"="bound_height=64&bound_width=64&power=2&active=1&effect=3.5&duration=2&end_var=mid_air&grab_end_hit=1&a_type=Physical|center",
						"ground"="bound_height=20&bound_width=20&power=0.9&active=2&effect=3.5&duration=2&a_type=Physical|center-front",
						"kb"="bound_height=20&bound_width=20&power=1.2&active=2&effect=2&duration=300&a_type=Physical|center-front",
						"heavy kb"="bound_height=20&bound_width=20&power=1.5&active=2&effect=2.5&duration=350&a_type=Physical|center-front",
						"nudge"="bound_height=20&bound_width=20&power=0.7&active=3&effect=4&duration=15&a_type=Physical|center-front",
						"soft nudge"="bound_height=20&bound_width=20&power=0.7&active=3&effect=4&duration=10&a_type=Physical|center-front",
						"hard nudge"="bound_height=20&bound_width=20&power=0.7&active=3&effect=4&duration=25&a_type=Physical|center-front",
						"stun nudge"="bound_height=20&bound_width=20&power=0.7&active=3&effect=5&duration=20&a_type=Physical|center-front",
						"chaseatk"="bound_height=32&bound_width=32&power=0.1&active=1&effect=4&duration=10&a_type=Physical|center-front",
						"push"="bound_height=20&bound_width=20&power=0.01&active=2&effect=2&duration=100&a_type=Physical|center-front",
						"push-master"="bound_height=20&bound_width=20&power=0.01&active=1&effect=2&duration=150&a_type=Physical|center-front",
						"default counter"="bound_height=20&bound_width=20&power=1.2&active=3&effect=2&duration=300&a_type=Physical|center-front",
						)
						/*effects:
							1-flinch
							2-knockback
							2.5-heavy knockback(the receiver does not auto recover from this and instead lands on their face)
							3-launch
							3.1-launch slowly
							3.2-launch straight upwards
							3.5-ground
							3.6-ground slowly
							3.7-ground straight down
							4-nudge
							5-nudge stun

						for new attacks dont forget to set duration and priority. And that follow up attacks are only possible for finisher attacks
						*/
						//bound_height,bound_width,power,active,effect,duration,a_type|placement

		attack_priority=list("light"=1,"heavy"=2,"launch"=2,"kb"=3,"heavy kb"=3,"nudge"=3,"soft nudge"=3,"hard nudge"=3,"stun nudge"=3,"chaseatk"=2,"push"=10,
							 "push-master"=10,"default counter"=3,"falling launch"=3,"ground"=2)

		flinchers=list()


obj
	var

		tmp
			end_var=""
			a_type=""
			base_state=""
			orientation
			grab_dmg=0
			grab_end_hit=0
			//trail_bar=0

client
	var
		tmp
			list
				menu=list()

			menu_view=0
			menu_active=1
			menu_category="main"

			obj/menu_focus
			hudobj/fullscreen

mob
	Del()
		hurtby=null
		lasthit=null
		target=null
		del h_box
		del HUDframe
		del combotrack
		del HPbar
		del Kibar
		del DisplayHPbar
		del DisplayKibar
		del DisplayFrame
		del aura_fx
		del flash_fx
		del detect_range
		del active_proj
		vis_contents=list()
		..()


	var
		tmp
			list
				attackstring=list()//check the string of attacks that have been carried out
				viewingstats=list()

			image/DisplayHPbar
			image/DisplayKibar
			image/DisplayFrame
			image/Target
			image/targ_image

			mob/hurtby
			mob/lasthit
			mob/target

			obj/detect_range
			obj/active_proj
			obj/h_box
			obj/HudobjHelper/AMaskBar/HPbar
			obj/HudobjHelper/AMaskBar/Kibar

			hudobj/HUDframe
			hudobj/combotrack

			visual_fx/flash_fx
			visual_fx/aura_fx

			fly=0
			showingstatus=0
			last_run_time=0
			boost_drain_delay=10
			charge=0
			charge_rate=0.02


			launch=0
			nudgestop
			chase=0
			nudge=0
			finisher=0
			finisher_confirm=0
			combo_status
			currentcombo//check which combo has been carried out
			blockhit=0
			invincible=0
			dead=0
			kb=0
			colorval=null
			block=0
			unblock_delay=0
			attacking=0
			a_state=0
			attack_anim=0
			combo_state=0
			flinching=0
			flinch_end=0
			last_flinch=0
			hyper_move=0
			pursue=0

			dmg_add=0
			dmg_red=0
			speed_add=0
			speed_red=0



		list
			combos=list()//list of all owned combos

		HP=300
		MaxHP=300
		Energy=150
		MaxEnergy=150
		base_damage=10
		light_combo="default light"
		heavy_combo="default heavy"
		launch_combo="default launch"
		kiblast_combo="default ki blast"
		kiblast_type="ki blast"
		counter_type="default counter"