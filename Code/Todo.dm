/*
Counters
	-(DONE)default: teleport behind and counterattack
	-(DONE)default|mastery: teleport behind with the ability to counterattack or cancel into any other action
	-(DONE)push: push away those directly in front of you (no animation cancel available, long recovery frames, cannot be followed up on)
	-(DONE)push|mastery: push away those directly in front of you, cancelling the animation on contact with an enemy, can be followed up on
	-(DONE)evasive: dodge away in any cardinal direction + the air
	-(DONE)evasive|mastery: dodge away in any cardinal direction + the air while having the ability to cancel the dodge into an attack (cancelling the dodge into the air into an attack will trigger an attack which launches all opponents hit, any other direction will knock away the enemy, not combo-able)

Combo Extension
	-(DONE)Hyper movement: allows players to relocate their character during certain interactions for varying costs:
						- the player is performing a finishing combo and has yet to reach the final attack of the combo (costs 10 energy)
						- the player has completely missed a melee attack and is currently in the recovery frames of said attack (costs 20 energy)
						- the player is in any movement locked state due to a direct influence of another entity (i.e - flinch, knockback, etc.) (costs 50 energy)

	-(DONE)Chase: press space after knocking an enemy back to pursue them.


General
	-Update Flinching system to be a borrowed time system( like StateMachine)
	-Save System
	-Inventory System (list--> most items will be displayed in text form)
	-Skills will be displayed same way as before
	-(DONE)Remove as much mouse usage as possible
	-(DONE)Create an intuitive way to target enemies (always start from the last person you attacked, then the last one to attack you and then move on from there)
	-(DONE)Create boundaries

UI
	-Combo counter with damage info (like in budokai 3)

	Options Menu
		-(DONE)Screen will darken and menu options will slide from the left to the right
		-(DONE)Selected option will move to the top center of the screen, other options will recede offscreen to the left and then content for selected option will fade in
		-(DONE)Options will slide forward to the right slightly when active

Bugs
	-(FIXED)Bring to ground when you respawn
	-(FIXED)Players pressing enter interrupts other players' typing serverwide
	-(DONE)Implement key repeats for typing
	-(DONE)Change map to grass
	-(DONE)Improve the homing speed of the initial light/heavy attack

Combat
	-Create a combo limit where when reached the person being combo'd will be able to hyper_move out for no cost
	-Make skills not contribute towards this limit
	-Make repeating buttons add to this limit incrementally(e.g. - first Z combo adds 10, second Z combo adds 18), to give incentive to use the other combos
	-Make certain interactions decrease or freeze the combo limit for a set amount of time
	-Add the fall/knocked down state

Focus
	-mechanic to handle transformation effectiveness and buff/debuff balance
	-If knockback when focus is empty then the user will revert
	-Taking damage will reduce the user's focus value
	-When focus is less than 20% then energy will start to drain to alert user
	-The focus value will recover after the user ki charges for 5 seconds
*/

