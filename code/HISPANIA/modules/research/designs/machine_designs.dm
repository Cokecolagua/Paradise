/datum/design/telepad
	name = "Machine Board (Telepad Board)"
	desc = "Allows for the construction of circuit boards used to build a Telepad."
	id = "telepad"
	req_tech = list("programming" = 6, "bluespace" = 8, "plasmatech" = 6, "engineering" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telesci_pad
	category = list ("Teleportation Machinery")

/datum/design/doppler_array
	name = "Machine Board (Tachyon-Doppler Array Board)"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array."
	id = "doppler_array"
	req_tech = list("programming" = 4, "plasmatech" = 4, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/doppler_array
	category = list ("Research Machinery")

/datum/design/undirect_doppler_array
	name = "Machine Board (Undirectional Tachyon-Doppler Array Board)"
	desc = "A highly precise sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array."
	id = "undirect_doppler_array"
	req_tech = list("programming" = 6, "plasmatech" = 4, "engineering" = 3, "toxins" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/doppler_array/undirectional
	category = list ("Research Machinery")
