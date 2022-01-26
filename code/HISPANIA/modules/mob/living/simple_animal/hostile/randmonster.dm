+/mob/living/simple_animal/hostile/randomstats
	name = "alien fighter"
	icon = 'icons/mob/alien.dmi'
	icon_state = "alienh_running"
	icon_living = "alienh_running"
	icon_dead = "alienh_dead"
	icon_gib = "syndicate_gib"
	gender = FEMALE
	response_help = "pokes"
	response_harm = "hits"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat= 3, /obj/item/stack/sheet/animalhide/xeno = 1)
	attacktext = "slashes"
	speak_emote = list("hisses")
	bubble_icon = "alien"
	maxHealth = 125
	health = 125
	melee_damage_lower = 15
	melee_damage_upper = 15
	faction = list("alien")
	var/attack_minimum = 8
	var/attack_maximum = 25
	var/health_minimum = 100
	var/health_maximum = 200
	var/randomize_aggro = TRUE // falso para no randomizar la agresividad, solo los stats
	var/mad_length = 30 SECONDS // duración en segundos que un mob neutral se hace hostil cuando le pegan

/mob/living/simple_animal/hostile/randomstats/Initialize()
	. = ..()
	var/attack_result = rand(attack_minimum,attack_maximum)
	var/health_result = rand(health_minimum,health_maximum)
	melee_damage_lower = attack_result
	melee_damage_upper = attack_result
	maxHealth = health_result
	health = health_result
	if(randomize_aggro == TRUE)
		faction += pick("hostile","neutral")

/mob/living/simple_animal/hostile/randomstats/proc/stop_malding()
	faction -= "hostile"
	faction += "neutral"

/mob/living/simple_animal/hostile/randomstats/attacked_by(obj/item/I, mob/living/user)
	if("neutral" in faction)
		faction -= "neutral"
		faction += "hostile"
		addtimer(CALLBACK(src, /mob/living/simple_animal/hostile/randomstats/.proc/stop_malding), mad_length)
	. = ..()
