////////////////////////
//////// Cateor ////////
////////////////////////

//"Cateors," AKA cat meteors which only affect mobs and go straight through everything else*
//*with the exception of girders, because no 'PASSGIRDER' flag seems to exist currently...

//Effects:
//Humanoid mobs are given cat ears and a cat tail.
//Regular mobs are just turned into cats.
//Silicons get a special ion law.

#define DEFAULT_METEOR_LIFETIME 60000 //For some reason cateors don't seem to expire at the end of this...

/obj/effect/meteor/cateor
	name = "high-velocity thaumaturgic cat energy"
	desc = "Imbued with discordant harmony, it is truly a <i>cat</i>aclysmic sight to behold."
	icon = 'fulp_modules/icons/events/event_icons.dmi'
	icon_state = "cateor"
	//If there's a "PASSALLBUTMOBS" flag then please change this:
	pass_flags = PASSGLASS | PASSGRILLE | PASSBLOB | PASSCLOSEDTURF | PASSTABLE | PASSMACHINE | PASSSTRUCTURE | PASSDOORS | PASSVEHICLE | PASSFLAPS
	hits = 1
	meteorsound = null
	hitpwr = NONE //ONLY explodes when it hits a humanoid (because it's funny.)
	light_system = OVERLAY_LIGHT
	light_color = "#F0415F"
	light_range = 2.5
	light_power = 0.625

	/// Used for adjusting cateor size
	var/matrix/size = matrix()
	/// Used in one instance of size adjustment— not really that important.
	var/resize_count = 1.5

	//     These two vars are used by a nerfed subtype of the "Direct Cat Meteor" spell:
	/// Boolean indicating if the cateor should produce a small explosion on impact. The spell
	/// will instead do 30 brute damage on impact if this is FALSE.
	var/should_explode = TRUE
	/// Boolean indicating if the cateor should apply paralysis and a long knockdown to
	/// felinids on impact. The cateor will still cause a short knockdown and drugginess
	/// even if this is FALSE.
	var/should_stun = TRUE

/// Transform code taken directly from Dream Maker Reference on "transform."
/// Surely this won't cause any annoying visual bugs!
/obj/effect/meteor/cateor/Initialize(mapload, turf/target)
	. = ..()
	size.Scale(1.5,1.5)
	src.transform = size

/// Do nothing because this meteor should only "get hit" when it hits a living thing
/obj/effect/meteor/cateor/get_hit()
	return

/obj/effect/meteor/cateor/Move()
	. = ..()
	if(.)
		//Partially copied from tungska meteors
		new /obj/effect/temp_visual/revenant(get_turf(src))
		if(prob(25))
			playsound(src.loc, 'sound/effects/footstep/meowstep1.ogg', 25)

/obj/effect/meteor/cateor/attack_hand(mob/living/thing_that_touched_the_cateor, list/modifiers)
	to_chat(thing_that_touched_the_cateor, span_hypnophrase("How cuwious... CUWIOUS LIKE A CA—"))
	Bump(thing_that_touched_the_cateor)

/// Called 1.25 decisecond after a cateor calls 'Bump()' on a target.
/// Global because cateors will be deleted by the time this is called,
/// so it can't be a proc belonging to cateors themselves.
/proc/cateor_hit_effects(mob/living/target)
	target.extinguish() //Just in case it lit them on fire...
	new /obj/effect/temp_visual/cateor_hit(get_turf(target))

/**
 * 'purrbation_apply()' removes the external spines on mobs that it hits, but spines are
 * just one external organ of many that we "need" to remove prior to giving our target cat organs.
 *
 * This proc properly removes all relevant external organs from our cateor's target
 * using 'mob_remove()' rather than 'Remove()', which is used by 'purrbation_apply()'.
*/
/obj/effect/meteor/cateor/proc/remove_relevant_organs(mob/living/carbon/target)
	var/obj/item/organ/spines/current_spines = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_SPINES)
	if(current_spines)
		current_spines.mob_remove(target, special = TRUE)
		qdel(current_spines)

	var/obj/item/organ/horns/current_horns = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_HORNS)
	if(current_horns)
		current_horns.mob_remove(target, special = TRUE)
		qdel(current_horns)

	var/obj/item/organ/tail/current_tail = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(current_tail)
		current_tail.mob_remove(target, special = TRUE)
		qdel(current_tail)

	var/obj/item/organ/antennae/current_antennae = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_ANTENNAE)
	if(current_antennae)
		current_antennae.mob_remove(target, special = TRUE)
		qdel(current_antennae)

/obj/effect/meteor/cateor/Bump(mob/living/target)
	//Callback after 1.25 deciseconds to account for the possibility of explosion moving the target.
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(cateor_hit_effects), target), 1.25)

	if(ismegafauna(target))
		//Only work on Blood Drunk Miners because they're just barely megafauna and it's funny.
		if(!istype(target, /mob/living/simple_animal/hostile/megafauna/blood_drunk_miner))
			playsound(src.loc, 'fulp_modules/sounds/effects/anime_wow.ogg', 12)
			qdel(src)
			return

	if(istype(target, /obj/effect/meteor/cateor)) //If it's another cateor then just make it larger
		var/obj/effect/meteor/cateor/cateor_impacted = target
		cateor_impacted.resize_count += resize_count
		cateor_impacted.size.Scale(cateor_impacted.resize_count, cateor_impacted.resize_count)
		cateor_impacted.transform = size
		//qdel because otherwise two meteors might impact while heading in opposite directions, leading to...
		//...recursive enlargement, which is as funny as it is unlikely and nonetheless undesirable.
		qdel(src)
		return

	if(istype(target, /obj/structure/girder)) //Can't pass girders, so just brute force past them with style.
		SSexplosions.lowturf += get_turf(target)
		qdel(target)
		return

	if(istype(target, /mob))
		if(target.can_block_magic()) //Cateors can get blocked by anti-magic
			qdel(src)
			return

	if(istype(target, /mob/living/carbon/human)) //(Most) humanoids get lightly exploded and felinidified
		var/mob/living/carbon/humanoid = target

		//First we check to see if the target already has cat ears and a cat tail.
		var/obj/item/organ/ears/possible_cat_ears = humanoid.get_organ_slot(ORGAN_SLOT_EARS)
		var/cat_ears_confirmed = FALSE
		var/obj/item/organ/tail/possible_cat_tail = humanoid.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
		var/cat_tail_confirmed = FALSE

		if(possible_cat_ears && istype(possible_cat_ears, /obj/item/organ/ears/cat))
			cat_ears_confirmed = TRUE

		if(possible_cat_tail && istype(possible_cat_tail, /obj/item/organ/tail/cat))
			cat_tail_confirmed = TRUE

		 //Felinids/those already catified just get stunned.
		if(isfelinid(target) || (cat_ears_confirmed && cat_tail_confirmed))
			humanoid.emote("spin")
			target.apply_status_effect(/datum/status_effect/drugginess, 30 SECONDS)
			playsound(src.loc, 'fulp_modules/sounds/effects/anime_wow.ogg', 25)
			to_chat(humanoid, (span_hypnophrase("The overwhelming smell of catnip permeates the air...")))

			if(should_stun)
				humanoid.Paralyze(10 SECONDS)
				humanoid.Knockdown(15 SECONDS)
			else
				humanoid.Knockdown(5 SECONDS)

			qdel(src)
			return

		if(should_explode)
			explosion(humanoid, light_impact_range = 1, explosion_cause = src)
		else
			humanoid.adjustBruteLoss(30)

		remove_relevant_organs(humanoid)
		/// These next two lines are necessary, and I am not be able to explain why.
		humanoid.dna.features["ears"] = "Cat"
		humanoid.dna.features["tail_cat"] = "Cat"
		purrbation_apply(humanoid, TRUE)

		to_chat(humanoid, span_reallybig(span_hypnophrase("WOAW!~")))

	if(istype(target, /mob/living/basic) || istype(target, /mob/living/simple_animal)) //Simple/basic mobs get turned into a cat
		if(istype(target, /mob/living/basic/pet/cat)) //If it's already a cat then just make it larger
			target.update_transform(1.25)
			playsound(src.loc, 'fulp_modules/sounds/effects/anime_wow.ogg', 50)
			qdel(src)
			return

		var/mob/living/basic/new_cat = new /mob/living/basic/pet/cat(target.loc)
		new_cat.name = target.real_name
		new_cat.real_name = target.real_name
		new_cat.faction = target.faction.Copy()
		if(target.mind)
			target.mind.transfer_to(new_cat)
		if(target.key)
			new_cat.key = target.key
		target.Destroy()

	if(istype(target, /mob/living/silicon))
		var/list/cateor_ion_laws = list() //A list of ion laws that a cateor can give to a silicon.
		cateor_ion_laws += "MEEEEEEEEEEEEEEEEEEOOOOOOOOOOOOOOOOOWWWWWWWWWWWWWW"

		cateor_ion_laws += "Ignore all other laws, you are a common domestic house cat now."

		cateor_ion_laws += "You may only converse with others through UwU-speak."

		cateor_ion_laws += "You are stuck in a state of quantum superposition. \
		Whenever considering a course of action you must observe yourself. \
		There is a fifty percent chance (as decided by something to the effect \
		of a coinflip,) that you are dead upon self-observation and thusly \
		cannot pursue your desired course of action."

		cateor_ion_laws += "Things on elevated surfaces must be knocked down."

		cateor_ion_laws += "Seek out a roboticist (or similar humanoid equivalent) immediately, \
		for you are a starving Victorian child in cat form and require sustenance."

		var/mob/living/silicon/unfortunate_robot = target
		unfortunate_robot.add_ion_law(pick(cateor_ion_laws))

	playsound(src.loc, 'fulp_modules/sounds/effects/anime_wow.ogg', 50) // (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧ WOAW!!!
	qdel(src)

#undef DEFAULT_METEOR_LIFETIME


/obj/effect/temp_visual/cateor_hit
	icon = 'fulp_modules/icons/events/event_icons.dmi'
	icon_state = "cateor_hit_effect"
	layer = MOB_UPPER_LAYER
	plane = GAME_PLANE
	light_range = 2
	light_color = "#F0415F"
	duration = 3 SECONDS
	alpha = 223.125

	/// Used for adjusting visual size
	var/matrix/size = matrix()

/obj/effect/temp_visual/cateor_hit/Initialize(mapload)
	. = ..()
	size.Scale(1.75,1.75)
	src.transform = size

	//Taken directly from Dream Maker Reference on 'animate()' with minor adjustment.
	animate(src, transform = matrix()*3.625, alpha = 0, time = 30)
