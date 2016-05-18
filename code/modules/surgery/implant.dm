//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.

//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity
	priority = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!hasorgans(target))
			return 0
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.open == (affected.encased ? 3 : 2) && !(affected.status & ORGAN_BLEEDING)

	proc/get_max_wclass(var/obj/item/organ/external/affected)
		switch (affected.name)
			if ("head")
				return 1
			if ("upper body")
				return 3
			if ("lower body")
				return 2
		return 0

	proc/get_cavity(var/obj/item/organ/external/affected)
		switch (affected.name)
			if ("head")
				return "cranial"
			if ("upper body")
				return "thoracic"
			if ("lower body")
				return "abdominal"
		return ""

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!", \
		"\red Your hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!")
		affected.createwound(CUT, 20)

/datum/surgery_step/cavity/make_space
	allowed_tools = list(
	/obj/item/weapon/surgicaldrill = 100,	\
	/obj/item/weapon/pen = 75,	\
	/obj/item/stack/rods = 50
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			return affected && !affected.cavity

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].", \
		"You start making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]." )
		target.custom_pain("The pain in your chest is living hell!",1)
		affected.cavity = 1
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].", \
		"\blue You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]." )

/datum/surgery_step/cavity/close_space
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/smokable/cigarette = 75,	\
	/obj/item/weapon/flame/lighter = 50,			\
	/obj/item/weapon/weldingtool = 25
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			return affected && affected.cavity

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts mending [target]'s [get_cavity(affected)] cavity wall with \the [tool].", \
		"You start mending [target]'s [get_cavity(affected)] cavity wall with \the [tool]." )
		target.custom_pain("The pain in your chest is living hell!",1)
		affected.cavity = 0
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] mends [target]'s [get_cavity(affected)] cavity walls with \the [tool].", \
		"\blue You mend [target]'s [get_cavity(affected)] cavity walls with \the [tool]." )

/datum/surgery_step/cavity/place_item
	priority = 0
	allowed_tools = list(/obj/item = 100)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			if(istype(user,/mob/living/silicon/robot))
				return
			if(affected && affected.cavity)
				var/total_volume = tool.w_class
				for(var/obj/item/I in affected.implants)
					if(istype(I,/obj/item/weapon/implant))
						continue
					total_volume += I.w_class
				return total_volume <= get_max_wclass(affected)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.", \
		"You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity." )
		target.custom_pain("The pain in your chest is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)

		user.visible_message("\blue [user] puts \the [tool] inside [target]'s [get_cavity(affected)] cavity.", \
		"\blue You put \the [tool] inside [target]'s [get_cavity(affected)] cavity." )
		if (tool.w_class > get_max_wclass(affected)/2 && prob(50) && !(affected.status & ORGAN_ROBOT))
			user << "\red You tear some blood vessels trying to fit such a big object in this cavity."
			var/datum/wound/internal_bleeding/I = new (10)
			affected.wounds += I
			affected.owner.custom_pain("You feel something rip in your [affected.name]!", 1)
		user.drop_item()
		affected.implants += tool
		tool.loc = affected
		affected.cavity = 0

//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity/implant_removal
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/material/kitchen/utensil/fork = 20
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(affected.organ_tag == BP_HEAD)
			var/obj/item/organ/internal/brain/sponge = target.internal_organs_by_name["brain"]
			return ..() && (!sponge || !sponge.damage)
		else
			return ..()

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts poking around inside [target]'s [affected.name] with \the [tool].", \
		"You start poking around inside [target]'s [affected.name] with \the [tool]" )
		target.custom_pain("The pain in your [affected.name] is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)

		var/find_prob = 0

		if(target_zone == BP_TORSO)
			if(target.stomach_contents.len)
				find_prob = 50
				user.visible_message("<span class='notice'>[user] starts poking around [target]'s stomach!</span>",
									 "<span class='notice'>You start poking around [target]'s stomach.</span></span>")
				var/a = pick(target.stomach_contents)

				if(ismob(a))
					var/mob/M = a
					user.visible_message("<span class='notice'>[user] starts to pull [M] out of [target]'s stomach!</span>",
										 "<span class='notice'>You start to pull [M] out of [target]'s stomach!</span>")
					if(!prob(find_prob))
						user.visible_message("<span class='warning'>[user] loses their grip on [M], failing to extract them from [target]'s stomach!</span>",
											 "<span class='warning'>You lose you grip on [M], failing to extract them from [target]'s stomach!</span>")
						return

					if(do_after(user, 30))
						user.visible_message("<span class='notice'>[user] pulls [M] out of [target]'s stomach!</span>",
											 "<span class='notice'>You pull [M] out of [target]'s stomach!</span>")
						target.stomach_contents -= M
						M.loc = get_turf(target)
						return
					else
						user.visible_message("<span class='warning'>[user] loses their grip on [M], failing to extract them from [target]'s stomach!</span>",
											 "<span class='warning'>You lose you grip on [M], failing to extract them from [target]'s stomach! You have to stay still to extract them!</span>")
						return

				if(isobj(a))
					var/obj/O = a
					find_prob = 25 + (O.w_class * 5)

					if(prob(find_prob))
						user.visible_message("\blue [user] takes something out of incision on [target]'s [affected.name] with \the [tool].", \
						"\blue You take [O] out of incision on [target]'s [affected.name]s with \the [tool]." )
						target.stomach_contents -= O
						O.loc = get_turf(target)
						O.add_blood(target)
						O.update_icon()

		if (affected.implants.len)

			var/obj/item/obj = pick(affected.implants)

			if(istype(obj,/obj/item/weapon/implant))
				var/obj/item/weapon/implant/imp = obj
				if (imp.islegal())
					find_prob +=60
				else
					find_prob +=40
			else
				find_prob +=50

			if (prob(find_prob))
				user.visible_message("\blue [user] takes something out of incision on [target]'s [affected.name] with \the [tool].", \
				"\blue You take [obj] out of incision on [target]'s [affected.name]s with \the [tool]." )
				affected.implants -= obj

				BITSET(target.hud_updateflag, IMPLOYAL_HUD)

				//Handle possessive brain borers.
				if(istype(obj,/mob/living/simple_animal/borer))
					var/mob/living/simple_animal/borer/worm = obj
					if(worm.controlling)
						target.release_control()
					worm.detatch()
					worm.leave_host()
				else
					obj.loc = get_turf(target)
					obj.add_blood(target)
					obj.update_icon()
					if(istype(obj,/obj/item/weapon/implant))
						var/obj/item/weapon/implant/imp = obj
						imp.imp_in = null
						imp.implanted = 0
			else
				user.visible_message("\blue [user] removes \the [tool] from [target]'s [affected.name].", \
				"\blue There's something inside [target]'s [affected.name], but you just missed it this time." )
		else
			user.visible_message("\blue [user] could not find anything inside [target]'s [affected.name], and pulls \the [tool] out.", \
			"\blue You could not find anything inside [target]'s [affected.name]." )

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		..()
		var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
		if (affected.implants.len)
			var/fail_prob = 10
			fail_prob += 100 - tool_quality(tool)
			if (prob(fail_prob))
				var/obj/item/weapon/implant/imp = affected.implants[1]
				user.visible_message("\red Something beeps inside [target]'s [affected.name]!")
				playsound(imp.loc, 'sound/items/countdown.ogg', 75, 1, -3)
				spawn(25)
					imp.activate()

