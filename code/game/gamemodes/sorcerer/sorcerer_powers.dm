/obj/effect/proc_holder/spell/sorcerer
	panel = "Vampire"
	school = "vampire"
	clothes_req = 0
	range = 1
	charge_max = 1800
	action_background_icon_state = "bg_vampire"
	var/required_blood = 0
	var/gain_desc = null
	var/deduct_blood_on_cast = TRUE  //Do we want to take the blood when this is cast, or at a later point?

/obj/effect/proc_holder/spell/sorcerer/New()
	..()
	if(!gain_desc)
		gain_desc = "You have gained \the [src] ability."

/obj/effect/proc_holder/spell/sorcerer/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/living/user = usr)
	if(!user.mind)
		return 0
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You are in too weak of a form to do this!</span>")
		return 0

	var/datum/sorcerer/sorcerer = user.mind.sorcerer

	if(!sorcerer)
		return 0

	var/fullpower = sorcerer.get_ability(/datum/sorcerer_passive/full)

	if(user.stat >= DEAD)
		to_chat(user, "<span class='warning'>Not when you're dead!</span>")
		return 0

	if(sorcerer.nullified && !fullpower)
		to_chat(user, "<span class='warning'>Something is blocking your powers!</span>")
		return 0
	if(sorcerer.bloodusable < required_blood)
		to_chat(user, "<span class='warning'>You require at least [required_blood] units of usable blood to do that!</span>")
		return 0

/obj/effect/proc_holder/spell/sorcerer/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!user.mind)
		return 0
	if(!ishuman(user))
		return 0

	var/datum/sorcerer/sorcerer = user.mind.sorcerer

	if(!sorcerer)
		return 0

	var/fullpower = sorcerer.get_ability(/datum/sorcerer_passive/full)

	if(user.stat >= DEAD)
		return 0

	if(sorcerer.nullified && !fullpower)
		return 0
	if(sorcerer.bloodusable < required_blood)
		return 0
	if(istype(loc.loc, /area/chapel) && !fullpower)
		return 0
	return ..()

/obj/effect/proc_holder/spell/sorcerer/proc/affects(mob/target, mob/user = usr)
	if(target.mind && target.mind.sorcerer)
		return 0
	if(user.mind.sorcerer.get_ability(/datum/sorcerer_passive/full))
		return 1
	if(target.mind && target.mind.isholy)
		return 0
	return 1

/obj/effect/proc_holder/spell/sorcerer/proc/can_reach(mob/M as mob)
	if(M.loc == usr.loc)
		return 1 //target and source are in the same thing
	return M in oview_or_orange(range, usr, selection_type)

/obj/effect/proc_holder/spell/sorcerer/before_cast(list/targets)
	if(!usr.mind || !usr.mind.sorcerer)
		targets.Cut()
		return

	if(!required_blood)
		return


	var/datum/sorcerer/sorcerer = usr.mind.sorcerer

	if(required_blood <= sorcerer.bloodusable)
		if(!deduct_blood_on_cast) //don't take the blood yet if this is false!
			return
		sorcerer.bloodusable -= required_blood
	else
		// stop!!
		targets.Cut()

	if(targets.len)
		to_chat(usr, "<span class='notice'><b>You have [sorcerer.bloodusable] left to use.</b></span>")

/obj/effect/proc_holder/spell/sorcerer/targetted/choose_targets(mob/user = usr)
	var/list/possible_targets[0]
	for(var/mob/living/carbon/C in oview_or_orange(range, user, selection_type))
		possible_targets += C
	var/mob/living/carbon/T = input(user, "Choose your victim.", name) as null|mob in possible_targets

	if(!T || !can_reach(T))
		revert_cast(user)
		return

	perform(list(T), user = user)

/obj/effect/proc_holder/spell/sorcerer/self/choose_targets(mob/user = usr)
	perform(list(user))

/obj/effect/proc_holder/spell/sorcerer/mob_aoe/choose_targets(mob/user = usr)
	var/list/targets[0]
	for(var/mob/living/carbon/C in oview_or_orange(range, user, selection_type))
		targets += C

	if(!targets.len)
		revert_cast(user)
		return

	perform(targets, user = user)

/datum/sorcerer_passive
	var/gain_desc

/datum/sorcerer_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "You have gained \the [src] ability."

////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/sorcerer/self/rejuvenate
	name = "Rejuvenate"
	desc= "Use reserve blood to enliven your body, removing any incapacitating effects."
	action_icon_state = "vampire_rejuvinate"
	charge_max = 200
	stat_allowed = 1

/obj/effect/proc_holder/spell/sorcerer/self/rejuvenate/cast(list/targets, mob/user = usr)
	var/mob/living/U = user

	user.SetWeakened(0)
	user.SetStunned(0)
	user.SetParalysis(0)
	user.SetSleeping(0)
	U.adjustStaminaLoss(-75)
	to_chat(user, "<span class='notice'>You instill your body with clean blood and remove any incapacitating effects.</span>")
	spawn(1)
		if(usr.mind.sorcerer.get_ability(/datum/sorcerer_passive/regen))
			for(var/i = 1 to 5)
				U.adjustBruteLoss(-2)
				U.adjustOxyLoss(-5)
				U.adjustToxLoss(-2)
				U.adjustFireLoss(-2)
				sleep(35)

/obj/effect/proc_holder/spell/sorcerer/targetted/hypnotise
	name = "Hypnotise (20)"
	desc= "A piercing stare that incapacitates your victim for a good length of time."
	action_icon_state = "vampire_hypnotise"
	required_blood = 20

/obj/effect/proc_holder/spell/sorcerer/targetted/hypnotise/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		user.visible_message("<span class='warning'>[user]'s eyes flash briefly as [user.p_they()] stare[user.p_s()] into [target]'s eyes</span>")
		if(do_mob(user, target, 50))
			if(!affects(target))
				to_chat(user, "<span class='warning'>Your piercing gaze fails to knock out [target].</span>")
				to_chat(target, "<span class='notice'>[user]'s feeble gaze is ineffective.</span>")
			else
				to_chat(user, "<span class='warning'>Your piercing gaze knocks out [target].</span>")
				to_chat(target, "<span class='warning'>You find yourself unable to move and barely able to speak.</span>")
				target.Weaken(10)
				target.Stun(10)
				target.stuttering = 10
		else
			revert_cast(usr)
			to_chat(usr, "<span class='warning'>You broke your gaze.</span>")

/obj/effect/proc_holder/spell/sorcerer/mob_aoe/glare
	name = "Glare"
	desc = "A scary glare that incapacitates people for a short while around you."
	action_icon_state = "vampire_glare"
	charge_max = 300
	stat_allowed = 1

/obj/effect/proc_holder/spell/sorcerer/mob_aoe/glare/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='warning'>[user]'s eyes emit a blinding flash!</span>")
	if(istype(user:glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
		to_chat(user, "<span class='warning'>You're blindfolded!</span>")
		return
	for(var/mob/living/target in targets)
		if(!affects(target))
			continue
		target.Stun(5)
		target.Weaken(5)
		target.stuttering = 20
		to_chat(target, "<span class='warning'>You are blinded by [user]'s glare.</span>")
		add_attack_logs(user, target, "(Vampire) Glared at")

/obj/effect/proc_holder/spell/sorcerer/self/screech
	name = "Chiropteran Screech (30)"
	desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	gain_desc = "You have gained the Chiropteran Screech ability which stuns anything with ears in a large radius and shatters glass in the process."
	action_icon_state = "vampire_screech"
	required_blood = 30

/obj/effect/proc_holder/spell/sorcerer/self/screech/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='warning'>[user] lets out an ear piercing shriek!</span>", "<span class='warning'>You let out a loud shriek.</span>", "<span class='warning'>You hear a loud painful shriek!</span>")
	for(var/mob/living/carbon/C in hearers(4))
		if(C == user)
			continue
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
				continue
		if(!affects(C))
			continue
		to_chat(C, "<span class='warning'><font size='3'><b>You hear a ear piercing shriek and your senses dull!</font></b></span>")
		C.Weaken(4)
		C.AdjustEarDamage(0, 20)
		C.Stuttering(20)
		C.Stun(4)
		C.Jitter(150)
	for(var/obj/structure/window/W in view(4))
		W.deconstruct(FALSE)
	playsound(user.loc, 'sound/effects/creepyshriek.ogg', 100, 1)

/obj/effect/proc_holder/spell/sorcerer/self/jaunt
	name = "Mist Form (30)"
	desc = "You take on the form of mist for a short period of time."
	gain_desc = "You have gained the Mist Form ability which allows you to take on the form of mist for a short period and pass over any obstacle in your path."
	action_icon_state = "mist"
	charge_max = 600
	required_blood = 30
	centcom_cancast = 0
	var/jaunt_duration = 50 //in deciseconds

/obj/effect/proc_holder/spell/sorcerer/self/jaunt/cast(list/targets, mob/user = usr)
	spawn(0)
		var/mob/living/U = user
		var/originalloc = get_turf(user.loc)
		var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt(originalloc)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(originalloc)
		animation.name = "blood"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "empty"
		animation.layer = 5
		animation.master = holder
		U.ExtinguishMob()
		flick("mist", animation)
		user.forceMove(holder)
		user.client.eye = holder
		sleep(jaunt_duration)
		var/mobloc = get_turf(user.loc)
		animation.loc = mobloc
		user.canmove = 0
		sleep(20)
		flick("mist_reappear", animation)
		sleep(5)
		if(!user.Move(mobloc))
			for(var/direction in list(1,2,4,8,5,6,9,10))
				var/turf/T = get_step(mobloc, direction)
				if(T)
					if(user.Move(T))
						break
		user.canmove = 1
		user.client.eye = user
		qdel(animation)
		qdel(holder)

/datum/sorcerer_passive/regen
	gain_desc = "Your rejuvination abilities have improved and will now heal you over time when used."

/datum/sorcerer_passive/vision
	gain_desc = "Your vampiric vision has improved."

/datum/sorcerer_passive/full
	gain_desc = "You have reached your full potential and are no longer weak to the effects of anything holy and your vision has been improved greatly."
