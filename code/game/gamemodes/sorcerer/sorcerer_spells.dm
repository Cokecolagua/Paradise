/datum/action/innate/sorcerer
	name = "Sorcerer DEBUG"
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_revenant"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	button_icon_state = "telerune"
	desc = "Prepare blood magic by carving runes into your flesh. This is easier with an <b>empowering rune</b>."
	var/list/spells = list()
	var/channeling = FALSE

/datum/action/innate/sorcerer/IsAvailable()
	if(!issorcerer(owner))
		return FALSE
	return ..()

/datum/action/innate/sorcerer/Remove()
	for(var/X in spells)
		qdel(X)
	..()

/datum/action/innate/sorcerer/override_location()
	button.ordered = FALSE
	button.screen_loc = DEFAULT_BLOODSPELLS
	button.moved = DEFAULT_BLOODSPELLS

/datum/action/innate/sorcerer/proc/Positioning()
	var/list/screen_loc_split = splittext(button.screen_loc, ",")
	var/list/screen_loc_X = splittext(screen_loc_split[1], ":")
	var/list/screen_loc_Y = splittext(screen_loc_split[2], ":")
	var/pix_X = text2num(screen_loc_X[2])
	for(var/datum/action/innate/sorcerer_spell/B in spells)
		if(B.button.locked)
			var/order = pix_X + spells.Find(B) * 31
			B.button.screen_loc = "[screen_loc_X[1]]:[order],[screen_loc_Y[1]]:[screen_loc_Y[2]]"
			B.button.moved = B.button.screen_loc

/datum/action/innate/sorcerer/Activate()
	var/rune = FALSE
	var/limit = RUNELESS_MAX_BLOODCHARGE
	for(var/obj/effect/rune/empower/R in range(1, owner))
		rune = TRUE
		limit = MAX_BLOODCHARGE
		break
	if(length(spells) >= limit)
		if(rune)
			to_chat(owner, "<span class='cultitalic'>You cannot store more than [MAX_BLOODCHARGE] spell\s. <b>Pick a spell to remove.</b></span>")
			remove_spell("You cannot store more than [MAX_BLOODCHARGE] spell\s, pick a spell to remove.")
		else
			to_chat(owner, "<span class='cultitalic'>You cannot store more than [RUNELESS_MAX_BLOODCHARGE] spell\s without an empowering rune! <b>Pick a spell to remove.</b></span>")
			remove_spell("You cannot store more than [RUNELESS_MAX_BLOODCHARGE] spell\s without an empowering rune, pick a spell to remove.")
		return
	var/entered_spell_name
	var/datum/action/innate/sorcerer_spell/BS
	var/list/possible_spells = list()
	for(var/I in subtypesof(/datum/action/innate/sorcerer_spell))
		var/datum/action/innate/sorcerer_spell/J = I
		var/spell_name = initial(J.name)
		possible_spells[spell_name] = J
	if(length(spells))
		possible_spells += "(REMOVE SPELL)"
	entered_spell_name = input(owner, "Pick a blood spell to prepare...", "Spell Choices") as null|anything in possible_spells
	if(entered_spell_name == "(REMOVE SPELL)")
		remove_spell()
		return
	BS = possible_spells[entered_spell_name]
	if(QDELETED(src) || owner.incapacitated() || !BS || (rune && !(locate(/obj/effect/rune/empower) in range(1, owner))) || (length(spells) >= limit))
		return

	if(!channeling)
		channeling = TRUE
		to_chat(owner, "<span class='cultitalic'>You begin to carve unnatural symbols into your flesh!</span>")
	else
		to_chat(owner, "<span class='warning'>You are already invoking blood magic!</span>")
		return

	if(do_after(owner, 100 - rune * 60, target = owner))
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.dna && (NO_BLOOD in H.dna.species.species_traits))
				H.cult_self_harm(3 - rune * 2)
			else
				H.bleed(20 - rune * 12)
		var/datum/action/innate/sorcerer_spell/new_spell = new BS(owner)
		spells += new_spell
		new_spell.Grant(owner, src)
		to_chat(owner, "<span class='cult'>Your wounds glow with power, you have prepared a [new_spell.name] invocation!</span>")
	channeling = FALSE

/datum/action/innate/sorcerer/proc/remove_spell(message = "Pick a spell to remove.")
	var/nullify_spell = input(owner, message, "Current Spells") as null|anything in spells
	if(nullify_spell)
		qdel(nullify_spell)


/datum/action/innate/sorcerer_spell
	name = "Arcane Magic"
	button_icon_state = "telerune"
	desc = "Fear the Old Blood."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	buttontooltipstyle = "cult"
	var/charges = 1
	var/magic_path = null
	var/obj/item/melee/blood_magic/hand_magic
	var/datum/action/innate/sorcerer/all_magic
	var/base_desc //To allow for updating tooltips
	var/invocation = "Hoi there something's wrong!"
	var/health_cost = 0

/datum/action/innate/sorcerer_spell/Grant(mob/living/owner, datum/action/innate/sorcerer/BM)
	if(health_cost)
		desc += "<br>Deals <u>[health_cost] damage</u> to your arm per use."
	base_desc = desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	all_magic = BM
	button.ordered = FALSE
	..()

/datum/action/innate/sorcerer_spell/override_location()
	button.locked = TRUE
	all_magic.Positioning()

/datum/action/innate/sorcerer_spell/Remove()
	if(all_magic)
		all_magic.spells -= src
	if(hand_magic)
		qdel(hand_magic)
		hand_magic = null
	..()

/datum/action/innate/sorcerer_spell/IsAvailable()
	if(!issorcerer(owner) || owner.incapacitated() || !charges)
		return FALSE
	return ..()

/datum/action/innate/sorcerer_spell/Activate()
	if(magic_path) // If this spell flows from the hand
		if(!hand_magic) // If you don't already have the spell active
			hand_magic = new magic_path(owner, src)
			if(!owner.put_in_hands(hand_magic))
				qdel(hand_magic)
				hand_magic = null
				to_chat(owner, "<span class='warning'>You have no empty hand for invoking blood magic!</span>")
				return
			to_chat(owner, "<span class='cultitalic'>Your wounds glow as you invoke the [name].</span>")

		else // If the spell is active, and you clicked on the button for it
			qdel(hand_magic)
			hand_magic = null

//***********ARCANE TORCH*************//

/datum/action/innate/sorcerer_magic
	name = "Arcane Torch"
	desc = "Manifests your magical decomposition as a ghostly hand, touch objects with it to analyze them and leave your presence."
	icon_icon = 'icons/mob/actions/actions.dmi'
	background_icon_state = "bg_revenant"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	button_icon_state = "arcane_aura"
	var/arcane_torch = /obj/item/melee/sorcerer_hand
	var/obj/item/melee/sorcerer_hand/torch

/datum/action/innate/sorcerer_magic/Activate()
	if(!torch)
		torch = new arcane_torch(owner, src)
		if(!owner.put_in_hands(torch))
			qdel(torch)
			torch = null
			to_chat(owner, "<span class='warning'>You have no empty hand for invoking your [name]!</span>")
			return
		to_chat(owner, "<span class='cultitalic'>Your mind relaxes as you invoke the [name].</span>")
	else
		qdel(torch)
		torch = null

/obj/item/melee/sorcerer_hand
	name = "\improper arcane aura"
	desc = "A sinister looking aura that drains the characteristics of objects to learn from them."
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "disintegrate-blue"
	item_state = "disintegrate-blue"
	flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/datum/action/innate/sorcerer_magic/source
	var/datum/sorcerer/sorcerer_user

/obj/item/melee/sorcerer_hand/afterattack(obj/item/T, mob/user, proximity_flag)
	if(!proximity_flag)
		return
	..()
	if(!istype(T))
		to_chat(user, "<span class='warning'>[src] can only drain objects!</span>")
		return
	if(isitem(T))
		to_chat(user, "<span class='warning'>[T] has been successfully drained!</span>")
		user.mind.sorcerer.current_knowledge += knowledge_value
		T.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		T.add_atom_colour("#636363", FIXED_COLOUR_PRIORITY)
	qdel(src)

/obj/item
	var/knowledge_value = 5

/datum/sorcerer
	var/current_knowledge = 0
	var/list/all_spells = list()
	var/list/draw_pile = list()
	var/list/discard_pile = list()
	var/list/items_analyzed = list()
	var/mob/living/owner = null
