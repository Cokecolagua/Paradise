//This is the gamemode file for the sorcerer antag
/datum/game_mode
	var/list/datum/mind/all_sorcerers = list()

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
	to_chat(world, "<B>Some crewmembers have fallen down a magical rabbit-hole trying to expand their knowledge, watch out for up-coming spell-casters!</B>")

/proc/issorcerer(mob/living/M)
	return istype(M) && M.mind && SSticker && SSticker.mode && (M.mind in SSticker.mode.all_sorcerers)

/datum/game_mode/sorcerer/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	var/list/sorcerers_possible = get_players_for_role(ROLE_SORCERER)
	sorcerer_amount = 1 + round(num_players() / 10)
	for(var/sorcerers_number = 1 to sorcerer_amount)
		if(!length(sorcerers_possible))
			break
		var/datum/mind/sorcerer = pick(sorcerers_possible)
		sorcerers_possible -= sorcerer
		all_sorcerers += sorcerer
		sorcerer.restricted_roles = restricted_jobs
		sorcerer.special_role = SPECIAL_ROLE_SORCERER
	return (length(all_sorcerers) > 0)

/datum/game_mode/sorcerer/post_setup()
	modePlayer += all_sorcerers
	for(var/datum/mind/sorcerer in all_sorcerers)
		greet_sorcerer(sorcerer)
		forge_sorcerer_objectives(sorcerer)
		sorcerer.current.faction |= "sorcerer"
		if(sorcerer.assigned_role == "Clown")
			to_chat(sorcerer.current, "<span class='cultitalic'>Your lust for knowledge has allowed you to overcome your clownish nature, letting you wield weapons without harming yourself.</span>")
			sorcerer.current.dna.SetSEState(GLOB.clumsyblock, FALSE)
			singlemutcheck(sorcerer.current, GLOB.clumsyblock, MUTCHK_FORCED)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(sorcerer.current)
		add_sorcerer_actions(sorcerer)
		grant_sorcerer_powers(sorcerer)
	..()

/datum/game_mode/proc/auto_declare_completion_sorcerer()
	if(all_sorcerers.len)
		var/text = "<FONT size = 2><B>The sorcerers were:</B></FONT>"
		for(var/datum/mind/sorcerer in all_sorcerers)
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

/mob/proc/make_sorcerer()
	if(!mind)
		return
	var/datum/sorcerer/sorc
	if(!mind.sorcerer)
		sorc.owner = src
		mind.sorcerer = sorc
	else
		sorc = mind.sorcerer

/datum/game_mode/proc/add_sorcerer_actions(datum/mind/sorcerer)
	if(sorcerer.current && ishuman(sorcerer.current))
		var/datum/action/innate/sorcerer/magic = new
		magic.Grant(sorcerer.current)
		var/datum/action/innate/sorcerer_magic/hand = new
		hand.Grant(sorcerer.current)
	sorcerer.current.update_action_buttons(TRUE)

/datum/game_mode/proc/greet_sorcerer(datum/mind/sorcerer, you_are=1)
	var/dat
	if(you_are)
		SEND_SOUND(sorcerer.current, sound('sound/ambience/antag/vampalert.ogg'))
		dat = "<span class='danger'>You are a Sorcerer!</span><br>"
	dat += {"To gain knowledge, use your Analytical Torch on items to drain them. Gain knowledge to learn spells.
After gaining enough points, you may gain, upgrade or remove spells. Using spells in public will be a sure sign for everyone else that you are a sorcerer."}
	to_chat(sorcerer.current, dat)
	to_chat(sorcerer.current, "<B>You must complete the following tasks:</B>")
	var/obj_count = 1
	for(var/datum/objective/objective in sorcerer.objectives)
		to_chat(sorcerer.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	to_chat(sorcerer.current, "<span class='motd'>For more information, check the wiki page: ([config.wikiurl]/index.php/Vampire)</span>")
	return

/datum/game_mode/proc/remove_sorcerer(datum/mind/sorcerer_mind, show_message = TRUE, remove_gear = FALSE)
	if(!(sorcerer_mind in all_sorcerers))
		return
	var/mob/sorcerer = sorcerer_mind.current
	all_sorcerers -= sorcerer_mind
	sorcerer.faction -= "sorcerer"
	sorcerer_mind.special_role = null
	for(var/datum/action/innate/cult/C in sorcerer.actions)
		qdel(C)

/datum/game_mode/proc/update_sorcerer_icons_added(datum/mind/sorcerer_mind)
	var/datum/atom_hud/antag/sorc_hud = GLOB.huds[ANTAG_HUD_SORCERER]
	sorc_hud.join_hud(sorcerer_mind.current)
	set_antag_hud(sorcerer_mind.current, ((sorcerer_mind in vampires) ? "hudvampire" : "hudvampirethrall"))

/datum/game_mode/proc/update_sorcerer_icons_removed(datum/mind/sorcerer_mind)
	var/datum/atom_hud/antag/sorcerer_hud = GLOB.huds[ANTAG_HUD_SORCERER]
	sorcerer_hud.leave_hud(sorcerer_mind.current)
	set_antag_hud(sorcerer_mind.current, null)
