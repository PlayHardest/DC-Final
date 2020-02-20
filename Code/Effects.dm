visual_fx
	Flash
		active=1
		//vis_flags=VIS_INHERIT_ICON|VIS_INHERIT_ICON_STATE|VIS_INHERIT_DIR//|VIS_UNDERLAY
		plane=FLOAT_PLANE+1
		varname="flash_fx"

	Aura
		active=1
		vis_flags=VIS_INHERIT_ICON_STATE|VIS_INHERIT_DIR
		layer=MOB_LAYER+2
		pixel_x=-33
		pixel_y=-31


	Jump_fx
		icon='Icons/Effects/JumpEffect.dmi'
		flickstate="lift off2"
		pixel_x=-48
		pixel_y=-27

	HyperMovement
		icon='Icons/Effects/JumpEffect.dmi'
		flickstate="hypermovement"
		pixel_x=-48
		pixel_y=-27

	size96x96
		icon='Icons/Effects/96x96.dmi'
		flickstate="wave"
		pixel_x=-31
		pixel_y=-35

proc
	ActivateAura(mob/m,i='Icons/Effects/Aura.dmi')
		if(!m || !i)	return
		if(!m.aura_fx)
			m.aura_fx=Recycle(/visual_fx/Aura)//,lease=6000)
			m.aura_fx.Owner=m
		m.aura_fx.icon=i
		if(!(m.aura_fx in m.vis_contents))
			m.vis_contents+=m.aura_fx
		m.aura_fx.active=2


	Deactivateaura(mob/m)
		if(!m||!m.aura_fx)	return
		m.vis_contents-=m.aura_fx
		m.aura_fx.active=1

	Jump_fx(mob/m)
		set waitfor=0
		if(!m)	return
		var/visual_fx/I=Recycle(/visual_fx/Jump_fx)
		I.setPosition(m)
		I.layer=m.layer
		flick(I.flickstate,I)
		sleep(10)
		Recycle(e=I)

	EvasiveShadow(mob/m,p_x=0,p_y=0,d,_time=10)
		set waitfor=0
		if(!m)	return
		var/visual_fx/I=Recycle(/visual_fx/AfterImage)
		var/mutable_appearance/m_a=new(m)
		m_a.color=list(0.3,0.3,0.3, 0.59,0.59,0.59, 0.11,0.11,0.11, 0,0,0)
		//m_a.alpha=100
		m_a.dir = d ? d : I.dir
		m_a.icon_state="dash"
		I.appearance=m_a
		I.setPosition(m)
		animate(I,pixel_x=I.pixel_x+p_x,pixel_y=I.pixel_y+p_y,alpha=0,time=_time)
		sleep(_time)
		Recycle(e=I)


	HyperMovement_fx(mob/m)
		set waitfor=0
		if(!m)	return
		var/visual_fx/I=Recycle(/visual_fx/HyperMovement)
		I.setPosition(m)
		I.dir=m.dir
		I.layer=m.layer
		flick(I.flickstate,I)
		sleep(5)
		Recycle(e=I)

	MovementLines(mob/m,d)
		set waitfor=0
		if(!m)	return
		var/visual_fx/I=Recycle(/visual_fx/size96x96)
		I.flickstate="movement"
		I.setPosition(m)
		I.dir=d ? d : m.dir
		I.layer=m.layer
		flick(I.flickstate,I)
		sleep(2)
		Recycle(e=I)

	ShockWave(mob/m,t=3)
		set waitfor=0
		if(!m)	return
		var/visual_fx/I=Recycle(/visual_fx/size96x96)
		I.icon_state="waves"
		I.pixel_x=-32
		I.pixel_y=-35
		var/matrix/M=matrix()
		M.Scale(0)
		I.transform=M
		I.setPosition(m)
		animate(I,transform=matrix()*3,time=t)
		animate(alpha=0,time=t+2,flags=ANIMATION_PARALLEL)
		sleep(t+2)
		Recycle(e=I)

	SpeedWave_fx(mob/m)
		set waitfor=0
		if(!m)	return
		var/visual_fx/I=Recycle(/visual_fx/size96x96)
		I.flickstate="wave"
		I.setPosition(m)
		I.dir=m.dir
		I.layer=m.layer
		flick(I.flickstate,I)
		sleep(5)
		Recycle(e=I)


	FlashEffect(mob/m,_color,time=1)
		set waitfor=0
		if(!m||!_color)	return
		if(!m.flash_fx)
			m.flash_fx=Recycle(/visual_fx/Flash)//,lease=6000)
			m.flash_fx.render_source=m.render_target
			m.flash_fx.Owner=m
		m.flash_fx.color=_color
		if(!(m.flash_fx in m.vis_contents))
			m.vis_contents+=m.flash_fx
		m.flash_fx.active=2
		sleep(time)
		if(m?.flash_fx)
			m.flash_fx.active=1
			m.flash_fx.color=null
			m.vis_contents-=m.flash_fx


