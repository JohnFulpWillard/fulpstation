/**
 * Slug cat
 * From: Rain World
 * By: Sheets
 */

/obj/item/clothing/suit/hooded/costume_2021/lizard
	name = "lizard onesie"
	desc = "A snuggly animal oneise, made from a stretchy hide."
	icon_state = "lizard"
	greyscale_config = /datum/greyscale_config/lizard_onesie
	greyscale_config_worn = /datum/greyscale_config/lizard_onesie/worn
	greyscale_colors = lizard_onesie_colour
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|FEET
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/costume_2021/lizard_head

/obj/item/clothing/head/hooded/costume_2021/lizard_head
	name = "lizard onesie"
	icon_state = "lizard_head"
	greyscale_config = /datum/greyscale_config/lizard_onesie_head
	greyscale_config_worn = /datum/greyscale_config/lizard_onesie_head/worn
	greyscale_colors = lizard_onesie_colour
	body_parts_covered = HEAD
	flags_inv = HIDEEARS|HIDEHAIR

/obj/item/clothing/suit/hooded/costume_2021/lizard/Initialize()
	. = ..()
	var/static/list/lizard_onesie_colours = list(
		"#ffec3e", //yellow
		"#FFFFFF", //white
		"#ff4040", //red
		"#b72cee", //purple
		"#2495e0", //blue
		"#32bb2e", //green
		"#ff7e28" //orange
	)
	var/lizard_oneise_colour = pick(list/lizard_onesie_colours)

/obj/item/clothing/suit/hooded/costume_2021/lizard/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "lizard_emissive", alpha = src.alpha)

/obj/item/clothing/head/hooded/costume_2021/lizard_head/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "lizardhead_emissive", alpha = src.alpha)

/obj/item/storage/box/halloween/edition_21/lizard
	theme_name = "2021's lizard onesie"
	costume_contents = list(
		/obj/item/clothing/suit/hooded/costume_2021/lizard,
	)
