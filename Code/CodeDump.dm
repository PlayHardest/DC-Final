			/*if(m.attacking && m.dir==GetDir(m,src) && m.h_box)
					clash+=m
				else*/
				hit+=m
			/*for(var/obj/Hitbox/h in obounds(src))
				if(h.Owner.dir==GetDir(h.Owner,src))
					clash+=h.Owner
			for(var/mob/m in clash)
				if(m.attacking==Owner.attacking)
					//Push both away
				if(m.attacking>Owner.attacking)//cancel the attack of the mob which has lower priority
					Owner.Flinch(10)
					Owner.attacking=0
					return
				else
					m.Flinch(10)
					m.attacking=0
					hit+=m*/
			for(var/mob/m in hit)
				world<<"[m] will be hit"
				if(m==Owner)	continue
				m.TakeDamage(Owner,power,effect,duration,a_type)



