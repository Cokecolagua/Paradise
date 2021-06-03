// Redspace Gateway Maze
/obj/effect/mazegen/module_loot/redspace
	name = "redspace loot"
	spawn_probability = 100

/obj/effect/mazegen/module_loot/redspace/spawn_loot(turf/T)
	/obj/item/mining_scanner/red_key

/obj/effect/mazegen/generator/blockwise/redspace
	name = "blockwise redspace maze generator"
	wall_material = /turf/simulated/wall/indestructible/redspace
	floor_material = /turf/simulated/floor/fakespace/redspace
	mwidth = 33
	mheight = 27
	list/obj/effect/mazegen/module_loot/loot_modules = list(/obj/effect/mazegen/module_loot/redspace)
