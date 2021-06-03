// AREAS

/area/awaymission/redroom
	name = "Red Rooms"
	icon_state = "away"
	tele_proof = TRUE

/area/awaymission/redroom/science
	name = "R3D Science"
	icon_state = "awaycontent1"

/area/awaymission/redroom/syndishuttle
	name = "V9 Space Shuttle"
	icon_state = "awaycontent2"

/area/awaymission/redroom/gym
	name = "Gymnasium"
	icon_state = "awaycontent3"

/area/awaymission/redroom/bedshop
	name = "Bed & Bedsheet Shop"
	icon_state = "awaycontent4"

// TURFS

/turf/simulated/wall/indestructible/redspace
	name = "\proper space"
	desc = ""
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	plane = PLANE_SPACE
	opacity = FALSE
	var/signal_state = ""

/turf/simulated/wall/indestructible/redspace/Initialize(mapload)
	. = ..()
	icon_state = SPACE_ICON_STATE
	signal_state = "redwall"

/turf/simulated/wall/indestructible/redspace/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	underlay_appearance.plane = PLANE_SPACE
	return TRUE

/turf/simulated/floor/fakespace/redspace
	name = "\proper space"
	desc = ""
	var/signal_state = ""

/turf/simulated/floor/fakespace/redspace/Initialize(mapload)
	. = ..()
	signal_state = "redfloor"

// ITEMS

/obj/item/mining_scanner/red_key
	name = "red key"
	desc = "A skeleton key painted red, the blade has an unusual pattern."
	icon = 'icons/obj/device.dmi'
	icon_state = "key"
	item_state = ""
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	var/range = 4
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
		var/turf/t = get_turf(src)
		redspace_scan_pulse(t, range)

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

/obj/item/card/id/away/gym
	name = "Gymnasium Shopclerk ID"
	desc = "A card used to provide ID and determine access across a gymnasium."

/obj/item/paper/red_key
	name = "Object X-3 Report"
	info = ""

// SPAWNER

/obj/effect/mob_spawn/human/gymnasium
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a shopclerk uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a gymnasium shopclerk"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	description = "Gear up as you try to escape a mysterious, magical red maze."
	important_info = ""
	flavour_text = "You are a shopclerk running a gymnasium. You vaguely recall finding a lost red key from \
	one of your costumers. The last thing you remember is inspecting the unusual pattern of the key's blade before falling asleep. As you open \
	your eyes, everything seems empty and desolated, the red key on your bed table starts to shine as you get out of your pod."
	uniform = /obj/item/clothing/under/waiter/shop
	shoes = /obj/item/clothing/shoes/black
	id = /obj/item/card/id/away/gym
	r_pocket = /obj/item/stack/spacecash/c500
	l_pocket = /obj/item/flash
	assignedrole = "Gymnasium Shopclerk"
