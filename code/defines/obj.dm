/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		user << "Civilians: NT is recruiting! Please head SOUTH to the NT Recruitment office to join the station's crew!"

/obj/structure/ninjatele

	name = "Long-Distance Teleportation Console"
	desc = "A console used to send a Spider Clan agent long distances rapidly."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "teleconsole"
	anchored = 1
	density = 0

	attackby(obj/item/weapon/W as obj, mob/user as mob)

		return attack_hand(user)


	attack_hand(mob/user as mob)


		if (user.mind.special_role=="Ninja")
			switch(alert("Phase Jaunt relay primed, target locked as [station_name()], initiate VOID-shift translocation? (Warning! Internals required!)",,"Yes","No"))

				if("Yes")
					if(user.z != src.z)        return

					user.loc.loc.Exited(user)
					user.loc = pick(carplist) // In the future, possibly make specific NinjaTele landmarks, and give him an option to teleport to North/South/East/West of SS13 instead of just hijacking a carpspawn.


					playsound(user.loc, 'sound/effects/phasein.ogg', 25, 1)
					playsound(user.loc, 'sound/effects/sparks2.ogg', 50, 1)
					anim(user.loc,user,'icons/mob/mob.dmi',,"phasein",,user.dir)

					user <<"\blue <b>VOID-Shift</b> translocation successful"

				if("No")

					user <<"\red <b>Process aborted!</b>"

					return
		else
			user<< "\red <B>FĆAL �Rr�R</B>: ??er n?t rec?gnized, c-c?ntr-r???-?? ??cked."

/obj/effect/mark
		var/mark = ""
		icon = 'icons/misc/mark.dmi'
		icon_state = "blank"
		anchored = 1
		layer = 99
		mouse_opacity = 0
		unacidable = 1//Just to be sure.

/obj/effect/beam
	name = "beam"
	unacidable = 1//Just to be sure.
	var/def_zone
	pass_flags = PASSTABLE


/obj/effect/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = 1.0
	unacidable = 1

/*
 * This item is completely unused, but removing it will break something in R&D and Radio code causing PDA and Ninja code to fail on compile
 */

/obj/effect/datacore
	name = "datacore"
	var/medical[] = list()
	var/general[] = list()
	var/security[] = list()
	//This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/locked[] = list()


/obj/effect/datacore/proc/get_manifest(monochrome, OOC)
	var/list/heads = new()
	var/list/sec = new()
	var/list/eng = new()
	var/list/med = new()
	var/list/sci = new()
	var/list/supp = new()
	var/list/bot = new()
	var/list/misc = new()
	var/list/isactive = new()
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th><th>Activity</th></tr>
	"}
	var/even = 0
	// sort mobs
	for(var/datum/data/record/t in data_core.general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/real_rank = t.fields["real_rank"]
		if(OOC)
			var/active = 0
			for(var/mob/M in player_list)
				if(M.real_name == name && M.client && M.client.inactivity <= 10 * 60 * 10)
					active = 1
					break
			isactive[name] = active ? "Active" : "Inactive"
		else
			isactive[name] = t.fields["p_stat"]
			//world << "[name]: [rank]"
			//cael - to prevent multiple appearances of a player/job combination, add a continue after each line
		var/department = 0
		if(real_rank in command_positions)
			heads[name] = rank
			department = 1
		if(real_rank in security_positions)
			sec[name] = rank
			department = 1
		if(real_rank in engineering_positions)
			eng[name] = rank
			department = 1
		if(real_rank in medical_positions)
			med[name] = rank
			department = 1
		if(real_rank in science_positions)
			sci[name] = rank
			department = 1
		if(real_rank in support_positions)
			supp[name] = rank
			department = 1
		if(real_rank in nonhuman_positions)
			bot[name] = rank
			department = 1
		if(!department && !(name in heads))
			misc[name] = rank
	if(heads.len > 0)
		dat += "<tr><th colspan=3>Heads</th></tr>"
		for(name in heads)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[heads[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(sec.len > 0)
		dat += "<tr><th colspan=3>Security</th></tr>"
		for(name in sec)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sec[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(eng.len > 0)
		dat += "<tr><th colspan=3>Engineering</th></tr>"
		for(name in eng)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[eng[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(med.len > 0)
		dat += "<tr><th colspan=3>Medical</th></tr>"
		for(name in med)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[med[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(sci.len > 0)
		dat += "<tr><th colspan=3>Science</th></tr>"
		for(name in sci)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sci[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(supp.len > 0)
		dat += "<tr><th colspan=3>Support</th></tr>"
		for(name in supp)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[supp[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	// in case somebody is insane and added them to the manifest, why not
	if(bot.len > 0)
		dat += "<tr><th colspan=3>Silicon</th></tr>"
		for(name in bot)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[bot[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	// misc guys
	if(misc.len > 0)
		dat += "<tr><th colspan=3>Miscellaneous</th></tr>"
		for(name in misc)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[misc[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")
	return dat


/*
We can't just insert in HTML into the nanoUI so we need the raw data to play with.
Instead of creating this list over and over when someone leaves their PDA open to the page
we'll only update it when it changes.  The PDA_Manifest global list is zeroed out upon any change
using /obj/effect/datacore/proc/manifest_inject( ), or manifest_insert( )
*/

var/global/list/PDA_Manifest = list()

/obj/effect/datacore/proc/get_manifest_json()
	if(PDA_Manifest.len)
		return PDA_Manifest
	var/heads[0]
	var/sec[0]
	var/eng[0]
	var/med[0]
	var/sci[0]
	var/supp[0]
	var/bot[0]
	var/misc[0]
	for(var/datum/data/record/t in data_core.general)
		var/name = sanitize(t.fields["name"])
		var/rank = sanitize(t.fields["rank"])
		var/real_rank = t.fields["real_rank"]
		var/isactive = t.fields["p_stat"]
		var/department = 0
		var/depthead = 0 			// Department Heads will be placed at the top of their lists.
		if(real_rank in command_positions)
			heads[++heads.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			depthead = 1
			if(rank=="Captain" && heads.len != 1)
				heads.Swap(1,heads.len)

		if(real_rank in security_positions)
			sec[++sec.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && sec.len != 1)
				sec.Swap(1,sec.len)

		if(real_rank in engineering_positions)
			eng[++eng.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && eng.len != 1)
				eng.Swap(1,eng.len)

		if(real_rank in medical_positions)
			med[++med.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && med.len != 1)
				med.Swap(1,med.len)

		if(real_rank in science_positions)
			sci[++sci.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && sci.len != 1)
				sci.Swap(1,sci.len)

		if(real_rank in support_positions)
			supp[++supp.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && supp.len != 1)
				supp.Swap(1,supp.len)

		if(real_rank in nonhuman_positions)
			bot[++bot.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1

		if(!department && !(name in heads))
			misc[++misc.len] = list("name" = name, "rank" = rank, "active" = isactive)


	PDA_Manifest = list(\
		"heads" = heads,\
		"sec" = sec,\
		"eng" = eng,\
		"med" = med,\
		"sci" = sci,\
		"supp" = supp,\
		"bot" = bot,\
		"misc" = misc\
		)
	return PDA_Manifest


/obj/effect/laser
	name = "laser"
	desc = "IT BURNS!!!"
	icon = 'icons/obj/projectiles.dmi'
	var/damage = 0.0
	var/range = 10.0


/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/*
/obj/structure/cable
	level = 1
	anchored =1
	var/datum/powernet/powernet
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer"
	icon = 'icons/obj/power_cond_red.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	layer = 2.44 //Just below unary stuff, which is at 2.45 and above pipes, which are at 2.4
	var/_color = "red"
	var/obj/structure/powerswitch/power_switch
	var/obj/item/device/powersink/attached // holding this here for qdel

/obj/structure/cable/yellow
	_color = "yellow"
	icon = 'icons/obj/power_cond_yellow.dmi'

/obj/structure/cable/green
	_color = "green"
	icon = 'icons/obj/power_cond_green.dmi'

/obj/structure/cable/blue
	_color = "blue"
	icon = 'icons/obj/power_cond_blue.dmi'

/obj/structure/cable/pink
	_color = "pink"
	icon = 'icons/obj/power_cond_pink.dmi'

/obj/structure/cable/orange
	_color = "orange"
	icon = 'icons/obj/power_cond_orange.dmi'

/obj/structure/cable/cyan
	_color = "cyan"
	icon = 'icons/obj/power_cond_cyan.dmi'

/obj/structure/cable/white
	_color = "white"
	icon = 'icons/obj/power_cond_white.dmi'
*/

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = 1.0


/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )

/obj/structure/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1
	unacidable = 1//temporary until I decide whether the borg can be removed. -veyveyr

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/item/weapon/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = 0
	anchored = 0
	w_class = 1.0
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT


/obj/effect/stop
	var/victim = null
	icon_state = "empty"
	name = "Geas"
	desc = "You can't resist."
	// name = ""

/obj/effect/spawner
	name = "object spawner"
