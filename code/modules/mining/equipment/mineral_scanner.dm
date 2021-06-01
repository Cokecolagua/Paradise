/**********************Mining Scanner**********************/
/obj/item/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results."
	name = "manual mining scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "mining1"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 35
	var/current_cooldown = 0

	origin_tech = "engineering=1;magnets=1"

/obj/item/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		mineral_scan_pulse(get_turf(user))


//Debug item to identify all ore spread quickly
/obj/item/mining_scanner/admin

/obj/item/mining_scanner/admin/attack_self(mob/user)
	for(var/turf/simulated/mineral/M in world)
		if(M.scan_state)
			M.icon_state = M.scan_state
	qdel(src)

/obj/item/t_scanner/adv_mining_scanner
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results. This one has an extended range."
	name = "advanced automatic mining scanner"
	icon_state = "mining0"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 35
	var/current_cooldown = 0
	var/range = 7
	origin_tech = "engineering=3;magnets=3"

/obj/item/t_scanner/adv_mining_scanner/cyborg
	flags = CONDUCT | NODROP

/obj/item/t_scanner/adv_mining_scanner/lesser
	name = "automatic mining scanner"
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results."
	range = 4
	cooldown = 50

/obj/item/t_scanner/adv_mining_scanner/scan()
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		var/turf/t = get_turf(src)
		mineral_scan_pulse(t, range)

/proc/mineral_scan_pulse(turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/simulated/mineral/M in range(range, T))
		if(M.scan_state)
			minerals += M
	if(LAZYLEN(minerals))
		for(var/turf/simulated/mineral/M in minerals)
			var/obj/effect/temp_visual/mining_overlay/oldC = locate(/obj/effect/temp_visual/mining_overlay) in M
			if(oldC)
				qdel(oldC)
			var/obj/effect/temp_visual/mining_overlay/C = new /obj/effect/temp_visual/mining_overlay(M)
			C.icon_state = M.scan_state

/obj/effect/temp_visual/mining_overlay
	plane = FULLSCREEN_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/ore_visuals.dmi'
	appearance_flags = 0 //to avoid having TILE_BOUND in the flags, so that the 480x480 icon states let you see it no matter where you are
	duration = 35
	pixel_x = -224
	pixel_y = -224

/obj/effect/temp_visual/mining_overlay/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = EASE_IN)

//Gateway item that detects redspace structures
/obj/item/mining_scanner/red_key
	name = "red key"
	desc = "A skeleton key painted red, the blade has an unusual pattern."
	icon = 'icons/obj/device.dmi'
	icon_state = "key"
	item_state = ""
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL = 500)
	origin_tech = "biotech=4;bluespace=5"

/obj/effect/temp_visual/mining_overlay/redspace
	icon = 'icons/effects/key_runes.dmi'
	layer = BELOW_MOB_LAYER

/obj/effect/temp_visual/mining_overlay/redspace/floor

/obj/item/mining_scanner/red_key/attack_self(mob/user)
	if(!user.client)
		return
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		redspace_scan_pulse(get_turf(user))

/proc/redspace_scan_pulse(turf/T, range = world.view)
	var/list/signals = list()
	for(var/turf/simulated/floor/fakespace/redspace/F in range(range, T))
		if(F.signal_state)
			signals += F
	for(var/turf/simulated/wall/indestructible/redspace/W in range(range, T))
		if(W.signal_state)
			signals += W
	if(LAZYLEN(signals))
		for(var/turf/simulated/floor/fakespace/redspace/F in signals)
			var/obj/effect/temp_visual/mining_overlay/oldS = locate(/obj/effect/temp_visual/mining_overlay/redspace/floor) in F
			if(oldS)
				qdel(oldS)
			var/obj/effect/temp_visual/mining_overlay/redspace/floor/S = new /obj/effect/temp_visual/mining_overlay/redspace/floor(F)
			S.icon_state = F.signal_state
		for(var/turf/simulated/wall/indestructible/redspace/W in signals)
			var/obj/effect/temp_visual/mining_overlay/oldE = locate(/obj/effect/temp_visual/mining_overlay/redspace) in W
			if(oldE)
				qdel(oldE)
			var/obj/effect/temp_visual/mining_overlay/redspace/E = new /obj/effect/temp_visual/mining_overlay/redspace(W)
			E.icon_state = W.signal_state
