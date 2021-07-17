//This is the gamemode file for the sorcerer antag
/datum/game_mode
	var/list/datum/mind/sorcerers = list()

/datum/game_mode/sorcerer
	name = "sorcerer"
	config_tag = "sorcerer"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Chaplain", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	var/sorcerer_amount = 4

/datum/game_mode/sorcerer/announce()
	to_chat(world, "<B>The current game mode is - Sorcerers!</B>")
	to_chat(world, "<B>Wizard Federation Trainees have been sent to the station to prove their might, watch out for up-coming spell-casters!</B>")

/datum/game_mode/sorcerer/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	var/list/datum/mind/possible_sorcerers = get_players_for_role(ROLE_SORCERER)
	sorcerer_amount = 1 + round(num_players() / 10)
	if(possible_sorcerers.len>0)
		for(var/i = 0, i < sorcerer_amount, i++)
			if(!possible_sorcerers.len) break
			var/datum/mind/sorcerer = pick(possible_sorcerers)
			possible_sorcerers -= sorcerer
			sorcerers += sorcerer
			sorcerer.restricted_roles = restricted_jobs
			modePlayer += sorcerers
			sorcerer.special_role = SPECIAL_ROLE_SORCERER
		..()
		return 1
	else
		return 0

/datum/game_mode/sorcerer/post_setup()
	for(var/datum/mind/sorcerer in sorcerers)
		grant_sorcerer_powers(sorcerer.current)
		forge_sorcerer_objectives(sorcerer)
		greet_sorcerer(sorcerer)
		update_sorcerer_icons_added(sorcerer)
	..()

/datum/game_mode/proc/auto_declare_completion_sorcerer()
	if(sorcerers.len)
		var/text = "<FONT size = 2><B>The sorcerers were:</B></FONT>"
		for(var/datum/mind/sorcerer in sorcerers)
			var/traitorwin = 1
			text += "<br>[sorcerer.key] was [sorcerer.name] ("
			if(sorcerer.current)
				if(sorcerer.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(sorcerer.current.real_name != sorcerer.name)
					text += " as [sorcerer.current.real_name]"
			else
				text += "body destroyed"
			text += ")"
			if(sorcerer.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in sorcerer.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[objective.type]", "SUCCESS"))
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[objective.type]", "FAIL"))
						traitorwin = 0
					count++

			var/special_role_text
			if(sorcerer.special_role)
				special_role_text = lowertext(sorcerer.special_role)
			else
				special_role_text = "antagonist"
			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				SSblackbox.record_feedback("tally", "traitor_success", 1, "SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				SSblackbox.record_feedback("tally", "traitor_success", 1, "FAIL")
		to_chat(world, text)
	return 1

/datum/game_mode/proc/forge_sorcerer_objectives(datum/mind/sorcerer)

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = sorcerer
	kill_objective.find_target()
	sorcerer.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = sorcerer
	steal_objective.find_target()
	sorcerer.objectives += steal_objective

	switch(rand(1,100))
		if(1 to 80)
			if(!(locate(/datum/objective/escape) in sorcerer.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = sorcerer
				sorcerer.objectives += escape_objective
		else
			if(!(locate(/datum/objective/survive) in sorcerer.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = sorcerer
				sorcerer.objectives += survive_objective
	return

/datum/game_mode/proc/grant_sorcerer_powers(mob/living/carbon/sorcerer_mob)
	if(!istype(sorcerer_mob))
		return
	sorcerer_mob.make_sorcerer()

/datum/game_mode/proc/greet_sorcerer(datum/mind/sorcerer, you_are=1)
	var/dat
	if(you_are)
		SEND_SOUND(sorcerer.current, sound('sound/ambience/antag/vampalert.ogg'))
		dat = "<span class='danger'>You are a Sorcerer!</span><br>"
	dat += {"To gain knowledge, use your Analytical Torch on items to drain them. Gain knowledge to learn spells.
After gaining enough points, you may gain, upgrade or remove spells. Using spells in public will be a sure sign for everyone else that you are a sorcerer."}
	to_chat(sorcerer.current, dat)
	to_chat(sorcerer.current, "<B>You must complete the following tasks:</B>")

	if(sorcerer.current.mind)
		if(sorcerer.current.mind.assigned_role == "Clown")
			to_chat(sorcerer.current, "Your lust for knowledge has allowed you to overcome your clumsy nature allowing you to wield weapons without harming yourself.")
			sorcerer.current.dna.SetSEState(GLOB.clumsyblock, FALSE)
			singlemutcheck(sorcerer.current, GLOB.clumsyblock, MUTCHK_FORCED)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(sorcerer.current)
	var/obj_count = 1
	for(var/datum/objective/objective in sorcerer.objectives)
		to_chat(sorcerer.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	to_chat(sorcerer.current, "<span class='motd'>For more information, check the wiki page: ([config.wikiurl]/index.php/Vampire)</span>")
	return
/datum/sorcerer
	var/bloodtotal = 0
	var/bloodusable = 0
	var/mob/living/owner = null
	var/iscloaking = 0
	var/list/powers = list()
	var/mob/living/carbon/human/draining
	var/nullified = 0
	var/list/upgrade_tiers = list(
		/obj/effect/proc_holder/spell/sorcerer/self/rejuvenate = 0,
		/obj/effect/proc_holder/spell/sorcerer/targetted/hypnotise = 0,
		/obj/effect/proc_holder/spell/sorcerer/mob_aoe/glare = 0,
		/datum/sorcerer_passive/vision = 100,
		/obj/effect/proc_holder/spell/sorcerer/self/screech = 200,
		/datum/sorcerer_passive/regen = 200,
		/obj/effect/proc_holder/spell/sorcerer/self/jaunt = 300,
		/datum/sorcerer_passive/full = 500)

/datum/sorcerer/proc/adjust_nullification(base, extra)
	// First hit should give full nullification, while subsequent hits increase the value slower
	nullified = max(nullified + extra, base)

/datum/sorcerer/proc/force_add_ability(path)
	var/spell = new path(owner)
	if(istype(spell, /obj/effect/proc_holder/spell))
		owner.mind.AddSpell(spell)
	powers += spell
	owner.update_sight() // Life updates conditionally, so we need to update sight here in case the vamp gets new vision based on his powers. Maybe one day refactor to be more OOP and on the vampire's ability datum.

/datum/sorcerer/proc/get_ability(path)
	for(var/P in powers)
		var/datum/power = P
		if(power.type == path)
			return power
	return null

/datum/sorcerer/proc/add_ability(path)
	if(!get_ability(path))
		force_add_ability(path)

/datum/sorcerer/proc/remove_ability(ability)
	if(ability && (ability in powers))
		powers -= ability
		owner.mind.spell_list.Remove(ability)
		qdel(ability)
		owner.update_sight()

/datum/sorcerer/proc/update_owner(mob/living/carbon/human/current)
	if(current.mind && current.mind.sorcerer && current.mind.sorcerer.owner && (current.mind.sorcerer.owner != current))
		current.mind.sorcerer.owner = current

/mob/proc/make_sorcerer()
	if(!mind)
		return
	var/datum/sorcerer/sorc
	if(!mind.sorcerer)
		sorc = new /datum/sorcerer
		sorc.owner = src
		mind.sorcerer = sorc
	else
		sorc = mind.sorcerer
		sorc.powers.Cut()

	sorc.check_sorcerer_upgrade(0)

/datum/sorcerer/proc/remove_sorcerer_powers()
	for(var/P in powers)
		remove_ability(P)
	if(owner.hud_used)
		var/datum/hud/hud = owner.hud_used
		if(hud.vampire_blood_display)
			hud.remove_vampire_hud()
	owner.alpha = 255

/datum/sorcerer/proc/handle_bloodsucking(mob/living/carbon/human/H)
	draining = H
	var/blood = 0
	var/old_bloodtotal = 0 //used to see if we increased our blood total
	var/old_bloodusable = 0 //used to see if we increased our blood usable
	var/blood_volume_warning = 9999 //Blood volume threshold for warnings
	if(owner.is_muzzled())
		to_chat(owner, "<span class='warning'>[owner.wear_mask] prevents you from biting [H]!</span>")
		draining = null
		return
	add_attack_logs(owner, H, "sorcererbit & is draining their blood.", ATKLOG_ALMOSTALL)
	owner.visible_message("<span class='danger'>[owner] grabs [H]'s neck harshly and sinks in [owner.p_their()] fangs!</span>", "<span class='danger'>You sink your fangs into [H] and begin to drain [H.p_their()] blood.</span>", "<span class='notice'>You hear a soft puncture and a wet sucking noise.</span>")
	if(!iscarbon(owner))
		H.LAssailant = null
	else
		H.LAssailant = owner
	while(do_mob(owner, H, 50))
		if(!(owner.mind in SSticker.mode.sorcerers))
			to_chat(owner, "<span class='userdanger'>Your fangs have disappeared!</span>")
			return
		old_bloodtotal = bloodtotal
		old_bloodusable = bloodusable
		if(H.stat < DEAD)
			if(H.ckey || H.player_ghosted) //Requires ckey regardless if monkey or humanoid, or the body has been ghosted before it died
				blood = min(20, H.blood_volume)	// if they have less than 20 blood, give them the remnant else they get 20 blood
				bloodtotal += blood / 2	//divide by 2 to counted the double suction since removing cloneloss -Melandor0
				bloodusable += blood / 2
		else
			if(H.ckey || H.player_ghosted)
				blood = min(5, H.blood_volume)	// The dead only give 5 blood
				bloodtotal += blood
		if(old_bloodtotal != bloodtotal)
			if(H.ckey || H.player_ghosted) // Requires ckey regardless if monkey or human, and has not ghosted, otherwise no power
				to_chat(owner, "<span class='notice'><b>You have accumulated [bloodtotal] [bloodtotal > 1 ? "units" : "unit"] of blood[bloodusable != old_bloodusable ? ", and have [bloodusable] left to use" : ""].</b></span>")
		check_sorcerer_upgrade()
		H.blood_volume = max(H.blood_volume - 25, 0)
		//Blood level warnings (Code 'borrowed' from Fulp)
		if(H.blood_volume)
			if(H.blood_volume <= BLOOD_VOLUME_BAD && blood_volume_warning > BLOOD_VOLUME_BAD)
				to_chat(owner, "<span class='danger'>Your victim's blood volume is dangerously low.</span>")
			else if(H.blood_volume <= BLOOD_VOLUME_OKAY && blood_volume_warning > BLOOD_VOLUME_OKAY)
				to_chat(owner, "<span class='warning'>Your victim's blood is at an unsafe level.</span>")
			blood_volume_warning = H.blood_volume
		else
			to_chat(owner, "<span class='warning'>You have bled your victim dry!</span>")
			break

		if(ishuman(owner))
			var/mob/living/carbon/human/S = owner
			if(!H.ckey && !H.player_ghosted)
				to_chat(S, "<span class='notice'><b>Feeding on [H] reduces your thirst, but you get no usable blood from them.</b></span>")
				S.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, S.nutrition + 5))
			else
				S.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, S.nutrition + (blood / 2)))


	draining = null
	to_chat(owner, "<span class='notice'>You stop draining [H.name] of blood.</span>")

/datum/sorcerer/proc/check_sorcerer_upgrade(announce = 1)
	var/list/old_powers = powers.Copy()

	for(var/ptype in upgrade_tiers)
		var/level = upgrade_tiers[ptype]
		if(bloodtotal >= level)
			add_ability(ptype)

	if(announce)
		announce_new_power(old_powers)

/datum/sorcerer/proc/announce_new_power(list/old_powers)
	for(var/p in powers)
		if(!(p in old_powers))
			if(istype(p, /obj/effect/proc_holder/spell/vampire))
				var/obj/effect/proc_holder/spell/vampire/power = p
				to_chat(owner, "<span class='notice'>[power.gain_desc]</span>")
			else if(istype(p, /datum/vampire_passive))
				var/datum/vampire_passive/power = p
				to_chat(owner, "<span class='notice'>[power.gain_desc]</span>")

/datum/game_mode/proc/remove_sorcerer(datum/mind/sorcerer_mind)
	if(sorcerer_mind in sorcerers)
		SSticker.mode.sorcerers -= sorcerer_mind
		sorcerer_mind.special_role = null
		sorcerer_mind.current.create_attack_log("<span class='danger'>De-sorcererd</span>")
		sorcerer_mind.current.create_log(CONVERSION_LOG, "De-sorcererd")
		if(sorcerer_mind.sorcerer)
			sorcerer_mind.sorcerer.remove_sorcerer_powers()
			QDEL_NULL(sorcerer_mind.sorcerer)
		if(issilicon(sorcerer_mind.current))
			to_chat(sorcerer_mind.current, "<span class='userdanger'>You have been turned into a robot! You can feel your powers fading away...</span>")
		else
			to_chat(sorcerer_mind.current, "<span class='userdanger'>You have been brainwashed! You are no longer a sorcerer.</span>")
		SSticker.mode.update_sorcerer_icons_removed(sorcerer_mind)

//prepare for copypaste
/datum/game_mode/proc/update_sorcerer_icons_added(datum/mind/sorcerer_mind)
	var/datum/atom_hud/antag/sorc_hud = GLOB.huds[ANTAG_HUD_SORCERER]
	sorc_hud.join_hud(sorcerer_mind.current)
	set_antag_hud(sorcerer_mind.current, ((sorcerer_mind in vampires) ? "hudvampire" : "hudvampirethrall"))

/datum/game_mode/proc/update_sorcerer_icons_removed(datum/mind/sorcerer_mind)
	var/datum/atom_hud/antag/sorcerer_hud = GLOB.huds[ANTAG_HUD_SORCERER]
	sorcerer_hud.leave_hud(sorcerer_mind.current)
	set_antag_hud(sorcerer_mind.current, null)

/datum/sorcerer/proc/handle_sorcerer()
	if(owner.hud_used)
		var/datum/hud/hud = owner.hud_used
		if(!hud.vampire_blood_display)
			hud.vampire_blood_display = new /obj/screen()
			hud.vampire_blood_display.name = "Usable Blood"
			hud.vampire_blood_display.icon_state = "blood_display"
			hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
			hud.static_inventory += hud.vampire_blood_display
			hud.show_hud(hud.hud_version)
		hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#ce0202'>[bloodusable]</font></div>"
	nullified = max(0, nullified - 1)
