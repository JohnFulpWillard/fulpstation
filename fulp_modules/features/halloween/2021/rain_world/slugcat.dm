/**
 * Slug cat
 * From: Rain World
 * By: Sheets
 */



/obj/item/clothing/suit/hooded/costume_2021/slugcat
	name = "slugcat onesie"
	desc = "A snuggly animal oneise, made from a stretchy hide."
	icon_state = "slugcat"
	greyscale_config = /datum/greyscale_config/slugcat
	greyscale_config_worn = /datum/greyscale_config/slugcat/worn
	greyscale_colors = slugcat_onesie_colour
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|FEET
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/costume_2021/slugcat_head

/obj/item/clothing/head/hooded/costume_2021/slugcat_head
	name = "slugcat onesie"
	icon_state = "slugcat_head"
	greyscale_config = /datum/greyscale_config/slugcat_head
	greyscale_config_worn = /datum/greyscale_config/slugcat_head/worn
	greyscale_colors = slugcat_onesie_colour
	body_parts_covered = HEAD
	flags_inv = HIDEEARS|HIDEHAIR

/obj/item/clothing/suit/hooded/costume_2021/slugcat/Initialize()
	. = ..()
	var/static/list/slugcat_onesie_colours = list(
		"#ffec3e", //yellow
		"#FFFFFF", //white
		"#ff4040", //red
		"#b72cee", //purple
		"#2495e0", //blue
		"#32bb2e", //green
		"#ff7e28" //orange
	)
	var/slugcat_oneise_colour = pick(list/slugcat_onesie_colours)

/obj/item/clothing/suit/hooded/costume_2021/slugcat/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "slugcat_emissive", alpha = src.alpha)

/obj/item/clothing/head/hooded/costume_2021/slugcat_head/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "slugcathead_emissive", alpha = src.alpha)

/obj/item/storage/box/halloween/edition_21/slugcat
	theme_name = "2021's slugcat onesie"
	costume_contents = list(
		/obj/item/clothing/suit/hooded/costume_2021/slugcat,
	)
