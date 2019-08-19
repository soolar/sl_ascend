script "sl_community_service.ash"

#	Some details derived some yojimbos_law's forum post:
#	http://forums.kingdomofloathing.com/vb/showpost.php?p=4769933&postcount=345

static int[int] sl_cs_fastQuestList;

boolean LA_cs_communityService()
{
	if(my_path() != "Community Service")
	{
		return false;
	}

	static int curQuest = 0;
	if(curQuest == 0)
	{
		curQuest = expected_next_cs_quest();
	}

	cs_preTurnStuff(curQuest);

	if(fortuneCookieEvent())
	{
		return true;
	}

	equipBaseline();
	forceEquip($slot[Off-hand], $item[Barrel Lid]);
	forceEquip($slot[Shirt], $item[Tunac]);
	foreach it in $items[Brutal Brogues, Draftsman\'s Driving Gloves, Nouveau Nosering]
	{
		if(possessEquipment(it))
		{
			equip($slot[acc3], it);
		}
	}

	print(what_cs_quest(curQuest), "blue");

	cs_eat_spleen();

	if(sl_voteMonster(true, $location[Barf Mountain], "cs_combatNormal"))
	{
		return true;
	}

	boolean [familiar] useFam;
	if(((curQuest == 11) || (curQuest == 6) || (curQuest == 9)) && (my_spleen_use() < 12))
	{
		useFam = $familiars[Baby Sandworm, Unconscious Collective, Grim Brother, Golden Monkey, Bloovian Groose];
	}
	else
	{
		if(have_familiar($familiar[Rockin\' Robin]) && ($familiar[Rockin\' Robin].drops_today == 0))
		{
			useFam = $familiars[Galloping Grill, Fist Turkey, Rockin\' Robin, Puck Man, Ms. Puck Man];
		}
		else if(my_spleen_use() < 12)
		{
			useFam = $familiars[Galloping Grill, Fist Turkey, Puck Man, Ms. Puck Man, Baby Sandworm, Unconscious Collective, Grim Brother, Golden Monkey, Bloovian Groose];
		}
		else
		{
			useFam = $familiars[Galloping Grill, Fist Turkey, Puck Man, Ms. Puck Man];
		}
	}

	int[familiar] blacklist;
	if(get_property("sl_blacklistFamiliar") != "")
	{
		string[int] noFams = split_string(get_property("sl_blacklistFamiliar"), ";");
		foreach index, fam in noFams
		{
			blacklist[to_familiar(trim(fam))] = 1;
		}
	}

	handleFamiliar("item");
	#familiar toFam = $familiar[Cocoabo];
	familiar toFam = get_property("sl_familiarChoice").to_familiar();
	foreach fam in useFam
	{
		if(have_familiar(fam) && !(blacklist contains fam))
		{
			toFam = fam;
		}
	}
	handleFamiliar(toFam);


	switch(my_daycount())
	{
	case 1:
		if(!get_property("_loveTunnelUsed").to_boolean() && get_property("loveTunnelAvailable").to_boolean())
		{
			handleFamiliar($familiar[Nosy Nose]);
			loveTunnelAcquire(true, $stat[none], true, 3, true, 3, "cs_combatNormal");
			return true;
		}
		if(item_amount($item[Cornucopia]) == 1)
		{
			use(1, $item[Cornucopia]);
		}
		break;
	case 2:
		if(!get_property("_loveTunnelUsed").to_boolean() && get_property("loveTunnelAvailable").to_boolean())
		{
			handleFamiliar($familiar[Nosy Nose]);
			loveTunnelAcquire(true, $stat[Moxie], true, 2, true, 3, "cs_combatNormal");
			return true;
		}
		if(item_amount($item[Cornucopia]) == 1)
		{
			use(1, $item[Cornucopia]);
		}
		break;
	default:
		if(!get_property("_loveTunnelUsed").to_boolean() && get_property("loveTunnelAvailable").to_boolean())
		{
			handleFamiliar($familiar[Nosy Nose]);
			loveTunnelAcquire(true, $stat[none], true, 3, true, 1, "cs_combatNormal");
			return true;
		}
		break;
	}

	if(isOverdueDigitize() && (my_daycount() == 1) && (get_property("_sourceTerminalDigitizeMonsterCount").to_int() == 1))
	{
		if((get_property("_sourceTerminalDigitizeUses").to_int() > 0) && (get_property("_sourceTerminalDigitizeUses").to_int() < 3))
		{
			print("A Wanderer event is expected now, we want to re-digitize", "blue");
			sl_sourceTerminalEducate($skill[Digitize], $skill[Extract]);
			set_property("sl_combatDirective", "start;skill digitize");
			slAdv(1, $location[Barf Mountain], "cs_combatNormal");
			set_property("sl_combatDirective", "");
		}
	}

	if((my_daycount() == 2) && have_skill($skill[Shattering Punch]))
	{
		if(godLobsterCombat())
		{
			return true;
		}
	}

	//Quest order on Day 1: 11, 6, 9 (Coiling Wire, Weapon Damage, Item)
	//Day 2: 7, 10, 1, 2, 3, 4, 5, 8
	if((my_daycount() == 2) && sl_haveWitchess() && have_skills($skills[Conspiratorial Whispers, Curse of Weaksauce, Sauceshell, Shell Up, Silent Slam]) && (have_skill($skill[Tattle]) || have_skill($skill[Meteor Lore])) && !possessEquipment($item[Dented Scepter]) && (get_property("_sl_witchessBattles").to_int() < 5) && have_familiar($familiar[Galloping Grill]) && (my_ascensions() >= 100))
	{
		while((my_mp() < 120) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
		{
			doRest();
		}
		if((my_hp() < 200) && ((my_hp()+30) < my_maxhp()))
		{
			useCocoon();
		}
		handleFamiliar($familiar[Galloping Grill]);
		sl_sourceTerminalEducate($skill[Turbo], $skill[Compress]);
		boolean result = sl_advWitchess("king", "cs_combatKing");
		sl_sourceTerminalEducate($skill[Compress], $skill[Extract]);
		return result;
	}
	if((my_daycount() == 2) && sl_haveWitchess() && have_skills($skills[Conspiratorial Whispers, Curse of Weaksauce, Sauceshell, Shell Up, Silent Slam]) && (have_skill($skill[Tattle]) || have_skill($skill[Meteor Lore]))  && possessEquipment($item[Dented Scepter]) && !possessEquipment($item[Battle Broom]) && (get_property("_sl_witchessBattles").to_int() < 5) && have_familiar($familiar[Galloping Grill]) && (my_ascensions() >= 100))
	{
		while((my_mp() < 120) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
		{
			doRest();
		}
		if(equipped_item($slot[weapon]) != $item[Dented Scepter])
		{
			equip($slot[weapon], $item[Dented Scepter]);
		}
		if(equipped_item($slot[acc3]) == $item[none])
		{
			equip($slot[acc3], sl_bestBadge());
		}

		handleFamiliar($familiar[Galloping Grill]);
		buffMaintain($effect[Go Get \'Em\, Tiger!], 0, 1, 1);
		buffMaintain($effect[Glittering Eyelashes], 0, 1, 1);
		buffMaintain($effect[Butt-Rock Hair], 0, 1, 1);
		buffMaintain($effect[Phorcefullness], 0, 1, 1);
		buffMaintain($effect[Tomato Power], 0, 1, 1);
		buffMaintain($effect[Expert Oiliness], 0, 1, 1);
		buffMaintain($effect[Ruthlessly Efficient], 130, 1, 1);
		buffMaintain($effect[Song of Starch], 240, 1, 1);
		buffMaintain($effect[Frostbeard], 130, 1, 1);
		buffMaintain($effect[Intimidating Mien], 130, 1, 1);
		buffMaintain($effect[Takin\' It Greasy], 130, 1, 1);
		buffMaintain($effect[Pyromania], 130, 1, 1);
		buffMaintain($effect[Rotten Memories], 130, 1, 1);
		buffMaintain($effect[Big], 50, 1, 1);
		useCocoon();

		sl_sourceTerminalEducate($skill[Compress], $skill[Extract]);
		boolean result = sl_advWitchess("witch", "cs_combatWitch");
		sl_sourceTerminalEducate($skill[Extract], $skill[Turbo]);
		return result;
	}
	if((my_daycount() == 2) && (my_ascensions() > 200))
	{
		if(((my_hp() * 5) < my_maxhp()) && (my_mp() > 100))
		{
			useCocoon();
		}
		if((my_hp() / 0.8) > my_maxhp())
		{
			if(fightScienceTentacle())
			{
				return true;
			}
			if(evokeEldritchHorror())
			{
				return true;
			}
		}
	}

	if((my_daycount() != 1) && cs_witchess())
	{
		return true;
	}

	if(get_property("_tempRelayCounters") != "")
	{
		print("Setting wanderer flags", "green");
		setAdvPHPFlag();
	}
	asdonAutoFeed(37);

	if(curQuest == 6)
	{
		cheeseWarMachine(0, 0, 3, 0);
//		cheeseWarMachine(0, 1, 3, 0);
		zataraSeaside(my_primestat());
	}
	else if(my_daycount() != 1)
	{
		cheeseWarMachine(0, 2, 1, random(3)+1);
	}

	if((curQuest == 11) || (curQuest == 6) || (curQuest == 9) || (curQuest == 7))
	{
		print("Beginning early quest actions (" + curQuest + ")", "green");
		if(curQuest != 7)
		{
			if((my_inebriety() == 0) && (sl_get_clan_lounge() contains $item[Clan Speakeasy]) && (item_amount($item[Clan VIP Lounge Key]) > 0) && (my_meat() >= 500))
			{
				slDrink(1, $item[Lucky Lindy]);
				if(my_inebriety() != 1)
				{
					if(sl_get_clan_lounge() contains $item[Lucky Lindy])
					{
						print("Confused!! Mafia reports Lucky Lindy but we couldn't drink it?", "red");
					}
					print("Mafia knows we have a speakeasy but could not drink a Lucky Lindy", "red");
					string temp = visit_url("clan_viplounge.php?whichfloor=2&action=speakeasy");
					if(sl_get_clan_lounge() contains $item[Lucky Lindy])
					{
						print("Mafia now knows we have a Lucky Lindy", "green");
						return true;
					}
					else
					{
						abort("Speakeasy issue, could not resolve contents and use them. Try visiting Clan Speakeasy and run again, do not manually drink a Lucky Lindy");
					}
				}
				solveCookie();
			}

			if((my_inebriety() == 0) && !(sl_get_clan_lounge() contains $item[Clan Speakeasy]))
			{
				abort("Your clan does not have a Clan Speakeasy or mafia doesn't understand that you do. Change clans and try again");
			}

			if((item_amount($item[Time-Spinner]) > 0) && (get_property("_timeSpinnerMinutesUsed").to_int() == 0))
			{
				timeSpinnerGet("booze");
			}

			if((inebriety_left() > 9) && (my_inebriety() != 0))
			{
				if((item_amount($item[Shot of Kardashian Gin]) > 0) && hippy_stone_broken())
				{
					if(hippy_stone_broken())
					{
						slDrink(min(item_amount($item[Shot of Kardashian Gin]), (inebriety_left() - 9)), $item[Shot of Kardashian Gin]);
					}
					else
					{
						slOverdrink(min(item_amount($item[Shot of Kardashian Gin]), (inebriety_left() - 9)), $item[Shot of Kardashian Gin]);
					}
				}
				if(item_amount($item[Sacramento Wine]) > 0)
				{
					slDrink(min(item_amount($item[Sacramento Wine]), (inebriety_left() - 9)), $item[Sacramento Wine]);
				}
				else if(item_amount($item[Ice Island Long Tea]) > 0)
				{
					slDrink(1, $item[Ice Island Long Tea]);
				}
				else if((item_amount($item[Splendid Martini]) > 0) && canDrink($item[Splendid Martini]))
				{
					slDrink(min(item_amount($item[Splendid Martini]), (inebriety_left() - 9)), $item[Splendid Martini]);
				}
				else if(item_amount($item[Meadeorite]) > 0)
				{
					slDrink(min(item_amount($item[Meadeorite]), (inebriety_left() - 9)), $item[Meadeorite]);
				}

			}

			if(get_property("sl_csDoWheel").to_boolean() && do_chateauGoat())
			{
				return true;
			}

			if(item_amount($item[A Ten-Percent Bonus]) > 0)
			{
				use(1, $item[A Ten-Percent Bonus]);
			}

			if((curQuest == 11) && ((my_turncount() + 60) < get_property("sl_cookie").to_int()) && (my_adventures() > 65))
			{
				if(do_cs_quest(11))
				{
					use(1, $item[A Ten-Percent Bonus]);
					curQuest = 0;
					cli_execute("postsool");
					return true;
				}
				else
				{
					curQuest = 0;
					abort("Could not handle our quest and can not recover");
				}
			}

			if((curQuest != 11) && (have_effect($effect[substats.enh]) == 0) && (sl_sourceTerminalEnhanceLeft() >= 1))
			{
				sl_sourceTerminalEnhance("substats");
			}

			if(get_property("_sl_witchessBattles").to_int() <= 2)
			{
				if(cs_witchess())
				{
					return true;
				}
			}

			if(get_property("_sl_witchessBattles").to_int() == 3)
			{
				if((my_mp() >= 120) && sl_haveWitchess() && have_skills($skills[Conspiratorial Whispers, Curse Of Weaksauce, Sauceshell, Shell Up, Silent Slam]) && (have_skill($skill[Tattle]) || have_skill($skill[Meteor Lore])) && !possessEquipment($item[Dented Scepter]) && have_familiar($familiar[Galloping Grill]) && (my_ascensions() >= 100))
				{
					handleFamiliar($familiar[Galloping Grill]);
					sl_sourceTerminalEducate($skill[Turbo], $skill[Compress]);
					boolean retval = sl_advWitchess("king", "cs_combatKing");
					sl_sourceTerminalEducate($skill[Compress], $skill[Extract]);
					return retval;
				}
			}

//			if((my_turncount() >= 60) && cs_witchess())
			if(item_amount($item[Sacramento Wine]) == 0)
			{
				//This might end up getting food and we need to consider that....
				if(cs_witchess())
				{
					return true;
				}
			}

			if(do_chateauGoat())
			{
				return true;
			}

			if(!get_property("_chateauMonsterFought").to_boolean() && chateaumantegna_available() && (get_property("chateauMonster") == $monster[dairy goat]))
			{
			}

			if(chateaumantegna_available() && (get_property("chateauMonster") != $monster[dairy goat]) && (my_fullness() == 0) && !get_property("_photocopyUsed").to_boolean())
			{
				if(canYellowRay())
				{
					if(yellowRayCombatString() == ("skill " + $skill[Open a Big Yellow Present]))
					{
						handleFamiliar("yellowray");
					}
					handleFaxMonster($monster[Dairy Goat], "cs_combatYR");
				}
				else
				{
					handleFaxMonster($monster[Dairy Goat], "cs_combatNormal");
				}
				if((item_amount($item[Glass of Goat\'s Milk]) > 0) && (freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && have_skill($skill[Advanced Saucecrafting]))
				{
					if(!have_skills($skills[Expert Corner-Cutter, Rapid Prototyping]) && have_skill($skill[Inigo\'s Incantation of Inspiration]))
					{
						shrugAT($effect[Inigo\'s Incantation of Inspiration]);
						buffMaintain($effect[Inigo\'s Incantation of Inspiration], 100, 1, 5);
					}

					cli_execute("make milk of magnesium");
				}
				return true;
			}

			cs_eat_stuff(0);

			buffMaintain($effect[Singer\'s Faithful Ocelot], 15, 1, 1);
			buffMaintain($effect[Fat Leon\'s Phat Loot Lyric], 11, 1, 1);

			while((my_mp() < 40) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}

			if((internalQuestStatus("questG07Myst") == 1) || (internalQuestStatus("questG08Moxie") == 1) || (internalQuestStatus("questG09Muscle") == 1))
			{
				handleBarrelFullOfBarrels(true);
				visit_url("guild.php?place=challenge");
				if(knoll_available())
				{
					while(LX_bitchinMeatcar());
					visit_url("guild.php?place=paco");
					visit_url("guild.php?place=paco");
					visit_url("guild.php?place=paco");
					run_choice(1);
					woods_questStart();
					if(!florist_available())
					{
						trickMafiaAboutFlorist();
					}
					return true;
				}
			}

			if(my_ascensions() > get_property("lastGuildStoreOpen").to_int())
			{
				location loc = $location[none];
				switch(my_class())
				{
				case $class[Pastamancer]:
				case $class[Sauceror]:
					loc = $location[The Haunted Pantry];
					break;
				case $class[Seal Clubber]:
				case $class[Turtle Tamer]:
					loc = $location[The Outskirts of Cobb\'s Knob];
					break;
				case $class[Accordion Thief]:
				case $class[Disco Bandit]:
					loc = $location[The Sleazy Back Alley];
					break;
				}
				if(loc.turns_spent > 8)
				{
					abort("Could not find the guild quest goal. Could not sudo it. Find it and re-run.");
				}

				buffMaintain($effect[Musk of the Moose], 10, 1, 1);
				slAdv(1, loc, "cs_combatNormal");
				return true;
			}

			int tomatoGoal = 2;
			if(get_property("sl_hccsNoConcludeDay").to_boolean())
			{
				tomatoGoal = 1;
			}

			if((item_amount($item[Tomato]) < tomatoGoal) && have_skill($skill[Advanced Saucecrafting]))
			{
				if(contains_text($location[The Haunted Pantry].combat_queue, to_string($monster[Possessed Can of Tomatoes])))
				{
					if(timeSpinnerCombat($monster[Possessed Can of Tomatoes], "cs_combatNormal"))
					{
						return true;
					}
				}
				buffMaintain($effect[Musk of the Moose], 10, 1, 1);
				if(possessEquipment($item[Latte Lovers Member\'s Mug]) && !get_property("_latteBanishUsed").to_boolean())
				{
					slEquip($slot[Off-Hand], $item[Latte Lovers Member\'s Mug]);
				}
				slAdv(1, $location[The Haunted Pantry], "cs_combatNormal");
				return true;
			}

			if(have_skill($skill[Advanced Saucecrafting]) && ((item_amount($item[Cherry]) < 1) || (item_amount($item[Grapefruit]) < 1) || (item_amount($item[Lemon]) < 1)))
			{
				if(contains_text($location[The Skeleton Store].combat_queue, $monster[Novelty Tropical Skeleton]))
				{
					if(timeSpinnerCombat($monster[Novelty Tropical Skeleton], "cs_combatNormal"))
					{
						return true;
					}
				}
				if((have_effect($effect[On The Trail]) > 0) && (get_property("olfactedMonster") != to_string($monster[Novelty Tropical Skeleton])))
				{
					uneffect($effect[On The Trail]);
				}
				if(possessEquipment($item[Latte Lovers Member\'s Mug]))
				{
					if(get_property("_latteBanishUsed").to_boolean())
					{
						string opt1 = "S5ENw2oLpIrV44T64s7HS5GWxbdWfEajGLH6d5fPSyfFosMI94DC95VSyT3qR8kAeGhHMHZXV3Zobll3ZXF4WjZsdmxpQT09";
						string opt2 = "GasfMOkRT1QCrz1G7H9+lq6VcmDt65ZFLGVetRLQqa4vvoHHsWsa15LiGylFwCssT2oyYWJUL3E5Tmc5VmRvWWhqajdVQT09";
						string opt3 = "MUnOlP/vCrCbI5Kxs7WHG8aGvILUb0IFgi9p/vZOuAhivrjV6NL3ad97awbNvTU9MmNqZzFmR2RUbXg2TC9XYXRuNldjUT09";

						string page = visit_url("main.php?latte=1", false);
						string url = "choice.php?pwd=&whichchoice=1329&option=1&l1=" + opt1 + "&l2=" + opt2 + "&l3=" + opt3;
						page = visit_url(url);
					}
					slEquip($slot[Off-Hand], $item[Latte Lovers Member\'s Mug]);
				}

				if(item_amount($item[skeleton key]) == 0)
				{
					if((item_amount($item[skeleton bone]) > 0) && (item_amount($item[loose teeth]) > 0))
					{
						cli_execute("make " + $item[Skeleton Key]);
					}
				}
				set_property("choiceAdventure1060", 2);
				slAdv(1, $location[The Skeleton Store], "cs_combatNormal");
				return true;
			}

			if((get_property("dnaSyringe") == $phylum[pirate]) && (get_property("_dnaPotionsMade").to_int() == 0))
			{
				cli_execute("camp dnapotion");
			}

			if((item_amount($item[Gene Tonic: Pirate]) == 0) && (get_property("_dnaPotionsMade").to_int() < 3) && (item_amount($item[DNA Extraction Syringe]) > 0) && elementalPlanes_access($element[stench]))
			{
				slAdv(1, $location[Pirates of the Garbage Barges], "cs_combatNormal");
				return true;
			}

			if((get_property("dnaSyringe") == $phylum[elemental]) && (get_property("_dnaPotionsMade").to_int() == 1))
			{
				cli_execute("camp dnapotion");
			}

			if((((item_amount($item[Gene Tonic: Elemental]) == 0) && (get_property("_dnaPotionsMade").to_int() < 3)) || !get_property("_dnaHybrid").to_boolean()) && (item_amount($item[DNA Extraction Syringe]) > 0) && elementalPlanes_access($element[hot]))
			{
				buffMaintain($effect[Reptilian Fortitude], 8, 1, 1);
				buffMaintain($effect[Power Ballad of the Arrowsmith], 5, 1, 1);

				buffMaintain($effect[Astral Shell], 10, 1, 1);
				buffMaintain($effect[Ghostly Shell], 6, 1, 1);
				buffMaintain($effect[Blubbered Up], 7, 1, 1);
				buffMaintain($effect[Springy Fusilli], 10, 1, 1);
				buffMaintain($effect[The Moxious Madrigal], 2, 1, 1);
				buffMaintain($effect[Cletus\'s Canticle of Celerity], 4, 1, 1);
				buffMaintain($effect[Walberg\'s Dim Bulb], 5, 1, 1);

				useCocoon();

				slAdv(1, $location[The Bubblin\' Caldera], "cs_combatNormal");
				if((have_effect($effect[Beaten Up]) > 0) && have_skill($skill[Tongue of the Walrus]) && (my_mp() > (3 * mp_cost($skill[Tongue of the Walrus]))))
				{
					if(contains_text(get_property("sl_combatHandler"), "(DNA)"))
					{
						use_skill(2, $skill[Tongue of the Walrus]);
					}
					else
					{
						set_property("sl_beatenUpCount", get_property("sl_beatenUpCount").to_int() + 1);
					}
				}
				return true;
			}

			if(have_effect($effect[Drenched in Lava]) > 0)
			{
				doHottub();
			}

#			if(((get_property("_g9Effect").to_int() > 125) || (item_amount($item[Airborne Mutagen]) == 0)) && (((curQuest == 9) || (my_turncount() < get_property("sl_cookie").to_int())) && elementalPlanes_access($element[spooky])))
			if(((curQuest == 9) || (my_turncount() < get_property("sl_cookie").to_int())) && elementalPlanes_access($element[spooky]))
			{
				if((isOverdueDigitize() || isOverdueArrow()) && elementalPlanes_access($element[stench]))
				{
					print("A Wanderer event is expected now.", "blue");
					slAdv(1, $location[Barf Mountain], "cs_combatNormal");
					return true;
				}

				if(item_amount($item[Personal Ventilation Unit]) > 0)
				{
					slEquip($slot[acc1], $item[Personal Ventilation Unit]);
				}
				int turns_max = 10;
				if(have_skill($skill[CLEESH]))
				{
					turns_max = 18;
				}
				if($location[The Secret Government Laboratory].turns_spent <= turns_max)
				{
					buffMaintain($effect[Singer\'s Faithful Ocelot], 47, 1, 1);
					buffMaintain($effect[Fat Leon\'s Phat Loot Lyric], 43, 1, 1);

					if(contains_text($location[The Secret Government Laboratory].combat_queue, $monster[Government Scientist]))
					{
						if(timeSpinnerCombat($monster[Government Scientist], "cs_combatNormal"))
						{
							return true;
						}
					}

					if(possessEquipment($item[Latte Lovers Member\'s Mug]) && !get_property("_latteCopyUsed").to_boolean())
					{
						slEquip($slot[Off-Hand], $item[Latte Lovers Member\'s Mug]);
					}

					slAdv(1, $location[The Secret Government Laboratory], "cs_combatNormal");
					return true;
				}
			}
		}
		else if((curQuest == 7) && (item_amount($item[Emergency Margarita]) > 0))
		{
			buffMaintain($effect[Sweetbreads Flamb&eacute;], 0, 1, 1);
			if((have_effect($effect[substats.enh]) == 0) && (sl_sourceTerminalEnhanceLeft() >= 1))
			{
				sl_sourceTerminalEnhance("substats");
			}

			if((inebriety_left() > 0) && (my_adventures() <= 2))
			{
				if(item_amount($item[Astral Pilsner]) > 0)
				{
					slDrink(min(inebriety_left(), item_amount($item[Astral Pilsner])), $item[Astral Pilsner]);
				}
				else if(item_amount($item[Sacramento Wine]) > 0)
				{
					slDrink(1, $item[Sacramento Wine]);
				}
				else if(item_amount($item[Iced Plum Wine]) > 0)
				{
					slDrink(1, $item[Iced Plum Wine]);
				}
				else if(item_amount($item[Meadeorite]) > 0)
				{
					slDrink(1, $item[Meadeorite]);
				}
				else if((sl_get_clan_lounge() contains $item[Clan Speakeasy]) && (item_amount($item[Clan VIP Lounge Key]) > 0))
				{
					slDrink(1, $item[cup of &quot;tea&quot;]);
				}
			}

			if((my_spleen_use() == 12) && (item_amount($item[Abstraction: Category]) > 0))
			{
				slChew(1, $item[Abstraction: Category]);
			}
			if(!get_property("_aprilShower").to_boolean())
			{
				cli_execute("shower myst");
			}
			if(item_amount($item[Flavored Foot Massage Oil]) > 0)
			{
				string temp = visit_url("curse.php?action=use&pwd=&whichitem=3274&targetplayer=" + get_player_id(my_name()));
			}

			if((isOverdueDigitize() || isOverdueArrow()) && elementalPlanes_access($element[stench]) && (get_property("_sl_margaritaWanderer") != my_turncount()))
			{
				set_property("_sl_margaritaWanderer", my_turncount());
				print("A Wanderer event is expected now, diverting... (Status: 7 with Margarita)", "blue");
				slAdv(1, $location[Barf Mountain], "cs_combatNormal");
				return true;
			}

			if(!get_property("sl_hccsNoConcludeDay").to_boolean())
			{
				if(have_familiar($familiar[Machine Elf]) && (get_property("_machineTunnelsAdv").to_int() < 5) && (my_adventures() > 0) && !is100FamiliarRun($familiar[Machine Elf]))
				{
					backupSetting("choiceAdventure1119", 1);
					handleFamiliar($familiar[Machine Elf]);
					slAdv(1, $location[The Deep Machine Tunnels]);
					restoreSetting("choiceAdventure1119");
					set_property("choiceAdventure1119", "");
					return true;
				}

				if(have_familiar($familiar[Machine Elf]) && (get_property("_machineTunnelsAdv").to_int() == 5) && ($location[The Deep Machine Tunnels].turns_spent == 5) && (my_adventures() > 0) && !is100FamiliarRun($familiar[Machine Elf]))
				{
					backupSetting("choiceAdventure1119", 1);
					handleFamiliar($familiar[Machine Elf]);
					slAdv(1, $location[The Deep Machine Tunnels]);
					restoreSetting("choiceAdventure1119");
					set_property("choiceAdventure1119", "");
					return true;
				}
			}

			if(canYellowRay() && elementalPlanes_access($element[hot]))
			{
				string yellowRay = yellowRayCombatString();
				if(yellowRay == ("skill " + $skill[Open a Big Yellow Present]))
				{
					handleFamiliar("yellowray");
				}
				if((!possessEquipment($item[Heat-Resistant Necktie]) || !possessEquipment($item[Heat-Resistant Gloves]) || !possessEquipment($item[Lava-Proof Pants])) && $location[LavaCo&trade; Lamp Factory].turns_spent < 10)
				{
					print("Adventuring in LavaCo using the yellow ray source: " + yellowRay, "blue");
					slAdv(1, $location[LavaCo&trade; Lamp Factory], "cs_combatYR");
					return true;
				}
			}

			boolean turnSave = get_property("sl_hccsTurnSave").to_boolean() || !in_hardcore();

			if((my_meat() > 100) && (item_amount($item[Hot Ashes]) > 0) && (item_amount($item[Ash Soda]) == 0))
			{
				buyUpTo(1, $item[Soda Water]);
				cli_execute("make 1 " + $item[Ash Soda]);
			}

			if(!turnSave && (item_amount($item[Black Pixel]) < 2) && (item_amount($item[Pixel Star]) == 0) && (have_familiar($familiar[Puck Man]) || have_familiar($familiar[Ms. Puck Man])) && knoll_available())
			{
				slEquip($slot[acc1], $item[Continuum Transfunctioner]);

				if(get_property("sl_tryPowerLevel").to_boolean())
				{
					buffMaintain($effect[Ur-Kel\'s Aria of Annoyance], 62, 1, 1);
					buffMaintain($effect[Pride of the Puffin], 62, 1, 1);
					buffMaintain($effect[Drescher\'s Annoying Noise], 72, 1, 1);
					buffMaintain(whatStatSmile(), 42, 1, 1);
				}

				slAdv(1, $location[8-bit Realm], "cs_combatNormal");
				return true;
			}

			if(!(sl_get_campground() contains $item[Dramatic&trade; Range]))
			{
				if(my_meat() > npc_price($item[Dramatic&trade; Range]))
				{
					buy(1, $item[Dramatic&trade; Range]);
					use(1, $item[Dramatic&trade; Range]);
				}
			}

			if(have_skill($skill[Advanced Saucecrafting]) && (sl_get_campground() contains $item[Dramatic&trade; Range]))
			{
				int tomatoCheck = 4;
				int tomatoMake = 6;
				if(my_class() != $class[Sauceror])
				{
					tomatoCheck = 2;
					tomatoMake = 2;
				}
				if(get_property("sl_hccsNoConcludeDay").to_boolean())
				{
					tomatoCheck = 1;
					tomatoMake = 1;
				}
				if((item_amount($item[Tomato Juice of Powerful Power]) < tomatoCheck) && (freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) >= 2) && have_skill($skill[Advanced Saucecrafting]))
				{
					if(!have_skills($skills[Expert Corner-Cutter, Rapid Prototyping]) && have_skill($skill[Inigo\'s Incantation of Inspiration]))
					{
						shrugAT($effect[Inigo\'s Incantation of Inspiration]);
						buffMaintain($effect[Inigo\'s Incantation of Inspiration], 100, 1, 10);
					}

					cli_execute("make " + tomatoMake + " " + $item[Tomato Juice Of Powerful Power]);
				}
			}

			int pixelsNeed = 30 - (15 * item_amount($item[Miniature Power Pill]));
			# Account for possible pixels from Snojo?
			# Make sure for tryPowerLevel not to go too high in ML (75).

			buffMaintain($effect[Glittering Eyelashes], 0, 1, 1);
			buffMaintain($effect[Ur-Kel\'s Aria of Annoyance], 62, 1, 1);
			buffMaintain($effect[Pride of the Puffin], 62, 1, 1);
			buffMaintain($effect[Drescher\'s Annoying Noise], 72, 1, 1);
			buffMaintain(whatStatSmile(), 42, 1, 1);
			buffMaintain($effect[Empathy], 47, 1, 1);
			buffMaintain($effect[Leash of Linguini], 44, 1, 1);
			buffMaintain($effect[Ruthlessly Efficient], 42, 1, 1);
			buffMaintain($effect[The Magical Mojomuscular Melody], 12, 1, 1);
			if(item_amount($item[Tomato Juice of Powerful Power]) > 4)
			{
				buffMaintain($effect[Tomato Power], 0, 1, 1);
			}
			if(((my_hp() + 50) < my_maxhp()) && (my_mp() > 100))
			{
				useCocoon();
			}

			boolean doFarm = false;
			if(!have_familiar($familiar[Puck Man]) && !have_familiar($familiar[Ms. Puck Man]) && (get_property("sl_csPuckCounter").to_int() > 0))
			{
				set_property("sl_csPuckCounter", get_property("sl_csPuckCounter").to_int() - 1);
				doFarm = true;
			}
			if(((item_amount($item[Power Pill]) < 2) || (item_amount($item[Yellow Pixel]) < pixelsNeed)) && (have_familiar($familiar[Puck Man]) || have_familiar($familiar[Ms. Puck Man])))
			{
				if(is100familiarRun() && is100familiarRun($familiar[Puck Man]) && is100familiarRun($familiar[Ms. Puck Man]))
				{}
				else
				{
					doFarm = true;
				}
			}

			if(possessEquipment($item[KoL Con 13 Snowglobe]) && (equipped_item($slot[Off-Hand]) == $item[A Light That Never Goes Out]))
			{
				equip($slot[Off-hand], $item[KoL Con 13 Snowglobe]);
				if(have_skill($skill[Pulverize]))
				{
					pulverizeThing($item[A Light That Never Goes Out]);
				}
				else
				{
					put_closet(1, $item[A Light That Never Goes Out]);
				}
				return true;
			}
			if(possessEquipment($item[Latte Lovers Member\'s Mug]) && (equipped_item($slot[Off-Hand]) == $item[A Light That Never Goes Out]))
			{
				equip($slot[Off-hand], $item[Latte Lovers Member\'s Mug]);
				if(have_skill($skill[Pulverize]))
				{
					pulverizeThing($item[A Light That Never Goes Out]);
				}
				else
				{
					put_closet(1, $item[A Light That Never Goes Out]);
				}
				return true;
			}

			if(turnSave)
			{
				doFarm = false;
			}

			if(doFarm)
			{
				if(get_property("sl_tryPowerLevel").to_boolean())
				{
					print("Trying to powerlevel, since sl_tryPowerLevel=true", "blue");
					if(elementalPlanes_access($element[stench]) && (my_hp() > 100))
					{
						if(current_mcd() < 10)
						{
							sl_change_mcd(11);
						}
						if(item_amount($item[Astral Statuette]) > 0)
						{
							equip($item[Astral Statuette]);
						}

						if(have_skill($skill[Soul Food]))
						{
							use_skill(my_soulsauce() / 5, $skill[Soul Food]);
						}

						buyUpTo(1, $item[Hair Spray]);
						buyUpTo(1, $item[Ben-Gal&trade; Balm]);
						buffMaintain($effect[Go Get \'Em\, Tiger!], 0, 1, 1);
						buffMaintain($effect[Butt-Rock Hair], 0, 1, 1);
						buffMaintain($effect[Unrunnable Face], 0, 1, 1);

						buffMaintain($effect[Astral Shell], 42, 1, 1);
						buffMaintain($effect[Elemental Saucesphere], 42, 1, 1);
						buffMaintain($effect[Big], 35, 1, 1);
						buffMaintain($effect[Brawnee\'s Anthem of Absorption], 45, 1, 1);
						buffMaintain($effect[Jalape&ntilde;o Saucesphere], 37, 1, 1);
						buffMaintain($effect[Ghostly Shell], 38, 1, 1);
						buffMaintain($effect[Reptilian Fortitude], 42, 1, 1);
						buffMaintain($effect[Power Ballad of the Arrowsmith], 37, 1, 1);
						buffMaintain($effect[The Moxious Madrigal], 34, 1, 1);
						buffMaintain($effect[Patience of the Tortoise], 33, 1, 1);
						buffMaintain($effect[Seal Clubbing Frenzy], 33, 1, 1);
						buffMaintain($effect[Mariachi Mood], 33, 1, 1);
						buffMaintain($effect[Disco State of Mind], 33, 1, 1);
						buffMaintain($effect[Saucemastery], 33, 1, 1);
						buffMaintain($effect[Blubbered Up], 39, 1, 1);
						buffMaintain($effect[Spiky Shell], 40, 1, 1);
						buffMaintain($effect[Song of Starch], 132, 1, 1);
						buffMaintain($effect[Rage of the Reindeer], 42, 1, 1);
						buffMaintain($effect[Scarysauce], 42, 1, 1);
						buffMaintain($effect[Disco Fever], 42, 1, 1);

#						if((have_effect($effect[The Dinsey Look]) == 0) && (item_amount($item[FunFunds&trade;]) > 0))
#						{
#							cli_execute("make dinsey face paint");
#						}
#						buffMaintain($effect[The Dinsey Look], 0, 1, 1);
#						buffMaintain($effect[Flexibili Tea], 0, 1, 1);
						buffMaintain($effect[Neuroplastici Tea], 0, 1, 1);
#						buffMaintain($effect[Physicali Tea], 0, 1, 1);


						if((get_property("_hipsterAdv").to_int() < 1) && have_familiar($familiar[Artistic Goth Kid]))
						{
							handleFamiliar($familiar[Artistic Goth Kid]);
						}
						else if((get_property("_hipsterAdv").to_int() < 1) && have_familiar($familiar[Mini-Hipster]))
						{
							handleFamiliar($familiar[Mini-Hipster]);
						}

						if(elementalPlanes_access($element[stench]))
						{
							slAdv(1, $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice], "cs_combatNormal");
							return true;
						}
					}
				}

#				if((elementalPlanes_access($element[hot])) && (item_amount($item[New Age Healing Crystal]) < 2))
#				{
#					slAdv(1, $location[The Velvet / Gold Mine], "cs_combatNormal");
#				}
				if(get_property("controlPanel9").to_boolean())
				{
					if(item_amount($item[Personal Ventilation Unit]) > 0)
					{
						slEquip($slot[acc1], $item[Personal Ventilation Unit]);
					}
					slAdv(1, $location[The Secret Government Laboratory], "cs_combatNormal");
				}
				else if(elementalPlanes_access($element[cold]))
				{
					if(!get_property("_VYKEALoungeRaided").to_boolean())
					{
						backupSetting("choiceAdventure1115", 4);
					}
					else
					{
						backupSetting("choiceAdventure1115", 6);
					}
				
					slAdv(1, $location[VYKEA], "cs_combatNormal");
				}
				else if(elementalPlanes_access($element[hot]))
				{
					slAdv(1, $location[The Velvet / Gold Mine], "cs_combatNormal");
				}
				else if(knoll_available())
				{
					slAdv(1, $location[8-bit Realm], "cs_combatNormal");
				}
				else
				{
					slAdv(1, $location[The Thinknerd Warehouse], "cs_combatNormal");
				}
				return true;
			}

			if(!get_property("sl_tryPowerLevel").to_boolean())
			{
				sl_change_mcd(0);
			}

			int missing = 0;
			if(!have_skill($skill[Advanced Saucecrafting]))
			{
				missing = missing + 1;
			}
			if(!elementalPlanes_access($element[spooky]))
			{
				missing = missing + 1;
			}
			if(!elementalPlanes_access($element[hot]))
			{
				missing = missing + 1;
			}
			missing = min(2, missing);

			if((have_effect($effect[Half-Blooded]) > 0) || (have_effect($effect[Half-Drained]) > 0) || (have_effect($effect[Bruised]) > 0) || (have_effect($effect[Relaxed Muscles]) > 0) || (have_effect($effect[Hypnotized]) > 0) || (have_effect($effect[Bad Haircut]) > 0))
			{
				doHottub();
			}

			if(turnSave)
			{
				missing = 0;
			}
			if((missing > (item_amount($item[Miniature Power Pill]) + item_amount($item[Power Pill]))) && (have_familiar($familiar[Puck Man]) || have_familiar($familiar[Ms. Puck Man])) && (!is100familiarRun() || !is100familiarRun($familiar[Puck Man]) || !is100familiarRun($familiar[Ms. Puck Man])))
			{
				if(elementalPlanes_access($element[hot]))
				{
					slAdv(1, $location[The Velvet / Gold Mine], "cs_combatNormal");
				}
				else if(elementalPlanes_access($element[stench]))
				{
					slAdv(1, $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice], "cs_combatNormal");
				}
				else if(elementalPlanes_access($element[spooky]))
				{
					slAdv(1, $location[The Deep Dark Jungle], "cs_combatNormal");
				}
				else if(elementalPlanes_access($element[sleaze]))
				{
					slAdv(1, $location[Sloppy Seconds Diner], "cs_combatNormal");
				}
				else
				{
					slAdv(1, $location[The Haunted Kitchen], "cs_combatNormal");
				}
				if(item_amount($item[Yellow Pixel]) >= 15)
				{
					cli_execute("make miniature power pill");
				}
				return true;
			}

			if((canYellowRay() || (numeric_modifier("item drop") >= 150.0)) && !get_property("_photocopyUsed").to_boolean() && ($classes[Pastamancer, Sauceror] contains my_class()))
			{
				if(yellowRayCombatString() == ("skill " + $skill[Open a Big Yellow Present]))
				{
					handleFamiliar("yellowray");
				}
				string combatString = "cs_combatYR";
				if(numeric_modifier("item drop") >= 150.0)
				{
					combatString = "cs_combatNormal";
				}

				sl_sourceTerminalEducate($skill[Duplicate], $skill[Extract]);
				useCocoon();
				if(handleFaxMonster($monster[Sk8 gnome], combatString))
				{
					return true;
				}
				sl_sourceTerminalEducate($skill[Extract], $skill[Portscan]);
			}

			if(elementalPlanes_access($element[hot]) && have_skills($skills[Meteor Lore, Snokebomb]) && have_familiar($familiar[XO Skeleton]) && (my_mp() > mp_cost($skill[Snokebomb])) && (get_property("_snokebombUsed").to_int() < 3) && (get_property("_macrometeoriteUses").to_int() < 10) && (get_property("_xoHugsUsed").to_int() < 11) && !is100FamiliarRun($familiar[XO Skeleton]))
			{
				if((!possessEquipment($item[Fireproof Megaphone]) && !possessEquipment($item[Meteorite Guard])) || !possessEquipment($item[High-Temperature Mining Mask]))
				{
					handleFamiliar($familiar[XO Skeleton]);
					slAdv(1, $location[The Velvet / Gold Mine], "cs_combatXO");
					return true;
				}
				if(!possessEquipment($item[Heat-Resistant Necktie]) || !possessEquipment($item[Heat-Resistant Gloves]) || !possessEquipment($item[Lava-Proof Pants]))
				{
					handleFamiliar($familiar[XO Skeleton]);
					slAdv(1, $location[LavaCo&trade; Lamp Factory], "cs_combatXO");
					return true;
				}
			}

			if(have_skill($skill[Advanced Saucecrafting]) && (sl_get_campground() contains $item[Dramatic&trade; Range]))
			{
				int tomatoMake = 6;
				int tomatoCheck = 4;
				int expertiseCheck = 2;
				if(my_class() != $class[Sauceror])
				{
					tomatoMake = 2;
					tomatoCheck = 2;
					expertiseCheck = 1;
				}
				if(get_property("sl_hccsNoConcludeDay").to_boolean())
				{
					tomatoCheck = 1;
					tomatoMake = 1;
					expertiseCheck = 1;
				}
				if(!have_skill($skill[Rapid Prototyping]) && have_skill($skill[Inigo\'s Incantation of Inspiration]))
				{
					shrugAT($effect[Inigo\'s Incantation of Inspiration]);
					buffMaintain($effect[Inigo\'s Incantation of Inspiration], 100, 3, 25);
				}

				if((item_amount($item[Oil of Expertise]) < expertiseCheck) && (freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0))
				{
					cli_execute("make " + $item[Oil Of Expertise]);
				}
				if((item_amount($item[Tomato Juice of Powerful Power]) < tomatoCheck) && (freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 1))
				{
					cli_execute("make " + tomatoMake + " " + $item[Tomato Juice Of Powerful Power]);
				}

				if((item_amount($item[grapefruit]) > 0) && (item_amount($item[Ointment of the Occult]) == 0) && (item_amount($item[Scrumptious Reagent]) > 0))
				{
					cli_execute("make " + $item[Ointment Of The Occult]);
				}
				else if((item_amount($item[squashed frog]) > 0) && (item_amount($item[Frogade]) == 0) && (item_amount($item[Scrumptious Reagent]) > 0))
				{
					cli_execute("make " + $item[Frogade]);
				}
				else if((item_amount($item[eye of newt]) > 0) && (item_amount($item[Eyedrops of Newt]) == 0) && (item_amount($item[Scrumptious Reagent]) > 0))
				{
					cli_execute("make " + $item[Eyedrops Of Newt]);
				}
				else if((item_amount($item[salamander spleen]) > 0) && (item_amount($item[Salamander Slurry]) == 0) && (item_amount($item[Scrumptious Reagent]) > 0))
				{
					cli_execute("make " + $item[Salamander Slurry]);
				}
			}

//			if(my_ascensions() > 200)
//			{
//				fightScienceTentacle();
//				evokeEldritchHorror();
//			}

			if(!get_property("sl_hccsNoConcludeDay").to_boolean())
			{
				uneffect($effect[Ode To Booze]);
				zataraSeaside(my_primestat());
				buffMaintain($effect[Polka Of Plenty], 30, 1, 10 - get_property("_neverendingPartyFreeTurns").to_int());
				songboomSetting($item[Gathered Meat-Clip]);
				if(snojoFightAvailable() && (my_adventures() > 0))
				{
					familiar oldFam = my_familiar();
					if(have_familiar($familiar[Rockin\' Robin]) && (item_amount($item[Robin\'s Egg]) == 0))
					{
						handleFamiliar($familiar[Rockin\' Robin]);
					}
					else if(have_familiar($familiar[Garbage Fire]) && (item_amount($item[Burning Newspaper]) == 0))
					{
						handleFamiliar($familiar[Garbage Fire]);
					}
					else if(have_familiar($familiar[Optimistic Candle]) && (item_amount($item[Glob Of Melted Wax]) == 0))
					{
						handleFamiliar($familiar[Optimistic Candle]);
					}
					slAdv(1, $location[The X-32-F Combat Training Snowman]);
					handleFamiliar(oldFam);
					return true;
				}

				//Consider checking for all Snojo debuffs.
				if(have_effect($effect[Hypnotized]) > 0)
				{
					doHottub();
				}

				if(neverendingPartyAvailable() && (my_adventures() > 0))
				{
					familiar oldFam = my_familiar();
					if(have_familiar($familiar[Rockin\' Robin]) && (item_amount($item[Robin\'s Egg]) == 0))
					{
						handleFamiliar($familiar[Rockin\' Robin]);
					}
					else if(have_familiar($familiar[Garbage Fire]) && (item_amount($item[Burning Newspaper]) == 0))
					{
						handleFamiliar($familiar[Garbage Fire]);
					}
					else if(have_familiar($familiar[Optimistic Candle]) && (item_amount($item[Glob Of Melted Wax]) == 0))
					{
						handleFamiliar($familiar[Optimistic Candle]);
					}
					neverendingPartyCombat();
					handleFamiliar(oldFam);
					return true;
				}

				if((spleen_left() >= 3) && (item_amount($item[Handful of Smithereens]) > 0))
				{
					slChew(1, $item[Handful of Smithereens]);
				}
				if((spleen_left() >= 2) && (item_amount($item[Handful of Smithereens]) > 1))
				{
					slChew(1, $item[Handful of Smithereens]);
				}
				while((spleen_left() >= 2) && (item_amount($item[cuppa Activi tea]) > 0))
				{
					slChew(1, $item[cuppa Activi tea]);
				}
				while((spleen_left() >= 2) && (item_amount($item[Nasty Snuff]) > 0))
				{
					slChew(1, $item[Nasty Snuff]);
				}
				if((item_amount($item[Astral Pilsner]) > 0) && (inebriety_left() > 0) && (my_level() >= 11))
				{
					slDrink(min(inebriety_left(), item_amount($item[Astral Pilsner])), $item[Astral Pilsner]);
				}

				if((item_amount($item[CSA fire-starting kit]) > 0) && !get_property("_fireStartingKitUsed").to_boolean() && (get_property("choiceAdventure595").to_int() == 1) && hippy_stone_broken())
				{
					use(1, $item[CSA Fire-Starting Kit]);
				}

				if(!get_property("_lookingGlass").to_boolean())
				{
					string page = visit_url("clan_viplounge.php?action=lookingglass", false);
				}
				if(!get_property("_madTeaParty").to_boolean())
				{
					if(!possessEquipment($item[Mariachi Hat]))
					{
						acquireGumItem($item[Mariachi Hat]);
					}
					cli_execute("hatter 11");
				}
				if(get_property("spacegateVaccine2").to_boolean() && !get_property("_spacegateVaccine").to_boolean() && (have_effect($effect[Broad-Spectrum Vaccine]) == 0) && get_property("spacegateAlways").to_boolean())
				{
					cli_execute("spacegate vaccine 2");
				}
				if((get_property("puzzleChampBonus").to_int() == 20) && !get_property("_witchessBuff").to_boolean())
				{
					visit_url("campground.php?action=witchess");
					visit_url("choice.php?whichchoice=1181&pwd=&option=3");
					visit_url("choice.php?whichchoice=1183&pwd=&option=2");
				}
				while(cs_witchess());
				while(godLobsterCombat());

				if((get_property("frAlways").to_boolean() || get_property("_frToday").to_boolean()) && !possessEquipment($item[FantasyRealm G. E. M.]))
				{
					visit_url("place.php?whichplace=realm_fantasy&action=fr_initcenter", false);
					visit_url("choice.php?whichchoice=1280&pwd=&option=3");
				}
			}

			if(!get_property("sl_saveMargarita").to_boolean() && (inebriety_left() == 0))
			{
				if((my_adventures() > 160) || (my_daycount() > 1))
				{
					abort("We have an emergency margarita but it seems really dumb to drink it right now (consider closeting the margarita and set sl_saveMargarita = true)...");
				}
				buffMaintain($effect[Simmering], 0, 1, 1);
				if((inebriety_left() == 0) && have_familiar($familiar[Stooper]))
				{
					use_familiar($familiar[Stooper]);
					foreach it in $items[Splendid Martini, Meadeorite, Sacramento Wine, Cold One]
					{
						if(item_amount(it) > 0)
						{
							slDrink(1, it);
							break;
						}
					}
				}
				buffMaintain($effect[Ode to Booze], 50, 1, 10);
				slOverdrink(1, $item[Emergency Margarita]);
			}
			else
			{
				put_closet(item_amount($item[Emergency Margarita]), $item[Emergency Margarita]);
				if((item_amount($item[Hacked Gibson]) == 0) && (inebriety_left() == 0))
				{
					sl_sourceTerminalExtrude($item[Hacked Gibson]);
				}

				if(!in_hardcore())
				{
					abort("Softcore Community Service, end of term.");
				}

				if((inebriety_left() == 0) && have_familiar($familiar[Stooper]) && ((40 + my_adventures() + numeric_modifier("Adventures")) < 175))
				{
					use_familiar($familiar[Stooper]);
					foreach it in $items[Splendid Martini, Meadeorite, Sacramento Wine, Cold One]
					{
						if(item_amount(it) > 0)
						{
							slDrink(1, it);
							break;
						}
					}
				}

				set_property("sl_familiarChoice", "");
				abort("Saving Emergency Margarita, forcing abort, done with day. Overdrink, cast simmer,  and run again.");
			}



			return true;
		}
	}

	print("Past early quest actions, considering completing a service...", "green");
	int checkQuest = expected_next_cs_quest();
	if(checkQuest != curQuest)
	{
		print("Quest data error detected, trying to resolve. Please don't do quests manually, it hurts me!", "red");
		curQuest = checkQuest;
		return true;
	}

	familiar prior = my_familiar();
	switch(curQuest)
	{
	case 0:
		{
			print("Service Complete, finishing finish...", "blue");
			try
			{
				if(do_cs_quest(30))
				{
					cli_execute("call kingsool");
					return true;
				}
				else
				{
					abort("Could not complete run.");
				}
			}
			finally
			{
				print("Waiting a few seconds, please hold.", "red");
				wait(5);
				if(get_property("kingLiberated").to_boolean())
				{
					cli_execute("call kingsool");
					return true;
				}
				else
				{
					abort("kingLiberation not set correctly but run is probably complete. Beep boop. Try running again to handle resetting options");
				}
			}
		}
		break;

	case 1:		#HP Quest
		{
#			if(!possessEquipment($item[Barrel Lid]) && get_property("barrelShrineUnlocked").to_boolean() && !get_property("_barrelPrayer").to_boolean())
#			{
#				boolean buff = cli_execute("barrelprayer Protection");
#			}

			if(possessEquipment($item[Barrel Lid]))
			{
				equip($item[Barrel Lid]);
			}
			januaryToteAcquire($item[Wad Of Used Tape]);

			if(item_amount($item[Ben-Gal&trade; Balm]) == 0)
			{
				buyUpTo(1, $item[Ben-Gal&trade; Balm], 25);
			}

			while(((total_free_rests() - get_property("timesRested").to_int()) > 4) && chateaumantegna_available())
			{
				cli_execute("postsool");
				doRest();
			}

			if((item_amount($item[lemon]) > 0) && (item_amount($item[philter of phorce]) == 0) && (have_effect($effect[Phorcefullness]) == 0) && (freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && have_skill($skill[Advanced Saucecrafting]))
			{
				if(!have_skills($skills[Expert Corner-Cutter, Rapid Prototyping]) && have_skill($skill[Inigo\'s Incantation of Inspiration]))
				{
					shrugAT($effect[Inigo\'s Incantation of Inspiration]);
					buffMaintain($effect[Inigo\'s Incantation of Inspiration], 100, 1, 5);
				}
				cli_execute("make " + $item[Philter Of Phorce]);
			}

			while((my_mp() < 125) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}

			if(!get_property("_lyleFavored").to_boolean())
			{
				string temp = visit_url("place.php?whichplace=monorail&action=monorail_lyle");
			}

			if((get_property("_g9Effect").to_int() == 0) && (item_amount($item[Experimental Serum G-9]) > 0))
			{
				string temp = visit_url("desc_effect.php?whicheffect=af64d06351a3097af52def8ec6a83d9b", false);
			}
			buffMaintain($effect[Quiet Determination], 10, 1, 1);
			buffMaintain($effect[Big], 15, 1, 1);
			buffMaintain($effect[Song of Starch], 100, 1, 1);
			buffMaintain($effect[Reptilian Fortitude], 10, 1, 1);
			buffMaintain($effect[Rage of the Reindeer], 10, 1, 1);
			buffMaintain($effect[Power Ballad of the Arrowsmith], 10, 1, 1);
			buffMaintain($effect[Seal Clubbing Frenzy], 1, 1, 1);
			buffMaintain($effect[Patience of the Tortoise], 1, 1, 1);
			buffMaintain($effect[Mariachi Mood], 1, 1, 1);
			buffMaintain($effect[Saucemastery], 1, 1, 1);
			buffMaintain($effect[Disco State of Mind], 1, 1, 1);
			buffMaintain($effect[Pasta Oneness], 1, 1, 1);
			buffMaintain($effect[Disdain of the War Snapper], 15, 1, 1);
			buffMaintain($effect[A Few Extra Pounds], 10, 1, 1);

			buffMaintain($effect[Lycanthropy\, Eh?], 0, 1, 1);
			buffMaintain($effect[Expert Oiliness], 0, 1, 1);
			buffMaintain($effect[Phorcefullness], 0, 1, 1);
			buffMaintain($effect[Tomato Power], 0, 1, 1);
			buffMaintain($effect[Puddingskin], 0, 1, 1);
			buffMaintain($effect[Superheroic], 0, 1, 1);
			buffMaintain($effect[Extra Backbone], 0, 1, 1);
			buffMaintain($effect[Pill Power], 0, 1, 1);
			buffMaintain($effect[Go Get \'Em\, Tiger!], 0, 1, 1);

			buffMaintain($effect[Frog in Your Throat], 0, 1, 1);
			buffMaintain($effect[Feroci Tea], 0, 1, 1);
			buffMaintain($effect[Vitali Tea], 0, 1, 1);
			buffMaintain($effect[Twen Tea], 0, 1, 1);
			buffMaintain($effect[Peppermint Bite], 0, 1 , 1);
			buffMaintain($effect[Barbecue Saucy], 0, 1, 1);
			buffMaintain($effect[Graham Crackling], 0, 1, 1);
			buffMaintain($effect[Berry Statistical], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Experimental Effect G-9], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Purity of Spirit], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Human-Human Hybrid], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Gr8tness], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Nigh-Invincible], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Pill Power], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Phorcefullness], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[The Power Of LOV], 0, 1, 1);

			if(!get_property("_grimBuff").to_boolean() && have_familiar($familiar[Grim Brother]))
			{
				cli_execute("grim hpmp");
			}

			if(!get_property("_streamsCrossed").to_boolean() && possessEquipment($item[Protonic Accelerator Pack]))
			{
				cli_execute("crossstreams");
			}

			if(get_property("spacegateVaccine2").to_boolean() && !get_property("_spacegateVaccine").to_boolean() && (have_effect($effect[Broad-Spectrum Vaccine]) == 0) && get_property("spacegateAlways").to_boolean())
			{
				cli_execute("spacegate vaccine 2");
			}

			if(is_unrestricted($item[Colorful Plastic Ball]))
			{
				# Can not be used in Ronin/Hardcore, derp....
				cli_execute("ballpit");
			}
			if((item_amount($item[Ancient Medicinal Herbs]) > 0) && (have_effect($effect[Ancient Fortitude]) == 0))
			{
				slChew(1, $item[Ancient Medicinal Herbs]);
			}

			if(!get_property("_madTeaParty").to_boolean())
			{
				if(item_amount($item[Coconut Shell]) == 0)
				{
					if((item_amount($item[Pentacorn Hat]) == 0) && (my_meat() > 300))
					{
						buyUpTo(1, $item[Pentacorn Hat]);
					}
				}
				if(!get_property("_lookingGlass").to_boolean())
				{
					cli_execute("clan_viplounge.php?action=lookingglass");
				}
				if(!possessEquipment($item[Helmet Turtle]))
				{
					acquireGumItem($item[Helmet Turtle]);
				}
				cli_execute("hatter 12");
			}

			if(get_property("telescopeUpgrades").to_int() > 0)
			{
				if(!get_property("telescopeLookedHigh").to_boolean())
				{
					cli_execute("telescope high");
				}
			}

			if((15 - get_property("_deckCardsDrawn").to_int()) >= 5)
			{
				deck_cheat("muscle buff");
			}

			if((spleen_left() > 0) && (item_amount($item[Abstraction: Action]) > 0) && (have_effect($effect[Action]) == 0))
			{
				slChew(1, $item[Abstraction: Action]);
			}

			if((inebriety_left() >= 12) && (item_amount($item[Clan VIP Lounge Key]) > 0) && (sl_get_clan_lounge() contains $item[Clan Speakeasy]) && (have_effect($effect[On The Trolley]) == 0) && (get_cs_questCost(curQuest) < 20))
			{
				slDrink(1, $item[Bee's Knees]);
			}

			if(item_amount($item[Pulled Orange Taffy]) > 5)
			{
				buffMaintain($effect[Orange Crusher], 0, 1, 50);
				if(get_cs_questCost(curQuest) < 10)
				{
					buffMaintain($effect[Orange Crusher], 0, 1, 50);
					buffMaintain($effect[Orange Crusher], 0, 1, 50);
					buffMaintain($effect[Orange Crusher], 0, 1, 50);
					buffMaintain($effect[Orange Crusher], 0, 1, 50);
					buffMaintain($effect[Orange Crusher], 0, 1, 50);
				}
			}

			if((get_property("_kgbClicksUsed").to_int() <= 10) && possessEquipment($item[Kremlin\'s Greatest Briefcase]))
			{
				string temp = visit_url("place.php?whichplace=kgb&action=kgb_tab1", false);
				temp = visit_url("place.php?whichplace=kgb&action=kgb_tab2", false);
				temp = visit_url("place.php?whichplace=kgb&action=kgb_tab3", false);
				temp = visit_url("place.php?whichplace=kgb&action=kgb_tab4", false);
				temp = visit_url("place.php?whichplace=kgb&action=kgb_tab5", false);
				temp = visit_url("place.php?whichplace=kgb&action=kgb_tab6", false);
				temp = visit_url("place.php?whichplace=kgb&action=kgb_tab1", false);
				temp = visit_url("place.php?whichplace=kgb&action=kgb_tab2", false);
			}

			if(get_cs_questCost(curQuest) > 10)
			{
				makeGenieWish($effect[Preemptive Medicine]);
			}

			if(get_cs_questCost(curQuest) > 1)
			{
				if((item_amount($item[Cashew]) >= 2) && !possessEquipment($item[Mini-Marshmallow Dispenser]))
				{
					cli_execute("make " + $item[Mini-Marshmallow Dispenser]);
				}
			}

			if((get_cs_questCost(curQuest) > 7) && (have_effect($effect[Muddled]) == 0))
			{
				fightClubSpa($effect[Muddled]);
			}

			if(get_cs_questCost(curQuest) > 1)
			{
				if(sl_csHandleGrapes())
				{
					return true;
				}
			}

			if(do_cs_quest(1))
			{
				curQuest = 0;
			}
			else
			{
				curQuest = 0;
				abort("Could not handle our quest and can not recover");
			}
		}
		break;

	case 2:		#Muscle Quest
		{
			januaryToteAcquire($item[Wad Of Used Tape]);
			if((get_property("frAlways").to_boolean() || get_property("_frToday").to_boolean()) && !possessEquipment($item[FantasyRealm G. E. M.]))
			{
				visit_url("place.php?whichplace=realm_fantasy&action=fr_initcenter", false);
				visit_url("choice.php?whichchoice=1280&pwd=&option=" + (random(2)+1));
			}

			if(!possessEquipment($item[Barrel Lid]) && get_property("barrelShrineUnlocked").to_boolean())
			{
				visit_url("da.php?barrelshrine=1");
				visit_url("choice.php?whichchoice=1100&pwd&option=1", true);
			}

			if(possessEquipment($item[Barrel Lid]))
			{
				equip($item[Barrel Lid]);
			}

			buyUpTo(1, $item[Ben-Gal&trade; Balm]);

			while((my_mp() < 50) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}

			while((my_mp() < 125) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}
			buffMaintain($effect[Quiet Determination], 10, 1, 1);
			buffMaintain($effect[Big], 15, 1, 1);
			buffMaintain($effect[Song of Bravado], 100, 1, 1);
			buffMaintain($effect[Rage of the Reindeer], 10, 1, 1);
			buffMaintain($effect[Stevedave\'s Shanty of Superiority], 30, 1, 1);
			buffMaintain($effect[Power Ballad of the Arrowsmith], 10, 1, 1);
			buffMaintain($effect[Disdain of the War Snapper], 15, 1, 1);

			buffMaintain($effect[Expert Oiliness], 0, 1, 1);
			buffMaintain($effect[Orange Crusher], 0, 1, 50);
			buffMaintain($effect[Orange Crusher], 0, 1, 50);
			buffMaintain($effect[Orange Crusher], 0, 1, 50);
			buffMaintain($effect[Orange Crusher], 0, 1, 50);
			buffMaintain($effect[Orange Crusher], 0, 1, 50);
			buffMaintain($effect[Phorcefullness], 0, 1, 1);
			buffMaintain($effect[Tomato Power], 0, 1, 1);
			buffMaintain($effect[Savage Beast Inside], 0, 1, 1);
			buffMaintain($effect[Extra Backbone], 0, 1, 1);

			buffMaintain($effect[Go Get \'Em\, Tiger!], 0, 1, 1);
			buffMaintain($effect[Seal Clubbing Frenzy], 1, 1, 1);
			buffMaintain($effect[Patience of the Tortoise], 1, 1, 1);
			buffMaintain($effect[Human-Humanoid Hybrid], 0, 1, 1);
			buffMaintain($effect[Human-Human Hybrid], 0, 1, 1);
			buffMaintain($effect[Frog in Your Throat], 0, 1, 1);
			buffMaintain($effect[Twen Tea], 0, 1, 1);
			buffMaintain($effect[Feroci Tea], 0, 1, 1);
			buffMaintain($effect[Peppermint Bite], 0, 1 , 1);
			buffMaintain($effect[Berry Statistical], 0, 1, 1);

			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Experimental Effect G-9], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Gr8tness], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Pill Power], 0, 1, 1);

			int grapeCost = 1;
			if(item_amount($item[Green Mana]) > 0)
			{
				grapeCost = 10;
			}
			if(get_cs_questCost(curQuest) > grapeCost)
			{
				if(sl_csHandleGrapes())
				{
					return true;
				}
			}

			handleFamiliar($familiar[Machine Elf]);
			cs_giant_growth();

			if((spleen_left() > 0) && (item_amount($item[Abstraction: Action]) > 0) && (have_effect($effect[Action]) == 0) && (estimate_cs_questCost(curQuest) > 1))
			{
				slChew(1, $item[Abstraction: Action]);
			}

			if((inebriety_left() >= 12) && (item_amount($item[Clan VIP Lounge Key]) > 0) && (sl_get_clan_lounge() contains $item[Clan Speakeasy]) && (have_effect($effect[On The Trolley]) == 0) && (estimate_cs_questCost(curQuest) > 1))
			{
				slDrink(1, $item[Bee's Knees]);
			}

			if(get_property("spacegateVaccine2").to_boolean() && !get_property("_spacegateVaccine").to_boolean() && (have_effect($effect[Broad-Spectrum Vaccine]) == 0) && get_property("spacegateAlways").to_boolean() && (estimate_cs_questCost(curQuest) > 1))
			{
				cli_execute("spacegate vaccine 2");
			}

			if(do_cs_quest(2))
			{
				cli_execute("refresh inv");
				curQuest = 0;
			}
			else
			{
				curQuest = 0;
				abort("Could not handle our quest and can not recover");
			}
		}
		break;

	case 3:		#Myst Quest
		{
			januaryToteAcquire($item[Wad Of Used Tape]);
			buyUpTo(1, $item[Glittery Mascara]);

			if((item_amount($item[Saucepanic]) > 0) && have_skill($skill[Double-Fisted Skull Smashing]))
			{
				equip($slot[off-hand], $item[Saucepanic]);
			}

			while((my_mp() < 133) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}
			buffMaintain($effect[Quiet Judgement], 10, 1, 1);
			buffMaintain($effect[Big], 15, 1, 1);
			buffMaintain($effect[Song of Bravado], 100, 1, 1);
			buffMaintain($effect[Stevedave\'s Shanty of Superiority], 30, 1, 1);
			buffMaintain($effect[The Magical Mojomuscular Melody], 3, 1, 1);
			buffMaintain($effect[Disdain of She-Who-Was], 15, 1, 1);


			buffMaintain($effect[Mystically Oiled], 0, 1, 1);
			buffMaintain($effect[Tomato Power], 0, 1, 1);
			buffMaintain($effect[Pill Power], 0, 1, 1);
			buffMaintain($effect[Glittering Eyelashes], 0, 1, 1);
			buffMaintain($effect[Liquidy Smoky], 0, 1, 1);
			buffMaintain($effect[Gr8tness], 0, 1, 1);
			buffMaintain($effect[OMG WTF], 0, 1, 1);
			buffMaintain($effect[Purple Reign], 0, 1, 50);
			buffMaintain($effect[Purple Reign], 0, 1, 50);
			buffMaintain($effect[Purple Reign], 0, 1, 50);
			buffMaintain($effect[Purple Reign], 0, 1, 50);
			buffMaintain($effect[Purple Reign], 0, 1, 50);
			buffMaintain($effect[Saucemastery], 1, 1, 1);
			buffMaintain($effect[Pasta Oneness], 1, 1, 1);
			buffMaintain($effect[Human-Humanoid Hybrid], 0, 1, 1);
			buffMaintain($effect[Human-Human Hybrid], 0, 1, 1);
			buffMaintain($effect[Salamander In Your Stomach], 0, 1, 1);
			buffMaintain($effect[Twen Tea], 0, 1, 1);
			buffMaintain($effect[Wit Tea], 0, 1, 1);
			buffMaintain($effect[Sweet\, Nuts], 0, 1, 1);
			buffMaintain($effect[Baconstoned], 0, 1, 1);
			buffMaintain($effect[Berry Statistical], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Experimental Effect G-9], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[The Magic Of LOV], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Seriously Mutated], 0, 1, 1);

			int grapeCost = 1;
			if(item_amount($item[Green Mana]) > 0)
			{
				grapeCost += 9;
			}
			if(item_amount($item[Bag Of Grain]) > 0)
			{
				grapeCost += 7;
			}
			if(get_cs_questCost(curQuest) > grapeCost)
			{
				if(sl_csHandleGrapes())
				{
					return true;
				}
			}

			buffMaintain($effect[Nearly All-Natural], 0, 1, 1);
			handleFamiliar($familiar[Machine Elf]);
			cs_giant_growth();

			if((spleen_left() > 0) && (item_amount($item[Abstraction: Thought]) > 0) && (have_effect($effect[Thought]) == 0) && (estimate_cs_questCost(curQuest) > 1))
			{
				slChew(1, $item[Abstraction: Thought]);
			}

			if((inebriety_left() >= 12) && (item_amount($item[Clan VIP Lounge Key]) > 0) && (sl_get_clan_lounge() contains $item[Clan Speakeasy]) && (have_effect($effect[On The Trolley]) == 0) && (estimate_cs_questCost(curQuest) > 1))
			{
				slDrink(1, $item[Bee's Knees]);
			}

			if(get_property("spacegateVaccine2").to_boolean() && !get_property("_spacegateVaccine").to_boolean() && (have_effect($effect[Broad-Spectrum Vaccine]) == 0) && get_property("spacegateAlways").to_boolean() && (estimate_cs_questCost(curQuest) > 1))
			{
				cli_execute("spacegate vaccine 2");
			}

			if(do_cs_quest(3))
			{
				cli_execute("refresh inv");
				curQuest = 0;
			}
			else
			{
				curQuest = 0;
				abort("Could not handle our quest and can not recover");
			}
		}
		break;

	case 4:		#Moxie Quest
		{
			januaryToteAcquire($item[Wad Of Used Tape]);
			buyUpTo(1, $item[Hair Spray]);

			while((my_mp() < 142) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}

			if(have_skill($skill[Quiet Desperation]))
			{
				buffMaintain($effect[Quiet Desperation], 10, 1, 1);
			}
			else
			{
				buffMaintain($effect[Disco Smirk], 10, 1, 1);
			}
			buffMaintain($effect[Big], 15, 1, 1);
			buffMaintain($effect[Song of Bravado], 100, 1, 1);
			buffMaintain($effect[Stevedave\'s Shanty of Superiority], 30, 1, 1);
			buffMaintain($effect[The Moxious Madrigal], 2, 1, 1);
			buffMaintain($effect[Disco Fever], 10, 1, 1);
			buffMaintain($effect[Blubbered Up], 10, 1, 1);

			buffMaintain($effect[Expert Oiliness], 0, 1, 1);
			buffMaintain($effect[Tomato Power], 0, 1, 1);
			buffMaintain($effect[Pulchritudinous Pressure], 0, 1, 1);
			buffMaintain($effect[Lycanthropy\, Eh?], 0, 1, 1);
			buffMaintain($effect[Superhuman Sarcasm], 0, 1, 1);
			buffMaintain($effect[Notably Lovely], 0, 1, 1);
			buffMaintain($effect[Pill Power], 0, 1, 1);
			buffMaintain($effect[Butt-Rock Hair], 0, 1, 1);
			buffMaintain($effect[Gr8tness], 0, 1, 1);
			buffMaintain($effect[Liquidy Smoky], 0, 1, 1);
			buffMaintain($effect[Barbecue Saucy], 0, 1, 1);
			buffMaintain($effect[Cinnamon Challenger], 0, 1, 50);
			buffMaintain($effect[Cinnamon Challenger], 0, 1, 50);
			buffMaintain($effect[Cinnamon Challenger], 0, 1, 50);
			buffMaintain($effect[Cinnamon Challenger], 0, 1, 50);
			buffMaintain($effect[Cinnamon Challenger], 0, 1, 50);
			buffMaintain($effect[Disco State of Mind], 1, 1, 1);
			buffMaintain($effect[Mariachi Mood], 1, 1, 1);
			buffMaintain($effect[Human-Humanoid Hybrid], 0, 1, 1);
			buffMaintain($effect[Human-Human Hybrid], 0, 1, 1);
			buffMaintain($effect[Newt Gets In Your Eyes], 0, 1, 1);
			buffMaintain($effect[Twen Tea], 0, 1, 1);
			buffMaintain($effect[Dexteri Tea], 0, 1, 1);
			buffMaintain($effect[Busy Bein\' Delicious], 0, 1, 1);
			buffMaintain($effect[Bandersnatched], 0, 1, 1);
			buffMaintain($effect[Berry Statistical], 0, 1, 1);

			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Experimental Effect G-9], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[The Moxie Of LOV], 0, 1, 1);
			if(estimate_cs_questCost(curQuest) > 1)		buffMaintain($effect[Seriously Mutated], 0, 1, 1);

			int grapeCost = 1;
			if(item_amount($item[Green Mana]) > 0)
			{
				grapeCost += 9;
			}
			if(item_amount($item[Pocket Maze]) > 0)
			{
				grapeCost += 7;
			}

			if(get_cs_questCost(curQuest) > grapeCost)
			{
				if(sl_csHandleGrapes())
				{
					return true;
				}
			}

			if((get_cs_questCost(curQuest) > 7) && (have_effect($effect[Ten out of Ten]) == 0))
			{
				fightClubSpa($effect[Ten out of Ten]);
			}

			handleFamiliar($familiar[Machine Elf]);
			cs_giant_growth();

			if((spleen_left() > 0) && (item_amount($item[Abstraction: Sensation]) > 0) && (have_effect($effect[Sensation]) == 0) && (estimate_cs_questCost(curQuest) > 1))
			{
				slChew(1, $item[Abstraction: Sensation]);
			}

			if(get_cs_questCost(curQuest) > 5)
			{
				buffMaintain($effect[Amazing], 0, 1, 1);
			}


			if((inebriety_left() >= 12) && (item_amount($item[Clan VIP Lounge Key]) > 0) && (sl_get_clan_lounge() contains $item[Clan Speakeasy]) && (have_effect($effect[On The Trolley]) == 0) && (estimate_cs_questCost(curQuest) > 1))
			{
				slDrink(1, $item[Bee's Knees]);
			}

#			At this point, we are probably only saving 1.75 turns or so, do not bother.
#			if(get_property("spacegateVaccine2").to_boolean() && !get_property("_spacegateVaccine").to_boolean() && (have_effect($effect[Broad-Spectrum Vaccine]) == 0) && get_property("spacegateAlways").to_boolean())
#			{
#				cli_execute("spacegate vaccine 2");
#			}

			if(possessEquipment($item[Greatest American Pants]))
			{
				equip($item[Greatest American Pants]);
				visit_url("inventory.php?action=activatesuperpants");
				run_choice(4);
			}

			if((estimate_cs_questCost(curQuest) > 1) && (item_amount($item[Rhinestone]) > 0))
			{
				int turns = estimate_cs_questCost(curQuest) - 1;
				use(min(item_amount($item[Rhinestone]), 30 * turns), $item[Rhinestone]);
			}

			if(do_cs_quest(4))
			{
				curQuest = 0;
			}
			else
			{
				curQuest = 0;
				abort("Could not handle our quest and can not recover");
			}
		}
		break;

	case 5:		#Familiar Weight
		{
			while((my_mp() < 50) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}

			int lastQuestCost = 36;
			if(have_skill($skill[Smooth Movement]))
			{
				lastQuestCost = lastQuestCost - 3;
			}
			if(have_skill($skill[The Sonata of Sneakiness]))
			{
				lastQuestCost = lastQuestCost - 3;
			}
			if((item_amount($item[Snow Berries]) >= 1) || (item_amount($item[Snow Cleats]) == 0))
			{
				lastQuestCost = lastQuestCost - 3;
			}
			if(item_amount($item[cuppa Obscuri Tea]) > 0)
			{
				lastQuestCost = lastQuestCost - 3;
			}
			if(is_unrestricted($item[Olympic-sized Clan Crate]) && !get_property("_olympicSwimmingPool").to_boolean())
			{
				lastQuestCost = lastQuestCost - 3;
			}

			buffMaintain($effect[Blue Swayed], 0, 1, 50);
			buffMaintain($effect[Blue Swayed], 0, 1, 50);
			buffMaintain($effect[Blue Swayed], 0, 1, 50);
			buffMaintain($effect[Blue Swayed], 0, 1, 50);
			buffMaintain($effect[Blue Swayed], 0, 1, 50);
			buffMaintain($effect[Loyal Tea], 0, 1, 1);
			buffMaintain($effect[Blood Bond], 0, 1, 1);
			if((spleen_left() > 0) && (item_amount($item[Abstraction: Joy]) > 0) && (have_effect($effect[Joy]) == 0))
			{
				slChew(1, $item[Abstraction: Joy]);
			}

			if((get_property("puzzleChampBonus").to_int() == 20) && !get_property("_witchessBuff").to_boolean())
			{
				visit_url("campground.php?action=witchess");
				visit_url("choice.php?whichchoice=1181&pwd=&option=3");
				visit_url("choice.php?whichchoice=1183&pwd=&option=2");
			}

			if((have_effect($effect[Puzzle Champ]) == 0) && get_property("sl_pauseForWitchess").to_boolean())
			{
				user_confirm("Get the Witchess Familiar Buff and then click this away. Beep boop.");
			}

			zataraSeaside("familiar");

			int currentCost = get_cs_questCost(curQuest);
			if(have_skill($skill[Empathy of the Newt]))
			{
				currentCost = currentCost - 1;
			}
			if(have_skill($skill[Leash of Linguini]))
			{
				currentCost = currentCost - 1;
			}

			int needCost = lastQuestCost + currentCost;

			if(inebriety_left() >= 10)
			{
				if(my_adventures() < needCost)
				{
					//Is it possible for us to drink some other stuff?
					int extraAdv = 0;

					int drunkLeft = 10;
					if((item_amount($item[Sacramento Wine]) >= 4) && (drunkLeft >= 4))
					{
						extraAdv = extraAdv + 24;
						drunkLeft -= 4;
					}
					if((item_amount($item[Sacramento Wine]) >= 5) && (drunkLeft >= 1))
					{
						extraAdv = extraAdv + 6;
						drunkLeft -= 1;
					}
					if((item_amount($item[Iced Plum Wine]) >= 1) && (drunkLeft >= 1))
					{
						extraAdv = extraAdv + 7;
						drunkLeft -= 1;
					}

					if((my_meat() > 5000) && (drunkLeft >= 3) && (item_amount($item[Clan VIP Lounge Key]) > 0))
					{
						extraAdv = extraAdv + 13;
						needCost = needCost - 2;
						drunkLeft -= 3;
					}
					if((item_amount($item[Asbestos Thermos]) > 0) && (drunkLeft >= 4))
					{
						extraAdv = extraAdv + 16;
						drunkLeft -= 4;
					}

					if((item_amount($item[Cold One]) > 0) && (drunkLeft >= 1))
					{
						extraAdv = extraAdv + 5;
						drunkLeft -= 1;
					}

					if((my_adventures() + extraAdv) > needCost)
					{
						if((item_amount($item[Sacramento Wine]) >= 4) && (inebriety_left() >= 4))
						{
							slDrink(4, $item[Sacramento Wine]);
						}
						if((item_amount($item[Sacramento Wine]) >= 1) && (inebriety_left() >= 1))
						{
							slDrink(1, $item[Sacramento Wine]);
						}
						if((item_amount($item[Iced Plum Wine]) >= 1) && (inebriety_left() >= 1))
						{
							slDrink(1, $item[Iced Plum Wine]);
						}

						if((my_meat() > 5000) && (item_amount($item[Clan VIP Lounge Key]) > 0) && (inebriety_left() >= 3) && (sl_get_clan_lounge() contains $item[Clan Speakeasy]))
						{
							slDrink(1, $item[Hot Socks]);
						}
						if((item_amount($item[Asbestos Thermos]) > 0) && (inebriety_left() >= 4))
						{
							slDrink(1, $item[Asbestos Thermos]);
						}
						if((item_amount($item[Cold One]) > 0) && (inebriety_left() >= 1))
						{
							slDrink(1, $item[Cold One]);
						}

					}
					else if ((item_amount($item[Vintage Smart Drink]) > 0) && !get_property("sl_saveVintage").to_boolean())
					{
						slDrink(1, $item[Vintage Smart Drink]);
					}
				}
			}

			while((my_mp() < 27) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}
			buffMaintain($effect[Empathy], 15, 1, 1);
			buffMaintain($effect[Leash of Linguini], 12, 1, 1);
			if(is_unrestricted($item[Clan Pool Table]) && (have_effect($effect[Billiards Belligerence]) == 0))
			{
				visit_url("clan_viplounge.php?preaction=poolgame&stance=1");
			}

			familiar toFam = $familiar[Cocoabo];
			foreach fam in $familiars[]
			{
				if((familiar_weight(fam) > familiar_weight(toFam)) && have_familiar(fam))
				{
					toFam = fam;
				}
			}

			if(possessEquipment($item[Pet Rock &quot;Snooty&quot; Disguise]))
			{
				foreach fam in $familiars[Pet Rock, Toothsome Rock, Bulky Buddy Box, Holiday Log]
				{
					if(((familiar_weight(fam) + 11) > familiar_weight(toFam)) && have_familiar(fam))
					{
						toFam = fam;
					}
				}
			}

			#handleFamiliar(toFam);
			use_familiar(toFam);
			if(can_equip($item[Pet Rock &quot;Snooty&quot; Disguise]) && possessEquipment($item[Pet Rock &quot;Snooty&quot; Disguise]))
			{
				equip($item[Pet Rock &quot;Snooty&quot; Disguise]);
			}

			#This is probably not all that effective here....
			if(item_amount($item[Ghost Dog Chow]) > 0)
			{
				use(min(5,item_amount($item[Ghost Dog Chow])), $item[Ghost Dog Chow]);
			}

			if(do_cs_quest(5))
			{
				curQuest = 0;
				use_familiar(prior);
			}
			else
			{
				curQuest = 0;
				use_familiar(prior);
				abort("Could not handle our quest and can not recover");
			}
		}
		break;

	case 6:		#Weapon Damage
		{
			while((my_mp() < 50) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}

			//This needs to be cleaned up.
			if(((my_inebriety() == 5) || (my_inebriety() == 11)) && (have_effect($effect[In A Lather]) == 0))
			{
				slDrink(1, $item[Sockdollager]);
			}

//			januaryToteAcquire($item[Broken Champagne Bottle]);

			while((my_mp() < 207) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}

			buffMaintain($effect[Song of the North], 100, 1, 1);
			buffMaintain($effect[Bow-Legged Swagger], 100, 1, 1);
			buffMaintain($effect[Jackasses\' Symphony of Destruction], 9, 1, 1);
			buffMaintain($effect[Rage of the Reindeer], 10, 1, 1);
			buffMaintain($effect[Scowl of the Auk], 10, 1, 1);
			buffMaintain($effect[Tenacity of the Snapper], 8, 1, 1);
			buffMaintain($effect[Disdain of the War Snapper], 15, 1, 1);
			buffMaintain($effect[Frenzied, Bloody], 10, 1, 1);
			songboomSetting("weapon damage");

			buffMaintain($effect[The Power Of LOV], 0, 1, 1);

			if((item_amount($item[Wasabi Marble Soda]) == 0) && (have_effect($effect[Wasabi With You]) == 0) && (item_amount($item[Ye Wizard\'s Shack snack voucher]) > 0))
			{
				cli_execute("make " + $item[Wasabi Marble Soda]);
				buffMaintain($effect[Wasabi With You], 0, 1, 1);
			}

			buffMaintain($effect[Human-Beast Hybrid], 0, 1, 1);
			buffMaintain($effect[Twinkly Weapon], 0, 1, 1);
			buffMaintain($effect[This Is Where You\'re a Viking], 0, 1, 1);
			buffMaintain($effect[Feeling Punchy], 0, 1, 1);
			if(is_unrestricted($item[Clan Pool Table]) && (have_effect($effect[Billiards Belligerence]) == 0))
			{
				visit_url("clan_viplounge.php?preaction=poolgame&stance=1");
			}

			if(!get_property("_grimBuff").to_boolean() && have_familiar($familiar[Grim Brother]))
			{
				cli_execute("grim damage");
			}

			int restsLeft = total_free_rests() - get_property("timesRested").to_int();
			while((my_level() < 8) && (restsLeft > 0) && chateaumantegna_available() && ((my_basestat(my_primestat()) + restsLeft) >= 53))
			{
				doRest();
				cli_execute("postsool");
			}

			if((my_level() < 8) && !get_property("_fancyHotDogEaten").to_boolean() && (fullness_left() >= 12))
			{
				if(get_property("sl_noSleepingDog").to_boolean() || have_skill($skill[Dog Tired]))
				{
					eatFancyDog("savage macho dog");
				}
				else if(chateaumantegna_available())
				{
					eatFancyDog("sleeping dog");
				}
				if(!get_property("_fancyHotDogEaten").to_boolean())
				{
					abort("Tried to eat a hot dog and failed. Move to a hot dog stand clan or 'set _fancyHotDogEaten=true' in order to resume");
				}
				return true;
			}

			if((item_amount($item[Astral Pilsner]) > 0) && (inebriety_left() > 0) && (my_adventures() < get_cs_questCost(curQuest)))
			{
				slDrink(min(inebriety_left(), item_amount($item[Astral Pilsner])), $item[Astral Pilsner]);
			}

			if((my_adventures() < get_cs_questCost(curQuest)) && ((my_inebriety() == 7) || (my_inebriety() == 13)))
			{
				if(item_amount($item[Iced Plum Wine]) > 0)
				{
					slDrink(1, $item[Iced Plum Wine]);
				}
				else if(item_amount($item[Sacramento Wine]) > 0)
				{
					slDrink(1, $item[Sacramento Wine]);
				}
				else if((sl_get_clan_lounge() contains $item[Clan Speakeasy]) && (item_amount($item[Clan VIP Lounge Key]) > 0))
				{
					slDrink(1, $item[cup of &quot;tea&quot;]);
				}
			}

			if(do_cs_quest(6))
			{
				curQuest = 0;
			}
			else
			{
				curQuest = 0;
				abort("Could not handle our quest and can not recover");
			}
			januaryToteAcquire($item[Makeshift Garbage Shirt]);
			if(possessEquipment($item[Kremlin\'s Greatest Briefcase]))
			{
				string mod = string_modifier($item[Kremlin\'s Greatest Briefcase], "Modifiers");
				if(contains_text(mod, "Weapon Damage Percent"))
				{
					string page = visit_url("place.php?whichplace=kgb");
					boolean flipped = false;
					if(contains_text(page, "handleup"))
					{
						page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
						flipped = true;
					}

					page = visit_url("place.php?whichplace=kgb&action=kgb_button1", false);
					page = visit_url("place.php?whichplace=kgb&action=kgb_button3", false);
					page = visit_url("place.php?whichplace=kgb&action=kgb_button3", false);
					page = visit_url("place.php?whichplace=kgb&action=kgb_button5", false);
					if(flipped)
					{
						page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
					}
				}
			}
		}
		break;

	case 7:		#Spell Damage
		{
			if(my_daycount() == 1)
			{
				print("We don't try to do this quest on Day 1. Hmmm...", "red");
				abort("Probably saved margarita and re-ran without overdrinking. oops!");
			}
			if(my_daycount() > 1)
			{
				if((isOverdueDigitize() || isOverdueArrow()) && elementalPlanes_access($element[stench]))
				{
					print("A Wanderer event is expected now, diverting... (Status: 7 End)", "blue");
					slAdv(1, $location[Barf Mountain], "cs_combatNormal");
					return true;
				}

				if(snojoFightAvailable() && (my_adventures() > 0))
				{
					slAdv(1, $location[The X-32-F Combat Training Snowman]);
					return true;
				}
				if(have_familiar($familiar[Machine Elf]) && (get_property("_machineTunnelsAdv").to_int() < 2) && !is100FamiliarRun($familiar[Machine Elf]))
				{
					backupSetting("choiceAdventure1119", 1);
					handleFamiliar($familiar[Machine Elf]);
					slAdv(1, $location[The Deep Machine Tunnels]);
					restoreSetting("choiceAdventure1119");
					set_property("choiceAdventure1119", "");
					return true;
				}

				if((have_effect($effect[Half-Blooded]) > 0) || (have_effect($effect[Half-Drained]) > 0) || (have_effect($effect[Bruised]) > 0) || (have_effect($effect[Relaxed Muscles]) > 0) || (have_effect($effect[Hypnotized]) > 0) || (have_effect($effect[Bad Haircut]) > 0))
				{
					doHottub();
				}

				while((my_mp() < 250) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
				{
					doRest();
				}
				if(possessEquipment($item[Staff of the Headmaster\'s Victuals]) && can_equip($item[Staff of the Headmaster\'s Victuals]) && have_skill($skill[Spirit of Rigatoni]))
				{
					equip($slot[weapon], $item[Staff of the Headmaster\'s Victuals]);
				}
				else if(item_amount($item[Obsidian Nutcracker]) > 0)
				{
					equip($slot[weapon], $item[Obsidian Nutcracker]);
				}

				if((my_mp() > 250) && (my_maxhp() < 500) && have_skills($skills[Deep Dark Visions, Song Of Starch]))
				{
					buffMaintain($effect[Song of Starch], 240, 1, 1);
				}
				if((my_mp() > 140) && (my_maxhp() >= 500) && have_skill($skill[Deep Dark Visions]))
				{
					if(elemental_resist($element[spooky]) < 8)
					{
						buffMaintain($effect[Astral Shell], 110, 1, 1);
						buffMaintain($effect[Elemental Saucesphere], 110, 1, 1);
					}
					useCocoon();
					buffMaintain($effect[Visions of the Deep Dark Deeps], 100, 1, 1);

					useCocoon();
				}

				while((my_mp() < 250) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
				{
					doRest();
				}

				if(possessEquipment($item[Astral Statuette]))
				{
					equip($item[Astral Statuette]);
				}
				buffMaintain($effect[Song of Sauce], 100, 1, 1);
				buffMaintain($effect[Bendin\' Hell], 100, 1, 1);
				buffMaintain($effect[Arched Eyebrow of the Archmage], 10, 1, 1);
				buffMaintain($effect[Jackasses\' Symphony of Destruction], 8, 1, 1);
				buffMaintain($effect[Puzzle Fury], 0, 1, 1);
				buffMaintain($effect[Be A Mind Master], 0, 1, 1);
				buffMaintain($effect[Paging Betty], 0, 1, 1);
				buffMaintain($effect[The Magic Of LOV], 0, 1, 1);

				if(is_unrestricted($item[Clan Pool Table]) && (have_effect($effect[Mental A-cue-ity]) == 0))
				{
					visit_url("clan_viplounge.php?preaction=poolgame&stance=2");
				}

				if((item_amount($item[Tobiko Marble Soda]) == 0) && (have_effect($effect[Pisces in the Skyces]) == 0) && (item_amount($item[Ye Wizard\'s Shack snack voucher]) > 0))
				{
					cli_execute("make " + $item[Tobiko Marble Soda]);
					buffMaintain($effect[Pisces in the Skyces], 0, 1, 1);
				}

				if(have_familiar($familiar[Disembodied Hand]))
				{
					use_familiar($familiar[Disembodied Hand]);
					if(equipped_item($slot[familiar]) != $item[Obsidian Nutcracker])
					{
						if((item_amount($item[Obsidian Nutcracker]) > 0) || ((2 * npc_price($item[Obsidian Nutcracker])) < my_meat()))
						{
							buyUpTo(2, $item[Obsidian Nutcracker]);
						}
						if(item_amount($item[Obsidian Nutcracker]) > 0)
						{
							equip($slot[familiar], $item[Obsidian Nutcracker]);
						}
					}
				}

				if(get_cs_questCost(curQuest) > 1)
				{
					if((item_amount($item[Cashew]) >= 2) && !possessEquipment($item[Potato Masher]))
					{
						cli_execute("make " + $item[Potato Masher]);
					}
				}

				if(!get_property("_grimBuff").to_boolean() && have_familiar($familiar[Grim Brother]))
				{
					cli_execute("grim damage");
				}

				if(do_cs_quest(7))
				{
					curQuest = 0;
					use_familiar(prior);
				}
				else
				{
					curQuest = 0;
					use_familiar(prior);
					abort("Could not handle our quest and can not recover");
				}
			}
		}
		break;

	case 8:			#Non-Combat
		{
			while((my_mp() < 30) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}
			buffMaintain($effect[Smooth Movements], 10, 1, 1);
			buffMaintain($effect[The Sonata of Sneakiness], 20, 1, 1);
			uneffect($effect[Dog Breath]);

			if((item_amount($item[Snow Berries]) > 0) && (have_effect($effect[Snow Shoes]) == 0) && (item_amount($item[Snow Cleats]) == 0))
			{
				cli_execute("make " + $item[Snow Cleats]);
			}

			if((item_amount($item[Cop Dollar]) >= 10) && (have_effect($effect[Gummed Shoes]) == 0) && (item_amount($item[shoe gum]) == 0))
			{
				cli_execute("make " + $item[shoe gum]);
			}

			if(possessEquipment($item[Kremlin\'s Greatest Briefcase]))
			{
				string mod = string_modifier($item[Kremlin\'s Greatest Briefcase], "Modifiers");
				if(contains_text(mod, "Adventures"))
				{
					string page = visit_url("place.php?whichplace=kgb");
					boolean flipped = false;
					if(contains_text(page, "handleup"))
					{
						page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
						flipped = true;
					}

					page = visit_url("place.php?whichplace=kgb&action=kgb_button5", false);
					if(flipped)
					{
						page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
					}
				}
			}

			buffMaintain($effect[Snow Shoes], 0, 1, 1);
			buffMaintain($effect[Obscuri Tea], 0, 1, 1);
			buffMaintain($effect[Gummed Shoes], 0, 1, 1);
			buffMaintain($effect[Become Superficially Interested], 0, 1, 1);
			if(is_unrestricted($item[Olympic-sized Clan Crate]) && !get_property("_olympicSwimmingPool").to_boolean())
			{
				cli_execute("swim noncombat");
			}
			asdonBuff($effect[Driving Stealthily]);

			if(!is100FamiliarRun($familiar[Disgeist]) && have_familiar($familiar[Disgeist]))
			{
				# Need 37-41 pounds to save 3 turns. (probably 40)
				# 74 does not save 6 but 79 does.
				buffMaintain($effect[Empathy], 15, 1, 1);
				buffMaintain($effect[Leash of Linguini], 12, 1, 1);

				if(!is_familiar_equipment_locked() && (equipped_item($slot[familiar]) != $item[none]))
				{
					lock_familiar_equipment(true);
				}

				if(equipped_item($slot[familiar]) == $item[Astral Pet Sweater])
				{
					equip($slot[familiar], $item[none]);
				}

				use_familiar($familiar[Disgeist]);
				if((equipped_item($slot[familiar]) != $item[Astral Pet Sweater]) && (available_amount($item[Astral Pet Sweater]) > 0))
				{
					equip($slot[familiar], $item[Astral Pet Sweater]);
				}
				if(item_amount($item[Ghostly Reins]) > 0)
				{
					equip($slot[off-hand], $item[Ghostly Reins]);
				}
			}

			int questCost = get_cs_questCost(curQuest);
			if(my_adventures() < questCost)
			{
				buffMaintain($effect[A Rose by Any Other Material], 0, 1, 1);
				questCost = questCost - 12;
			}
			if(my_adventures() < questCost)
			{
				buffMaintain($effect[Throwing Some Shade], 0, 1, 1);
			}
			if((sl_mall_price($item[Shady Shades]) < 20000) && (questCost > 12))
			{
				buffMaintain($effect[Throwing Some Shade], 0, 1, 1);
			}
			if((sl_mall_price($item[Squeaky Toy Rose]) < 20000) && (questCost > 12))
			{
				buffMaintain($effect[A Rose by Any Other Material], 0, 1, 1);
			}
			getHorse("non-combat");

			if(my_adventures() < questCost)
			{
				equip($slot[pants], $item[none]);
				equip($slot[off-hand], $item[none]);
				pulverizeThing($item[A Light That Never Goes Out]);
				pulverizeThing($item[Vicar\'s Tutu]);
				slChew(item_amount($item[Handful of Smithereens]), $item[Handful of Smithereens]);
			}

			if((my_adventures() < questCost) || (sl_mall_price($item[Pocket Wish]) < 35000))
			{
				foreach eff in $effects[Chocolatesphere, Disquiet Riot, Patent Invisibility]
				{
					if(have_effect(eff) == 0)
					{
						makeGenieWish(eff);
					}
				}
			}

			if(do_cs_quest(8))
			{
				curQuest = 0;
			}
			else
			{
				curQuest = 0;
				abort("Could not handle our quest and can not recover");
			}
		}
		break;

	case 9:		#item/booze drops
		{
			if(have_effect($effect[Drenched in Lava]) > 0)
			{
				doHottub();
			}

			if((isOverdueDigitize() || isOverdueArrow()) && elementalPlanes_access($element[stench]))
			{
				print("A Wanderer event is expected now.", "blue");
				slAdv(1, $location[Barf Mountain], "cs_combatNormal");
				return true;
			}

			januaryToteAcquire($item[Wad Of Used Tape]);
			if(have_familiar($familiar[Trick-or-Treating Tot]) && !possessEquipment($item[Li\'l Ninja Costume]))
			{
				if(have_familiar($familiar[Pair of Stomping Boots]))
				{
					buffMaintain($effect[Empathy], 15, 1, 1);
					buffMaintain($effect[Leash of Linguini], 12, 1, 1);
					int runs = (familiar_weight($familiar[Pair of Stomping Boots]) + weight_adjustment()) / 5;
					runs = runs - get_property("_banderRunaways").to_int();
					while(runs > 0)
					{
						handleFamiliar($familiar[Pair of Stomping Boots]);
						backupSetting("choiceAdventure297", "3");
						slAdv(1, $location[The Haiku Dungeon], "cs_combatNormal");
						restoreSetting("choiceAdventure297");
						if($monsters[Ancient Insane Monk, Ferocious Bugbear, Gelatinous Cube, Knob Goblin Poseur] contains last_monster())
						{
							set_property("_banderRunaways", get_property("_banderRunaways").to_int() + 1);
						}
						if(possessEquipment($item[Li\'l Ninja Costume]))
						{
							break;
						}
						runs = runs - 1;
					}
				}
				else if(have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10))
				{
					backupSetting("choiceAdventure297", "3");
					boolean result = slAdv(1, $location[The Haiku Dungeon], "cs_combatNormal");
					restoreSetting("choiceAdventure297");
					return result;
				}
			}

			cs_eat_stuff(curQuest);

			while((my_mp() < 154) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}

			if(have_effect($effect[items.enh]) == 0)
			{
				sl_sourceTerminalEnhance("items");
			}

			buffMaintain($effect[Singer\'s Faithful Ocelot], 15, 1, 1);
			buffMaintain($effect[Empathy], 15, 1, 1);
			buffMaintain($effect[Leash of Linguini], 12, 1, 1);
			buffMaintain($effect[Fat Leon\'s Phat Loot Lyric], 11, 1, 1);
			buffMaintain($effect[Steely-Eyed Squint], 101, 1, 1);
			buffMaintain($effect[Heightened Senses], 0, 1, 1);
			asdonBuff($effect[Driving Observantly]);

			buffMaintain($effect[Spice Haze], 250, 1, 1);

			if((inebriety_left() >= 1) && (have_effect($effect[Sacr&eacute; Mental]) == 0))
			{
				if(item_amount($item[Sacramento Wine]) > 0)
				{
					slDrink(1, $item[Sacramento Wine]);
				}
			}

			buffMaintain($effect[Human-Pirate Hybrid], 0, 1, 1);
			buffMaintain($effect[One Very Clear Eye], 0, 1, 1);
			buffMaintain($effect[Sour Softshoe], 0, 1, 1);
			buffMaintain($effect[Serendipi Tea], 0, 1, 1);

			if(have_effect($effect[Uncucumbered]) == 0)
			{
				fightClubSpa($effect[Uncucumbered]);
			}
			if(is_unrestricted($item[Clan Pool Table]) && (have_effect($effect[Hustlin\']) == 0))
			{
				visit_url("clan_viplounge.php?preaction=poolgame&stance=3");
			}
			if(is_unrestricted($item[Clan Pool Table]) && (have_effect($effect[Billiards Belligerence]) == 0))
			{
				visit_url("clan_viplounge.php?preaction=poolgame&stance=1");
			}

			boolean [familiar] itemFams = $familiars[Gelatinous Cubeling, Syncopated Turtle, Slimeling, Angry Jung Man, Grimstone Golem, Adventurous Spelunker, Jumpsuited Hound Dog, Steam-Powered Cheerleader, Trick-Or-Treating Tot];
			familiar itemFam = $familiar[Cocoabo];
			foreach fam in itemFams
			{
				if(have_familiar(fam))
				{
					itemFam = fam;
				}
			}
			use_familiar(itemFam);
			if(my_familiar() == $familiar[Trick-Or-Treating Tot])
			{
				forceEquip($slot[Familiar], $item[Li\'l Ninja Costume]);
			}

			if(have_effect($effect[Synthesis: Collection]) == 0)
			{
				rethinkingCandy($effect[Synthesis: Collection]);
			}
			if((have_effect($effect[Certainty]) == 0) && (spleen_left() > 0) && (item_amount($item[Abstraction: Certainty]) > 0))
			{
				slChew(1, $item[Abstraction: Certainty]);
			}

			if(!get_property("_incredibleSelfEsteemCast").to_boolean() && (my_mp() > mp_cost($skill[Incredible Self-Esteem])) && have_skill($skill[Incredible Self-Esteem]))
			{
				use_skill(1, $skill[Incredible Self-Esteem]);
			}

			if(get_cs_questCost(curQuest) > 7)
			{
#				makeGenieWish($effect[Frosty]);
				makeGenieWish($effect[Infernal Thirst]);
			}

			if(possessEquipment($item[Greatest American Pants]))
			{
				equip($item[Greatest American Pants]);
				visit_url("inventory.php?action=activatesuperpants");
				run_choice(3);
			}

			if((get_property("sl_csDoWheel").to_boolean()) && (get_cs_questCost(curQuest) > 7))
			{
				deck_cheat("items");
			}

			if((item_amount($item[Astral Pilsner]) > 0) && (inebriety_left() > 0) && (my_adventures() < get_cs_questCost(curQuest)))
			{
				slDrink(min(inebriety_left(), item_amount($item[Astral Pilsner])), $item[Astral Pilsner]);
			}

			if(get_cs_questCost(curQuest) > 7)
			{
				zataraSeaside("item");
			}

			if(do_cs_quest(9))
			{
				curQuest = 0;
				use_familiar(prior);
			}
			else
			{
				curQuest = 0;
				use_familiar(prior);
				abort("Could not handle our quest and can not recover");
			}
			januaryToteAcquire($item[Makeshift Garbage Shirt]);
		}
		break;

	case 10:	#Hot Resistance
		{
			if(canYellowRay())
			{
//				if(is_unrestricted($item[Deluxe Fax Machine]) && (item_amount($item[Potion of Temporary Gr8tness]) == 0) && ($classes[Pastamancer, Sauceror] contains my_class()))
//				{
//					if(handleFaxMonster($monster[Sk8 gnome], "cs_combatYR"))
//					{
//						return true;
//					}
//				}
				if(elementalPlanes_access($element[hot]))
				{
					if((!possessEquipment($item[Fireproof Megaphone]) && !possessEquipment($item[Meteorite Guard])) || !possessEquipment($item[High-Temperature Mining Mask]))
					{
						if(yellowRayCombatString() == ("skill " + $skill[Open a Big Yellow Present]))
						{
							handleFamiliar("yellowray");
						}
						slAdv(1, $location[The Velvet / Gold Mine], "cs_combatYR");
						return true;
					}
				}
			}

			if(Lx_resolveSixthDMT())
			{
				return true;
			}

			# We want to leave some meat for Day 2
			if(have_familiar($familiar[Trick-or-Treating Tot]) && ((my_meat() > 2500) || possessEquipment($item[Li\'l Candy Corn Costume])))
			{
				use_familiar($familiar[Trick-or-Treating Tot]);
				if(!possessEquipment($item[Li\'l Candy Corn Costume]))
				{
					buyUpTo(1, $item[Li\'l Candy Corn Costume]);
				}
				forceEquip($slot[familiar], $item[Li\'l Candy Corn Costume]);
			}
			else if(have_familiar($familiar[Exotic Parrot]))
			{
				use_familiar($familiar[Exotic Parrot]);
				forceEquip($slot[familiar], $item[Astral Pet Sweater]);
			}

			if(possessEquipment($item[lava-proof pants]))
			{
				equip($item[lava-proof pants]);
			}
			else if(possessEquipment($item[Greatest American Pants]))
			{
				equip($item[Greatest American Pants]);
				visit_url("inventory.php?action=activatesuperpants");
				run_choice(2);
			}

			if(possessEquipment($item[Meteorite Guard]))
			{
				equip($item[Meteorite Guard]);
			}
			else if(possessEquipment($item[fireproof megaphone]))
			{
				equip($item[fireproof megaphone]);
			}

			if(possessEquipment($item[high-temperature mining mask]))
			{
				equip($item[high-temperature mining mask]);
			}
			if(possessEquipment($item[heat-resistant gloves]))
			{
				equip($slot[acc1], $item[heat-resistant gloves]);
			}
			if(possessEquipment($item[heat-resistant necktie]))
			{
				equip($slot[acc3], $item[heat-resistant necktie]);
			}

			asdonBuff($effect[Driving Safely]);
			getHorse("resistance");

			while((my_mp() < 37) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}

			boolean [item] toSmash = $items[asparagus knife, dirty hobo gloves, dirty rigging rope, heavy-duty clipboard, Microplushie: Sororitrate, plastic nunchaku, Ratty Knitted Cap, sewage-clogged pistol, Spookyraven Signet, Staff of the Headmaster\'s Victuals];
			foreach it in toSmash
			{
				if((item_amount($item[Sleaze Powder]) > 0) && (item_amount($item[Stench Powder]) > 0))
				{
					break;
				}
				pulverizeThing(it);
			}

			if((item_amount($item[Sleaze Powder]) > 0) && (item_amount($item[Lotion of Sleaziness]) == 0) && (have_effect($effect[Sleazy Hands]) == 0) && (freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && have_skill($skill[Advanced Saucecrafting]))
			{
				if(!have_skills($skills[Expert Corner-Cutter, Rapid Prototyping]) && have_skill($skill[Inigo\'s Incantation of Inspiration]))
				{
					shrugAT($effect[Inigo\'s Incantation of Inspiration]);
					buffMaintain($effect[Inigo\'s Incantation of Inspiration], 100, 1, 5);
				}

				cli_execute("make " + $item[Lotion Of Sleaziness]);
			}
			if((item_amount($item[Stench Powder]) > 0) && (item_amount($item[Lotion of Stench]) == 0) && (have_effect($effect[Stinky Hands]) == 0) && (freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && have_skill($skill[Advanced Saucecrafting]))
			{
				if(!have_skills($skills[Expert Corner-Cutter, Rapid Prototyping]) && have_skill($skill[Inigo\'s Incantation of Inspiration]))
				{
					shrugAT($effect[Inigo\'s Incantation of Inspiration]);
					buffMaintain($effect[Inigo\'s Incantation of Inspiration], 100, 1, 5);
				}
				cli_execute("make " + $item[Lotion Of Stench]);
			}

			if(!get_property("_mayoTankSoaked").to_boolean() && (sl_get_campground() contains $item[Portable Mayo Clinic]) && is_unrestricted($item[Portable Mayo Clinic]))
			{
				string temp = visit_url("shop.php?action=bacta&whichshop=mayoclinic");
			}

			buffMaintain($effect[Protection from Bad Stuff], 0, 1, 1);
			buffMaintain($effect[Human-Elemental Hybrid], 0, 1, 1);
			buffMaintain($effect[Elemental Saucesphere], 10, 1, 1);
			if(my_familiar() == $familiar[Exotic Parrot])
			{
				buffMaintain($effect[Leash of Linguini], 12, 1, 1);
				buffMaintain($effect[Empathy], 15, 1, 1);
			}
			buffMaintain($effect[Astral Shell], 10, 1, 1);
			buffMaintain($effect[Sleazy Hands], 0, 1, 1);
			buffMaintain($effect[Egged On], 0, 1, 1);
			buffMaintain($effect[Flame-Retardant Trousers], 0, 1, 1);
			buffMaintain($effect[Stinky Hands], 0, 1, 1);
			buffMaintain($effect[Human-Machine Hybrid], 0, 1, 1);
			buffMaintain($effect[Frost Tea], 0, 1, 1);
			buffMaintain($effect[Berry Elemental], 0, 1, 1);
			buffMaintain($effect[Amazing], 0, 1, 1);

			if(get_property("spacegateVaccine1").to_boolean() && !get_property("_spacegateVaccine").to_boolean() && (have_effect($effect[Rainbow Vaccine]) == 0) && get_property("spacegateAlways").to_boolean())
			{
				cli_execute("spacegate vaccine 1");
			}

			int curCost = get_cs_questCost(curQuest);

			if((have_effect($effect[Synthesis: Hot]) == 0) && (curCost >= 6))
			{
				rethinkingCandy($effect[Synthesis: Hot]);
				curCost -= 9;
			}

			if(curCost >= 3)
			{
				buffMaintain($effect[Spiro Gyro], 0, 1, 1);
			}

			cs_eat_stuff(curQuest);

			if(do_cs_quest(10))
			{
				curQuest = 0;
				equip($slot[hat], $item[none]);
				equip($slot[pants], $item[none]);
				equip($slot[off-hand], $item[none]);
				equip($slot[acc1], $item[none]);
				equip($slot[acc3], $item[none]);
				use_familiar(prior);
			}
			else
			{
				curQuest = 0;
				equip($slot[hat], $item[none]);
				equip($slot[pants], $item[none]);
				equip($slot[off-hand], $item[none]);
				equip($slot[acc1], $item[none]);
				equip($slot[acc3], $item[none]);
				use_familiar(prior);
				abort("Could not handle our quest and can not recover");
			}
		}
		break;

	case 11:
		{
			abort("Beep, should not be trying quest 11 at this point in the script");

			if(do_cs_quest(11))
			{
				use(1, $item[A Ten-Percent Bonus]);
				curQuest = 0;
			}
			else
			{
				curQuest = 0;
				abort("Could not handle our quest and can not recover");
			}
		}
		break;

	default:
		abort("No quest remaining or detectable. Maybe we are already done?");
		break;

	}
	return true;
}

boolean cs_witchess()
{
	if(my_path() != "Community Service")
	{
		return false;
	}
	if(!sl_haveWitchess())
	{
		return false;
	}

	if(get_property("_sl_witchessBattles").to_int() >= 5)
	{
		return false;
	}
#	if(get_property("_witchessFights").to_int() >= 5)
#	{
#		return false;
#	}

	print("Let's do a Witchess combat!", "green");

	if((get_property("_badlyRomanticArrows").to_int() != 1) && have_familiar($familiar[Reanimated Reanimator]))
	{
		handleFamiliar($familiar[Reanimated Reanimator]);
	}
	else if((get_property("_badlyRomanticArrows").to_int() != 1) && have_familiar($familiar[Obtuse Angel]))
	{
		handleFamiliar($familiar[Obtuse Angel]);
	}
	else if(have_familiar($familiar[Galloping Grill]) && sl_haveSourceTerminal())
	{
		handleFamiliar($familiar[Galloping Grill]);
	}

	if(get_property("_sourceTerminalDigitizeUses").to_int() == 0)
	{
		sl_sourceTerminalEducate($skill[Digitize], $skill[Extract]);
	}
	boolean result;
	if((my_daycount() == 1) && (item_amount($item[Greek Fire]) == 0) && !have_skill($skill[Digitize]))
	{
		result = sl_advWitchess("rook", "cs_combatNormal");
	}
	else
	{
		string goal = "booze";
		if(item_amount($item[Sacramento Wine]) >= 5)
		{
			goal = "food";
		}

/*
		//Ugh, this is an actual pain to handle. (Might be better if we use an attacking familiar)
		if(!in_hardcore() && !possessEquipment($item[Ox-Head Shield]))
		{
			if(my_mp() > 100)
			{
				goal = "shield"; 
			}
		}
*/

		result = sl_advWitchess(goal, "cs_combatNormal");
	}
	sl_sourceTerminalEducate($skill[Extract], $skill[Duplicate]);
	return result;
}

void cs_initializeDay(int day)
{
	if(my_path() != "Community Service")
	{
		return;
	}

	if(get_property("nsTowerDoorKeysUsed") == "")
	{
		set_property("nsTowerDoorKeysUsed", "Boris's key,Jarlsberg's key,Sneaky Pete's key,Richard's star key,skeleton key,digital key");
	}

	set_property("choiceAdventure1106", 2);
	set_property("choiceAdventure1108", 3);

	if(day == 1)
	{
		if(get_property("sl_day_init").to_int() < 1)
		{
			set_property("sl_day1_dna", "finished");
			if(!have_familiar($familiar[Puck Man]) && !have_familiar($familiar[Ms. Puck Man]))
			{
				set_property("sl_csPuckCounter", 20);
			}
			if(item_amount($item[transmission from planet Xi]) > 0)
			{
				use(1, $item[transmission from planet xi]);
			}
			if(item_amount($item[Xiblaxian holo-wrist-puter simcode]) > 0)
			{
				use(1, $item[Xiblaxian holo-wrist-puter simcode]);
			}

			if(have_skill($skill[Spirit of Peppermint]))
			{
				use_skill(1, $skill[Spirit of Peppermint]);
			}

			if(have_skill($skill[Iron Palm Technique]) && (have_effect($effect[Iron Palms]) == 0) && (my_class() == $class[Seal Clubber]))
			{
				use_skill(1, $skill[Iron Palm Technique]);
			}

			visit_url("tutorial.php?action=toot");
			use(item_amount($item[Letter From King Ralph XI]), $item[Letter From King Ralph XI]);
			use(item_amount($item[Pork Elf Goodies Sack]), $item[Pork Elf Goodies Sack]);
			tootGetMeat();

			sl_sourceTerminalEducate($skill[Extract], $skill[Turbo]);

			if(contains_text(get_property("sourceTerminalEnquiryKnown"), "stats.enq"))
			{
				sl_sourceTerminalRequest("enquiry stats.enq");
			}
			else if(contains_text(get_property("sourceTerminalEnquiryKnown"), "protect.enq"))
			{
				sl_sourceTerminalRequest("enquiry protect.enq");
			}
			else if(contains_text(get_property("sourceTerminalEnquiryKnown"), "familiar.enq"))
			{
				sl_sourceTerminalRequest("enquiry familiar.enq");
			}

			equipBaseline();
			visit_url("guild.php?place=challenge");

			if(get_property("sl_csDoWheel").to_boolean())
			{
				if((get_property("spookyAirportAlways").to_boolean()) && !get_property("_controlPanelUsed").to_boolean())
				{
					visit_url("place.php?whichplace=airport_spooky_bunker&action=si_controlpanel");
					visit_url("choice.php?pwd=&whichchoice=986&option=9",true);
				}
			}

			if(!get_property("sl_csDoWheel").to_boolean())
			{
				deck_cheat(my_primestat() + " stat");
			}
			deck_cheat("meat");
			deck_cheat("green mana");
			autosell(item_amount($item[1952 Mickey Mantle Card]), $item[1952 Mickey Mantle Card]);

			if(!possessEquipment($item[Turtle Totem]))
			{
				acquireGumItem($item[Turtle Totem]);
			}
			if(!possessEquipment($item[Saucepan]) && !possessEquipment($item[Saucepanic]))
			{
				acquireGumItem($item[Saucepan]);
			}

			if(knoll_available())
			{
				if(item_amount($item[Bitchin\' Meatcar]) == 0)
				{
					cli_execute("make bitch");
				}
				if(item_amount($item[Deck Of Every Card]) > 0)
				{
					buyUpTo(1, $item[Antique Accordion]);
				}
				else
				{
					buyUpTo(1, $item[Toy Accordion]);
				}
			}
			else
			{
				buyUpTo(1, $item[Toy Accordion]);
			}

			if(have_skill($skill[Summon Smithsness]))
			{
				while((my_mp() >= mp_cost($skill[Summon Smithsness])) && (get_property("tomeSummons").to_int() < 3))
				{
					use_skill(1, $skill[Summon Smithsness]);
				}
			}

			if(!(sl_get_campground() contains $item[Packet Of Tall Grass Seeds]))
			{
				cli_execute("garden pick");
			}
			if(!sl_haveWitchess())
			{
				if((item_amount($item[Ice Harvest]) >= 3) && (item_amount($item[Snow Berries]) >= 1))
				{
					cli_execute("make " + $item[Ice Island Long Tea]);
				}
			}

			startMeatsmithSubQuest();

			if(have_familiar($familiar[Crimbo Shrub]) && !get_property("_shrubDecorated").to_boolean())
			{
				familiar last = my_familiar();
				int gift = 1;
				if(is100FamiliarRun() && (my_familiar() != $familiar[Crimbo Shrub]))
				{
					gift = 2;
				}
				use_familiar($familiar[Crimbo Shrub]);
				visit_url("inv_use.php?pwd=&which=3&whichitem=7958");
				visit_url("choice.php?pwd=&whichchoice=999&option=1&topper=2&lights=1&garland=3&gift=" + gift);
				use_familiar(last);
			}

			if(get_property("barrelShrineUnlocked").to_boolean())
			{
				handleBarrelFullOfBarrels(true);
			}

			if(get_property("sl_breakstone").to_boolean())
			{
				string temp = visit_url("peevpee.php?action=smashstone&pwd&confirm=on", true);
				temp = visit_url("peevpee.php?place=fight");
				set_property("sl_breakstone", false);
			}
			set_property("sl_day_init", 1);
			try
			{
				visit_url("council.php");
			}
			finally
			{
				print("Visited Council for first time, if you manually visited the council before running, this might have aborted, just run again.", "red");
			}
		}
	}
	else if(day == 2)
	{
		if(get_property("sl_day_init").to_int() < 2)
		{
			equipBaseline();

			//We should only make this if the quests are still left.
			if(item_amount($item[Green Mana]) < 3)
			{
				deck_cheat("Giant Growth");
			}
			if(item_amount($item[Green Mana]) < 3)
			{
				deck_cheat("green mana");
			}

			if(have_skill($skill[Summon Smithsness]))
			{
				while((my_mp() >= mp_cost($skill[Summon Smithsness])) && (get_property("tomeSummons").to_int() < 2))
				{
					use_skill(1, $skill[Summon Smithsness]);
				}

				if(have_skill($skill[Summon Clip Art]) && (my_mp() >= mp_cost($skill[Summon Clip Art])) && (get_property("tomeSummons").to_int() < 3))
				{
					cli_execute("make " + $item[Cold-Filtered Water]);
				}
				else if((my_mp() >= mp_cost($skill[Summon Smithsness])) && (get_property("tomeSummons").to_int() < 3))
				{
					use_skill(1, $skill[Summon Smithsness]);
				}
			}

			if((item_amount($item[Seal Tooth]) == 0) && have_skill($skill[Ambidextrous Funkslinging]))
			{
				acquireHermitItem($item[Seal Tooth]);
			}

			if(!(sl_get_campground() contains $item[Packet Of Tall Grass Seeds]))
			{
				cli_execute("garden pick");
			}
			if(!possessEquipment($item[Saucepan]))
			{
				acquireGumItem($item[Saucepan]);
			}

			cli_execute("postsool");

			if((get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
			}

			set_property("sl_day_init", 2);
		}
	}
}

boolean do_chateauGoat()
{
	if(!get_property("_chateauMonsterFought").to_boolean() && chateaumantegna_available() && (get_property("chateauMonster") == $monster[dairy goat]))
	{
		foreach eff in $effects[Reptilian Fortitude, Power Ballad of the Arrowsmith, Astral Shell, Ghostly Shell, Blubbered Up, Springy Fusilli, The Moxious Madrigal, Cletus\'s Canticle of Celerity, Walberg\'s Dim Bulb]
		{
			buffMaintain(eff, mp_cost(to_skill(eff)), 1, 1);
		}
		cli_execute("postsool");
		doRest();
		foreach eff in $effects[Astral Shell, Ghostly Shell, Blubbered Up, Springy Fusilli, The Moxious Madrigal, Cletus\'s Canticle of Celerity, Walberg\'s Dim Bulb]
		{
			buffMaintain(eff, mp_cost(to_skill(eff)), 1, 1);
		}

		sl_sourceTerminalEducate($skill[Compress], $skill[Turbo]);

		if(canYellowRay())
		{
			if(yellowRayCombatString() == ("skill " + $skill[Open a Big Yellow Present]))
			{
				handleFamiliar("yellowray");
			}
			chateaumantegna_usePainting("cs_combatYR");
		}
		else
		{
			chateaumantegna_usePainting("cs_combatNormal");
		}
		if((item_amount($item[Glass of Goat\'s Milk]) > 0) && (freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0))
		{
			if(!have_skills($skills[Expert Corner-Cutter, Rapid Prototyping]) && have_skill($skill[Inigo\'s Incantation of Inspiration]))
			{
				shrugAT($effect[Inigo\'s Incantation of Inspiration]);
				buffMaintain($effect[Inigo\'s Incantation of Inspiration], 100, 1, 5);
			}
			cli_execute("make " + $item[Milk Of Magnesium]);
		}
		sl_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
		return true;
	}
	return false;
}

boolean cs_spendRests()
{
	if(my_path() != "Community Service")
	{
		return false;
	}
	if(my_inebriety() <= inebriety_limit())
	{
		return false;
	}
	while((get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
	{
		doRest();
	}
	return true;
}

void cs_make_stuff(int curQuest)
{
	if(item_amount($item[skeleton key]) == 0)
	{
		if((item_amount($item[skeleton bone]) > 0) && (item_amount($item[loose teeth]) > 0))
		{
			cli_execute("make " + $item[Skeleton Key]);
		}
	}
	if((item_amount($item[Milk of Magnesium]) == 0) && (item_amount($item[Glass of Goat\'s Milk]) > 0) && have_skill($skill[Advanced Saucecrafting]) && (freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0))
	{
		if(!have_skills($skills[Expert Corner-Cutter, Rapid Prototyping]) && have_skill($skill[Inigo\'s Incantation of Inspiration]))
		{
			shrugAT($effect[Inigo\'s Incantation of Inspiration]);
			buffMaintain($effect[Inigo\'s Incantation of Inspiration], 100, 1, 5);
		}
		cli_execute("make " + $item[Milk Of Magnesium]);
	}


	if(my_daycount() == 1)
	{
		if(!possessEquipment($item[Hairpiece on Fire]) && (item_amount($item[Lump of Brituminous Coal]) > 0) && !get_property("sl_hccsNoConcludeDay").to_boolean())
		{
			if(knoll_available() || (item_amount($item[Maiden Wig]) > 0))
			{
				cli_execute("make " + $item[Hairpiece On Fire]);
			}
		}
		switch(my_class())
		{
		case $class[Seal Clubber]:
			if(!possessEquipment($item[Meat Tenderizer Is Murder]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
			{
				if(!possessEquipment($item[Seal-Clubbing Club]))
				{
					acquireGumItem($item[Seal-Clubbing Club]);
				}
				cli_execute("make " + $item[Meat Tenderizer Is Murder]);
			}
			break;
		case $class[Turtle Tamer]:
			if(!possessEquipment($item[Work Is A Four Letter Sword]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
			{
				if(item_amount($item[Sword Hilt]) == 0)
				{
					cli_execute("buy 1 " + $item[Sword Hilt]);
				}
				cli_execute("make " + $item[Work Is A Four Letter Sword]);
			}
			break;
		case $class[Pastamancer]:
			if(!possessEquipment($item[Hand That Rocks The Ladle]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
			{
				if(!possessEquipment($item[Pasta Spoon]))
				{
					acquireGumItem($item[Pasta Spoon]);
				}
				cli_execute("make " + $item[Hand That Rocks The Ladle]);
			}
			break;
		case $class[Sauceror]:
			if(!possessEquipment($item[Saucepanic]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
			{
				if(!possessEquipment($item[Saucepan]))
				{
					acquireGumItem($item[Saucepan]);
				}
				cli_execute("make " + $item[Saucepanic]);
			}
			break;
		case $class[Disco Bandit]:
			if(!possessEquipment($item[Frankly Mr. Shank]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
			{
				if(!possessEquipment($item[Disco Ball]))
				{
					acquireGumItem($item[Disco Ball]);
				}
				cli_execute("make " + $item[Frankly Mr. Shank]);
			}
			break;
		case $class[Accordion Thief]:
			if(!possessEquipment($item[Shakespeare\'s Sister\'s Accordion]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
			{
				if(!possessEquipment($item[Stolen Accordion]))
				{
					acquireGumItem($item[Stolen Accordion]);
				}
				cli_execute("make " + $item[Shakespeare\'s Sister\'s Accordion]);
			}
			break;
		}
		if(!possessEquipment($item[A Light that Never Goes Out]) && (item_amount($item[Lump of Brituminous Coal]) > 0) && (curQuest == 9))
		{
			cli_execute("make " + $item[A Light that Never Goes Out]);
		}
	}
	if(my_daycount() == 2)
	{
		if((available_amount($item[Saucepanic]) == 1) && (item_amount($item[Lump of Brituminous Coal]) > 0) && have_skill($skill[Double-Fisted Skull Smashing]))
		{
			if(!possessEquipment($item[Saucepan]))
			{
				acquireGumItem($item[Saucepan]);
			}
			cli_execute("make " + $item[Saucepanic]);
		}
		if(knoll_available() || possessEquipment($item[Frilly Skirt]))
		{
			if(!possessEquipment($item[Vicar\'s Tutu]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
			{
				cli_execute("make " + $item[Vicar\'s Tutu]);
			}
		}

		if(!possessEquipment($item[Staff of the Headmaster\'s Victuals]) && (item_amount($item[Lump of Brituminous Coal]) > 0) && have_skill($skill[Spirit of Rigatoni]))
		{
			cli_execute("make " + $item[Staff of the Headmaster\'s Victuals]);
		}

		if(!have_familiar($familiar[Machine Elf]) && !is100FamiliarRun())
		{
			if(item_amount($item[Handful of Smithereens]) >= 3)
			{
				cli_execute("make 3 " + $item[Louder Than Bomb]);
			}
		}

		if((item_amount($item[Scrumptious Reagent]) >= 5) && have_skill($skill[Advanced Saucecrafting]))
		{
			if(!have_skill($skill[Rapid Prototyping]) && have_skill($skill[Inigo\'s Incantation of Inspiration]))
			{
				shrugAT($effect[Inigo\'s Incantation of Inspiration]);
				buffMaintain($effect[Inigo\'s Incantation of Inspiration], 100, 3, 25);
			}

			if((item_amount($item[gr8ps]) > 0) && (item_amount($item[Potion of Temporary Gr8ness]) == 0) && (npc_price($item[Delectable Catalyst]) < my_meat()) && ($classes[Sauceror, Pastamancer] contains my_class()) && (freeCrafts() > 0) && have_skill($skill[The Way of Sauce]))
			{
				cli_execute("make " + $item[Potion of Temporary Gr8ness]);
			}
			if((item_amount($item[grapefruit]) > 0) && (item_amount($item[Ointment of the Occult]) == 0) && (freeCrafts() > 0))
			{
				cli_execute("make " + $item[Ointment Of The Occult]);
			}
			if((item_amount($item[lemon]) > 0) && (item_amount($item[philter of phorce]) == 0) && (freeCrafts() > 0))
			{
				cli_execute("make " + $item[philter of phorce]);
			}
			if((item_amount($item[squashed frog]) > 0) && (item_amount($item[Frogade]) == 0) && (freeCrafts() > 0))
			{
				cli_execute("make " + $item[Frogade]);
			}
			if((item_amount($item[eye of newt]) > 0) && (item_amount($item[Eyedrops of Newt]) == 0) && (freeCrafts() > 0))
			{
				cli_execute("make " + $item[Eyedrops Of Newt]);
			}
			else if((item_amount($item[salamander spleen]) > 0) && (item_amount($item[Salamander Slurry]) == 0) && (freeCrafts() > 0))
			{
				cli_execute("make " + $item[Salamander Slurry]);
			}
		}

		if((item_amount($item[Yellow Pixel]) >= 15) && (item_amount($item[Black Pixel]) >= 2) && (item_amount($item[Pixel Star]) == 0))
		{
			cli_execute("make " + $item[Pixel Star]);
		}
		if(item_amount($item[Yellow Pixel]) >= 15)
		{
			cli_execute("make " + $item[Miniature Power Pill]);
		}

	}
}

boolean cs_eat_spleen()
{
	if(my_path() != "Community Service")
	{
		return false;
	}
	if(my_daycount() > 1)
	{
		return false;
	}

	int oldSpleenUse = my_spleen_use();
	while((my_spleen_use() < 12) && ((item_amount($item[Unconscious Collective Dream Jar]) + item_amount($item[Grim Fairy Tale]) + item_amount($item[Powdered Gold]) + item_amount($item[Groose Grease]) + item_amount($item[Agua De Vida])) > 0))
	{
		if((item_amount($item[Agua De Vida]) > 0) && (my_level() >= 4))
		{
			slChew(1, $item[Agua De Vida]);
			continue;
		}
		foreach it in $items[Unconscious Collective Dream Jar, Grim Fairy Tale, Powdered Gold, Groose Grease]
		{
			if(item_amount(it) > 0)
			{
				slChew(1, it);
				break;
			}
		}
		uneffect($effect[Just the Best Anapests]);
	}
	return oldSpleenUse != my_spleen_use();
}

boolean cs_eat_stuff(int quest)
{
	if(my_path() != "Community Service")
	{
		return false;
	}

	if((quest == 0) && (my_fullness() == 0))
	{
		if(sl_haveSourceTerminal())
		{
			if((item_amount($item[Source Essence]) < 10) && (item_amount($item[Browser Cookie]) == 0))
			{
				return false;
			}
		}
		if(item_amount($item[Milk of Magnesium]) > 0)
		{
			use(1, $item[Milk of Magnesium]);
		}
		if(get_property("sl_noSleepingDog").to_boolean() || have_skill($skill[Dog Tired]))
		{
			if(sl_sourceTerminalExtrudeLeft() > 0)
			{
				if(item_amount($item[Browser Cookie]) == 0)
				{
					sl_sourceTerminalExtrude($item[Browser Cookie]);
				}
			}

			if(item_amount($item[Browser Cookie]) > 0)
			{
				slEat(1, $item[Browser Cookie]);
			}
			else
			{
				eatFancyDog("savage macho dog");
			}
		}
		else
		{
			eatFancyDog("sleeping dog");
		}

		if((item_amount($item[Handful of Smithereens]) > 0) && (my_fullness() <= 3))
		{
			cli_execute("make " + $item[This Charming Flan]);
			eat(1, $item[This Charming Flan]);
		}
		if((item_amount($item[Meteoreo]) > 0) && (my_fullness() <= 4))
		{
			eat(1, $item[Meteoreo]);
		}
		if((item_amount($item[Snow Berries]) > 1) && (my_fullness() <= 4))
		{
			cli_execute("make " + $item[Snow Crab]);
			eat(1, $item[Snow Crab]);
		}
	}

	if(quest == 9)
	{
		if(item_amount($item[Weird Gazelle Steak]) > 0)
		{
			if(item_amount($item[Milk of Magnesium]) > 0)
			{
				use(1, $item[Milk of Magnesium]);
			}
			slEat(1, $item[Weird Gazelle Steak]);

			if(get_property("sl_noSleepingDog").to_boolean())
			{
				if(sl_sourceTerminalExtrudeLeft() > 0)
				{
					if((item_amount($item[Browser Cookie]) == 0) && (fullness_left() >= 4))
					{
						sl_sourceTerminalExtrude($item[Browser Cookie]);
					}
				}

				if((item_amount($item[Browser Cookie]) > 0) && (fullness_left() >= 4))
				{
					slEat(1, $item[Browser Cookie]);
				}
				else
				{
					eatFancyDog("savage macho dog");
				}
			}
			else
			{
				eatFancyDog("sleeping dog");
			}
			if((item_amount($item[Handful of Smithereens]) > 0) && (fullness_left() >= 2))
			{
				cli_execute("make " + $item[This Charming Flan]);
				eat(1, $item[This Charming Flan]);
			}
			if((item_amount($item[Meteoreo]) > 0) && (fullness_left() >= 1))
			{
				eat(1, $item[Meteoreo]);
			}
			if((item_amount($item[Snow Berries]) > 1) && (fullness_left() >= 1))
			{
				cli_execute("make " + $item[Snow Crab]);
				eat(1, $item[Snow Crab]);
			}

		}
	}
	else if(quest == 10)
	{
		if((item_amount($item[Sausage Without A Cause]) > 0) && !get_property("sl_saveSausage").to_boolean())
		{
			if(item_amount($item[Milk of Magnesium]) > 0)
			{
				use(1, $item[Milk of Magnesium]);
			}
			eat(1, $item[Sausage Without A Cause]);
			if(item_amount($item[Ice Harvest]) > 0)
			{
				eat(1, $item[Ice Harvest]);
			}
			if(item_amount($item[Snow Berries]) > 1)
			{
				cli_execute("make " + $item[Snow Crab]);
				eat(1, $item[Snow Crab]);
			}

			int questCost = get_cs_questCost(quest);
			
			if((fullness_left() >= 2) && (questCost > 20))
			{
				eatFancyDog("junkyard dog");
			}
		}
	}
	return true;
}

void cs_dnaPotions()
{
	if(my_path() != "Community Service")
	{
		return;
	}
	dna_generic();

	if((get_property("dnaSyringe") == $phylum[fish]) && !get_property("_dnaHybrid").to_boolean() && (my_daycount() == 1))
	{
		cli_execute("camp dnainject");
	}
}

string cs_combatNormal(int round, string opp, string text)
{
	if(round == 0)
	{
		print("sl_combatHandler: " + round, "brown");
		set_property("sl_combatHandler", "");
	}

	set_property("sl_diag_round", round);
	if(get_property("sl_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	monster enemy = to_monster(opp);
	string combatState = get_property("sl_combatHandler");

	phylum current = to_phylum(get_property("dnaSyringe"));
	phylum type = monster_phylum(enemy);

	if(!contains_text(combatState, "lattegulp") && !have_skill($skill[Turbo]) && ((3 * my_mp()) < my_maxmp()) && (my_maxmp() >= 300) && !get_property("_latteDrinkUsed").to_boolean() && have_skill($skill[Gulp Latte]) && !($monsters[LOV Enforcer, LOV Engineer, LOV Equivocator] contains enemy))
	{
		set_property("sl_combatHandler", combatState + "(lattegulp)");
		return "skill " + $skill[Gulp Latte];
	}

	if(!contains_text(combatState, "snokebomb") && have_skill($skill[Snokebomb]) && (get_property("_snokebombUsed").to_int() < 3) && ((my_mp() - 20) >= mp_cost($skill[Snokebomb])))
	{
		if($monsters[Flame-Broiled Meat Blob, Overdone Flame-Broiled Meat Blob, Swarm of Skulls] contains enemy)
		{
			set_property("sl_combatHandler", combatState + "(Snokebomb)");
			handleTracker(enemy, $skill[Snokebomb], "sl_banishes");
			return "skill " + $skill[Snokebomb];
		}
	}

	if(!contains_text(combatState, "throwlatte") && have_skill($skill[Throw Latte On Opponent]) && !get_property("_latteBanishUsed").to_boolean() && (my_mp() >= mp_cost($skill[Throw Latte On Opponent])))
	{
		if($monsters[Undead Elbow Macaroni, Factory-Irregular Skeleton, Octorok] contains enemy)
		{
			set_property("sl_combatHandler", combatState + "(throwlatte)");
			handleTracker(enemy, $skill[Throw Latte On Opponent], "sl_banishes");
			return "skill " + $skill[Throw Latte On Opponent];
		}
	}

	if(!contains_text(combatState, $skill[KGB Tranquilizer Dart]) && have_skill($skill[KGB Tranquilizer Dart]) && (get_property("_kgbTranquilizerDartUses").to_int() < 3))
	{
		if($monsters[Flame-Broiled Meat Blob, Keese, Overdone Flame-Broiled Meat Blob, Remaindered Skeleton] contains enemy)
		{
			set_property("sl_combatHandler", combatState + "(" + $skill[KGB Tranquilizer Dart] + ")");
			handleTracker(enemy, $skill[KGB Tranquilizer Dart], "sl_banishes");
			return "skill " + $skill[KGB Tranquilizer Dart];
		}
	}

	if((my_location() == $location[The Skeleton Store]) && have_skill($skill[Meteor Lore]) &&(get_property("_macrometeoriteUses").to_int() < 10))
	{
		if($monsters[Factory-Irregular Skeleton, Remaindered Skeleton, Swarm of Skulls] contains enemy)
		{
			return "skill " + $skill[Macrometeorite];
		}
	}

	if((my_familiar() == $familiar[Pair of Stomping Boots]) && ($monsters[Ancient Insane Monk, Ferocious Bugbear, Gelatinous Cube, Knob Goblin Poseur] contains enemy))
	{
		return "runaway";
	}

	if((my_location() == $location[The Haiku Dungeon]) && have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10))
	{
		if($monsters[Ancient Insane Monk, Ferocious Bugbear, Gelatinous Cube, Knob Goblin Poseur] contains enemy)
		{
			print("Macrometeoring: " + enemy, "green");
			set_property("_macrometeoriteUses", 1 + get_property("_macrometeoriteUses").to_int());
			return "skill " + $skill[Macrometeorite];
		}
	}


	if((my_location() == $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice]) && !contains_text(combatState, "love gnats"))
	{
		combatState = combatState + "(love gnats)(love stinkbug)(love mosquito)";
		set_property("sl_combatHandler", combatState);
	}

	if((enemy == $monster[LOV Enforcer]) && (my_familiar() == $familiar[Nosy Nose]))
	{
		if(my_hp() > (2*expected_damage()))
		{
			return "attack with weapon";
		}
	}
	if(enemy == $monster[LOV Engineer])
	{
#		if(!contains_text(combatState, "weaksauce") && (have_skill($skill[Curse Of Weaksauce])) && (my_mp() >= 32))
#		{
#			set_property("sl_combatHandler", combatState + "(weaksauce)");
#			return "skill " + $skill[Curse Of Weaksauce];
#		}

		if(!contains_text(combatState, "(candyblast)") && have_skill($skill[Candyblast]) && (my_mp() > (mp_cost($skill[Candyblast]) * 3)) && (my_class() != $class[Sauceror]))
		{
			set_property("sl_combatHandler", combatState + "(candyblast)");
			return "skill " + $skill[Candyblast];
		}

		if(have_skill($skill[Saucestorm]) && (my_mp() >= mp_cost($skill[Saucestorm])))
		{
			return "skill " + $skill[Saucestorm];
		}
	}

	if(!contains_text(combatState, "love gnats") && have_skill($skill[Summon Love Gnats]))
	{
		set_property("sl_combatHandler", combatState + "(love gnats)");
		return "skill " + $skill[Summon Love Gnats];
	}

	if((have_effect($effect[On The Trail]) == 0) && have_skill($skill[Transcendent Olfaction]) && (my_mp() >= mp_cost($skill[Transcendent Olfaction])))
	{
		boolean doOlfaction = false;
		if((item_amount($item[Time-Spinner]) == 0) || (get_property("_timeSpinnerMinutesUsed").to_int() >= 8))
		{
			if($monsters[Novelty Tropical Skeleton, Possessed Can of Tomatoes] contains enemy)
			{
				doOlfaction = true;
			}
		}

		if(($monster[Government Scientist] == enemy) && (item_amount($item[Experimental Serum G-9]) < 2))
		{
			doOlfaction = true;
		}

		if(doOlfaction)
		{
			if(!contains_text(combatState, "weaksauce") && have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 72))
			{
				set_property("sl_combatHandler", combatState + "(weaksauce)");
				return "skill " + $skill[Curse Of Weaksauce];
			}
			if(!contains_text(combatState, "soulbubble") && have_skill($skill[Soul Saucery]) && (my_soulsauce() >= soulsauce_cost($skill[Soul Bubble])))
			{
				set_property("sl_combatHandler", combatState + "(soulbubble)");
				return "skill " + $skill[Soul Bubble];
			}

			set_property("sl_combatHandler", combatState + "(olfaction)");
			handleTracker(enemy, $skill[Transcendent Olfaction], "sl_sniffs");
			return "skill " + $skill[Transcendent Olfaction];
		}
	}

	if(!contains_text(combatState, "(lattesniff)") && have_skill($skill[Offer Latte To Opponent]) && (my_mp() >= mp_cost($skill[Offer Latte To Opponent])) && !get_property("_latteCopyUsed").to_boolean())
	{
		if(($monster[Government Scientist] == enemy) && (get_property("_latteMonster") != enemy))
		{
			if((!contains_text(combatState, "weaksauce")) && have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 72))
			{
				set_property("sl_combatHandler", combatState + "(weaksauce)");
				return "skill " + $skill[Curse Of Weaksauce];
			}
			if(!contains_text(combatState, "soulbubble") && have_skill($skill[Soul Saucery]) && (my_soulsauce() >= soulsauce_cost($skill[Soul Bubble])))
			{
				set_property("sl_combatHandler", combatState + "(soulbubble)");
				return "skill " + $skill[Soul Bubble];
			}

			set_property("sl_combatHandler", combatState + "(lattesniff)");
			handleTracker(enemy, $skill[Offer Latte To Opponent], "sl_sniffs");
			return "skill " + $skill[Offer Latte To Opponent];
		}
	}

	if(((have_effect($effect[On The Trail]) < 40) || (contains_text(combatState, "(lattesniff)"))) && have_skill($skill[Gallapagosian Mating Call]) && (my_mp() >= mp_cost($skill[Gallapagosian Mating Call])) && !contains_text(combatState, "(matingcall)"))
	{
		if(($monster[Government Scientist] == enemy) && (get_property("_gallapagosMonster") != enemy))
		{
			if((!contains_text(combatState, "weaksauce")) && have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 72))
			{
				set_property("sl_combatHandler", combatState + "(weaksauce)");
				return "skill " + $skill[Curse Of Weaksauce];
			}
			if(!contains_text(combatState, "soulbubble") && have_skill($skill[Soul Saucery]) && (my_soulsauce() >= soulsauce_cost($skill[Soul Bubble])))
			{
				set_property("sl_combatHandler", combatState + "(soulbubble)");
				return "skill " + $skill[Soul Bubble];
			}

			set_property("sl_combatHandler", combatState + "(matingcall)");
			handleTracker(enemy, $skill[Gallapagosian Mating Call], "sl_sniffs");
			return "skill " + $skill[Gallapagosian Mating Call];
		}
	}


	if(!contains_text(combatState, "cleesh") && have_skill($skill[Cleesh]) && (my_mp() > mp_cost($skill[Cleesh])) && ((enemy == $monster[creepy little girl]) || (enemy == $monster[lab monkey]) || (enemy == $monster[super-sized cola wars soldier])) && (item_amount($item[Experimental Serum G-9]) < 2))
	{
		set_property("sl_combatHandler", combatState + "(cleesh)");
		return "skill " + $skill[CLEESH];
	}

	if(!contains_text(combatState, "DNA") && (item_amount($item[DNA Extraction Syringe]) > 0))
	{
		if(type != current)
		{
			set_property("sl_combatHandler", combatState + "(DNA)");
			return "item " + $item[DNA Extraction Syringe];
		}
	}

	if(!contains_text(combatState, "winkat") && (my_familiar() == $familiar[Reanimated Reanimator]))
	{
		if($monsters[Witchess Bishop, Witchess Knight] contains enemy)
		{
			set_property("sl_combatHandler", combatState + "(winkat)");
			if((get_property("_badlyRomanticArrows").to_int() == 1) && (get_property("romanticTarget") != enemy))
			{
				abort("Have animator out but can not arrow");
			}
			return "skill " + $skill[Wink At];
		}
	}

	if(!contains_text(combatState, "badlyromanticarrow") && (my_familiar() == $familiar[Obtuse Angel]))
	{
		if($monsters[Witchess Bishop, Witchess Knight] contains enemy)
		{
			set_property("sl_combatHandler", combatState + "(badlyromanticarrow)");
			if((get_property("_badlyRomanticArrows").to_int() == 1) && (get_property("romanticTarget") != enemy))
			{
				abort("Have angel out but can not arrow");
			}
			return "skill " + $skill[Fire a Badly Romantic Arrow];
		}
	}

	boolean danger = false;
	if((my_location() == $location[The X-32-F Combat Training Snowman]) && contains_text(text, "Cattle Prod"))
	{
		danger = true;
	}
	if((my_location() == $location[The Secret Government Laboratory]) && get_property("controlPanel9").to_boolean())
	{
		if(!contains_text(combatState, "weaksauce") && have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 32))
		{
			set_property("sl_combatHandler", combatState + "(weaksauce)");
			return "skill " + $skill[Curse Of Weaksauce];
		}

		if((!contains_text(combatState, "conspiratorialwhispers")) && (have_skill($skill[Conspiratorial Whispers])) && (my_mp() >= 49))
		{
			set_property("sl_combatHandler", combatState + "(conspiratorialwhispers)");
			return "skill " + $skill[Conspiratorial Whispers];
		}
		danger = true;
	}

	if(!contains_text(combatState, "love stinkbug") && get_property("lovebugsUnlocked").to_boolean() && !danger)
	{
		set_property("sl_combatHandler", combatState + "(love stinkbug)");
		return "skill " + $skill[Summon Love Stinkbug];
	}

	if(!contains_text(combatState, "(digitize)") && have_skill($skill[Digitize]) && (my_mp() > (mp_cost($skill[Digitize]) * 2)) && ($monsters[Witchess Bishop, Witchess Knight] contains enemy))
	{
		set_property("sl_combatHandler", combatState + "(digitize)");
		return "skill " + $skill[Digitize];
	}

	if(!contains_text(combatState, "(extract)") && have_skill($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 3)) && !danger)
	{
		set_property("sl_combatHandler", combatState + "(extract)");
		return "skill " + $skill[Extract];
	}

	if((!contains_text(combatState, "shattering punch")) && have_skill($skill[Shattering Punch]) && ((my_mp() / 2) > mp_cost($skill[Shattering Punch])) && !isFreeMonster(enemy) && !enemy.boss && (get_property("_shatteringPunchUsed").to_int() < 3))
	{
		set_property("sl_combatHandler", combatState + "(shattering punch)");
		handleTracker(enemy, $skill[shattering punch], "sl_instakill");
		return "skill " + $skill[shattering punch];
	}

	if(!contains_text(combatState, "gingerbread mob hit") && have_skill($skill[Gingerbread Mob Hit]) && ((my_mp() / 2) > mp_cost($skill[Gingerbread Mob Hit])) && !isFreeMonster(enemy) && !enemy.boss && !get_property("_gingerbreadMobHitUsed").to_boolean())
	{
		set_property("sl_combatHandler", combatState + "(gingerbread mob hit)");
		handleTracker(enemy, $skill[Gingerbread Mob Hit], "sl_instakill");
		return "skill " + $skill[Gingerbread Mob Hit];
	}

	if(!contains_text(combatState, "weaksauce") && have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 32))
	{
		set_property("sl_combatHandler", combatState + "(weaksauce)");
		return "skill " + $skill[Curse Of Weaksauce];
	}

	if(!contains_text(combatState, "(candyblast)") && have_skill($skill[Candyblast]) && (my_mp() > (mp_cost($skill[Candyblast]) * 3)) && !danger && (my_class() != $class[Sauceror]))
	{
		set_property("sl_combatHandler", combatState + "(candyblast)");
		return "skill " + $skill[Candyblast];
	}

	if(!contains_text(combatState, "love mosquito") && get_property("lovebugsUnlocked").to_boolean())
	{
		set_property("sl_combatHandler", combatState + "(love mosquito)");
		return "skill " + $skill[Summon Love Mosquito];
	}

	if(!contains_text(combatState, "cowboy kick") && have_skill($skill[Cowboy Kick]) && (monster_level_adjustment() <= 150))
	{
		set_property("sl_combatHandler", combatState + "(cowboy kick)");
		return "skill " + $skill[Cowboy Kick];
	}

	if(!contains_text(combatState, "(time-spinner)") && (item_amount($item[Time-Spinner]) > 0))
	{
		set_property("sl_combatHandler", combatState + "(time-spinner)");
		return "item " + $item[Time-Spinner];
	}

	if(have_skill($skill[Saucegeyser]) && (my_mp() >= mp_cost($skill[Saucegeyser])) && (my_class() == $class[Sauceror]))
	{
		return "skill " + $skill[Saucegeyser];
	}

	if(!contains_text(combatState, "entangling noodles") && have_skill($skill[Entangling Noodles]) && (my_mp() >= (mp_cost($skill[Entangling Noodles]) + (2 * mp_cost($skill[Saucestorm])))) && (monster_level_adjustment() <= 150))
	{
		set_property("sl_combatHandler", combatState + "(entangling noodles)");
		return "skill " + $skill[Entangling Noodles];
	}

	if(have_skill($skill[Saucestorm]) && (my_mp() >= mp_cost($skill[Saucestorm])))
	{
		return "skill " + $skill[Saucestorm];
	}

	if(have_skill($skill[Salsaball]) && (my_mp() >= mp_cost($skill[Salsaball])))
	{
		return "skill " + $skill[salsaball];
	}
	return "attack with weapon";
}

string cs_combatXO(int round, string opp, string text)
{
	# This assumes we have Volcano Charter, Meteor Love [sic], Snokebomb, XO Skeleton (not blocked by 100% run), and 50 MP, anything else and it probably fails
	if(round == 0)
	{
		print("sl_combatHandler: " + round, "brown");
		set_property("sl_combatHandler", "");
	}

	set_property("sl_diag_round", round);
	if(get_property("sl_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	if(my_familiar() != $familiar[XO Skeleton])
	{
		abort("In cs_combatXO without an XO to XOXO with");
	}

	monster enemy = to_monster(opp);
	string combatState = get_property("sl_combatHandler");


	if(my_location() == $location[LavaCo&trade; Lamp Factory])
	{
		if(!possessEquipment($item[Heat-Resistant Necktie]) || !possessEquipment($item[Heat-Resistant Gloves]) || !possessEquipment($item[Lava-Proof Pants]))
		{
			if(!contains_text(combatState, "hugpocket") && (get_property("_xoHugsUsed").to_int() < 11))
			{
				set_property("sl_combatHandler", combatState + "(hugpocket)");
				return "skill " + $skill[Hugs And Kisses!];
			}
			if(contains_text(combatState, "hugpocket") && (get_property("_macrometeoriteUses").to_int() < 10))
			{
				set_property("sl_combatHandler", "");
				return "skill " + $skill[Macrometeorite];
			}
		}
	}

	if(my_location() == $location[The Velvet / Gold Mine])
	{
		if((!possessEquipment($item[Fireproof Megaphone]) && !possessEquipment($item[Meteorite Guard])) || !possessEquipment($item[High-Temperature Mining Mask]))
		{
			if(!contains_text(combatState, "hugpocket") && (get_property("_xoHugsUsed").to_int() < 11))
			{
				set_property("sl_combatHandler", combatState + "(hugpocket)");
				return "skill " + $skill[Hugs And Kisses!];
			}
			if(contains_text(combatState, "hugpocket") && (get_property("_macrometeoriteUses").to_int() < 10))
			{
				set_property("sl_combatHandler", "");
				return "skill " + $skill[Macrometeorite];
			}
		}
	}

	if(!have_skill($skill[Snokebomb]) || (my_mp() < mp_cost($skill[Snokebomb])) || (get_property("_snokebombUsed").to_int() >= 3))
	{
		abort("Can not snoke that fire thing. We should probably smoke it instead.");
	}

	handleTracker(enemy, $skill[Snokebomb], "sl_banishes");
	return "skill " + $skill[Snokebomb];
}

string cs_combatYR(int round, string opp, string text)
{
	if(round == 0)
	{
		print("sl_combatHandler: " + round, "brown");
		set_property("sl_combatHandler", "");
	}

	set_property("sl_diag_round", round);
	if(get_property("sl_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	monster enemy = to_monster(opp);
	string combatState = get_property("sl_combatHandler");

	phylum current = to_phylum(get_property("dnaSyringe"));
	phylum type = monster_phylum(enemy);

	if(have_skill($skill[Duplicate]) && (enemy == $monster[Sk8 Gnome]))
	{
		foreach action in $skills[Curse of Weaksauce, Conspiratorial Whispers, Summon Love Mosquito, Shell Up, Silent Slam, Summon Love Stinkbug, Extract, Duplicate]
		{
			if((!contains_text(combatState, "(" + action + ")")) && have_skill(action) && (my_mp() > mp_cost(action)))
			{
				set_property("sl_combatHandler", combatState + "(" + action + ")");
				return "skill " + action;
			}
		}
	}

	if((!contains_text(combatState, "summon love gnats")) && have_skill($skill[Summon Love Gnats]))
	{
		set_property("sl_combatHandler", combatState + "(summon love gnats)");
		return "skill summon love gnats";
	}
	if((!contains_text(combatState, "DNA")) && (item_amount($item[DNA Extraction Syringe]) > 0))
	{
		if(type != current)
		{
			set_property("sl_combatHandler", combatState + "(DNA)");
			return "item DNA extraction syringe";
		}
	}

	if((my_location() == $location[LavaCo&trade; Lamp Factory]) && have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10))
	{
		if($monsters[Lava Golem] contains enemy)
		{
			return "skill " + $skill[Macrometeorite];
		}
	}

	if((my_location() == $location[The Velvet / Gold Mine]) && have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10))
	{
		if($monsters[Healing Crystal Golem] contains enemy)
		{
			return "skill " + $skill[Macrometeorite];
		}
		if(possessEquipment($item[High-Temperature Mining Mask]))
		{
			if($monsters[Mine Worker (female), Mine Worker (male)] contains enemy)
			{
				return "skill " + $skill[Macrometeorite];
			}
		}
		else
		{
			if($monsters[Mine Overseer (female), Mine Overseer (male)] contains enemy)
			{
				return "skill " + $skill[Macrometeorite];
			}
		}
	}

	if(have_skill($skill[Disintegrate]) && (my_mp() < 150) && (have_effect($effect[Everything Looks Yellow]) == 0))
	{
		if(!contains_text(combatState, "lattegulp") && !get_property("_latteDrinkUsed").to_boolean() && have_skill($skill[Gulp Latte]) && (my_mp() > mp_cost($skill[Gulp Latte])))
		{
			set_property("sl_combatHandler", combatState + "(lattegulp)");
			return "skill " + $skill[Gulp Latte];
		}
		if(!contains_text(combatState, "turbo") && have_skill($skill[Turbo]) && (my_mp() > mp_cost($skill[Turbo])))
		{
			set_property("sl_combatHandler", combatState + "(turbo)");
			return "skill " + $skill[Turbo];
		}
	}

	boolean [monster] lookFor = $monsters[Dairy Goat, Factory Overseer (female), Factory Overseer (male), Factory Worker (female), Factory Worker (male), Mine Overseer (male), Mine Overseer (female), Mine Worker (male), Mine Worker (female), sk8 Gnome];
	if((have_effect($effect[Everything Looks Yellow]) == 0) && (lookFor contains enemy))
	{
		if(!contains_text(combatState, "yellowray"))
		{
			if(have_skill($skill[Disintegrate]) && (my_mp() > mp_cost($skill[Disintegrate])) && (have_effect($effect[Everything Looks Yellow]) == 0))
			{
				set_property("sl_combatHandler", combatState + "(yellowray)");
				handleTracker(enemy, $skill[Disintegrate], "sl_yellowRays");
				return "skill " + $skill[Disintegrate];
			}
			string combatAction = yellowRayCombatString();
			if(combatAction != "")
			{
				set_property("sl_combatHandler", combatState + "(yellowray)");
				if(index_of(combatAction, "skill") == 0)
				{
					handleTracker(enemy, to_skill(substring(combatAction, 6)), "sl_yellowRays");
				}
				else if(index_of(combatAction, "item") == 0)
				{
					handleTracker(enemy, to_item(substring(combatAction, 5)), "sl_yellowRays");
				}
				else
				{
					print("Unable to track yellow ray behavior: " + combatAction, "red");
				}
				return combatAction;
			}
			else
			{
				abort("Wanted a yellow ray but we can not find one.");
			}
		}
	}

	if((!contains_text(combatState, "summon love stinkbug")) && get_property("lovebugsUnlocked").to_boolean())
	{
		set_property("sl_combatHandler", combatState + "(summon love stinkbug)");
		return "skill summon love stinkbug";
	}
	if((!contains_text(combatState, "(extract)")) && have_skill($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 3)))
	{
		set_property("sl_combatHandler", combatState + "(extract)");
		return "skill " + $skill[Extract];
	}
	if((!contains_text(combatState, "(time-spinner)")) && (item_amount($item[Time-Spinner]) > 0))
	{
		set_property("sl_combatHandler", combatState + "(time-spinner)");
		return "item " + $item[Time-Spinner];
	}
	if((!contains_text(combatState, "summon love mosquito")) && get_property("lovebugsUnlocked").to_boolean())
	{
		set_property("sl_combatHandler", combatState + "(summon love mosquito)");
		return "skill summon love mosquito";
	}
	if(have_skill($skill[Salsaball]) && (my_mp() >= mp_cost($skill[Salsaball])))
	{
		return "skill " + $skill[Salsaball];
	}
	return "attack with weapon";
}

string cs_combatKing(int round, string opp, string text)
{
	if(round == 0)
	{
		print("sl_combatHandler: " + round, "brown");
		set_property("sl_combatHandler", "");
	}

	set_property("sl_diag_round", round);
	if(get_property("sl_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	monster enemy = to_monster(opp);
	string combatState = get_property("sl_combatHandler");

	if(enemy != $monster[Witchess King])
	{
		abort("Wrong combat script called");
	}

	foreach action in $skills[Curse of Weaksauce, Conspiratorial Whispers, Tattle, Micrometeorite, Summon Love Mosquito, Shell Up, Silent Slam, Sauceshell, Summon Love Stinkbug, Extract, Turbo, Meteor Shower]
	{
		if((!contains_text(combatState, "(" + action + ")")) && have_skill(action) && (my_mp() > mp_cost(action)))
		{
			set_property("sl_combatHandler", combatState + "(" + action + ")");
			return "skill " + action;
		}
	}

	return "action with weapon";
}

string cs_combatWitch(int round, string opp, string text)
{
	if(round == 0)
	{
		print("sl_combatHandler: " + round, "brown");
		set_property("sl_combatHandler", "");
	}

	set_property("sl_diag_round", round);
	if(get_property("sl_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	monster enemy = to_monster(opp);
	string combatState = get_property("sl_combatHandler");

	if(enemy != $monster[Witchess Witch])
	{
		abort("Wrong combat script called");
	}
	foreach action in $skills[Curse of Weaksauce, Conspiratorial Whispers, Compress, Micrometeorite, Summon Love Mosquito, Summon Love Stinkbug, Meteor Shower]
	{
		if((!contains_text(combatState, "(" + action + ")")) && have_skill(action) && (my_mp() > mp_cost(action)))
		{
			set_property("sl_combatHandler", combatState + "(" + action + ")");
			return "skill " + action;
		}
	}

	foreach action in $skills[Lunging Thrust-Smack, Thrust-Smack, Lunge Smack]
	{
		if(have_skill(action) && (my_mp() > mp_cost(action)))
		{
			return "skill " + action;
		}
	}

	return "action with weapon";
}

string cs_combatLTB(int round, string opp, string text)
{
	if(round == 0)
	{
		print("sl_combatHandler: " + round, "brown");
		set_property("sl_combatHandler", "");
	}

	set_property("sl_diag_round", round);
	if(get_property("sl_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	monster enemy = to_monster(opp);
	string combatState = get_property("sl_combatHandler");

#	if(!contains_text(combatState, "love gnats") && have_skill($skill[Summon Love Gnats]))
#	{
#		set_property("sl_combatHandler", combatState + "(love gnats)");
#		return "skill " + $skill[Summon Love Gnats];
#	}
	if(!contains_text(combatState, "giant growth") && have_skill($skill[Giant Growth]))
	{
		if(item_amount($item[Green Mana]) == 0)
		{
			abort("We do not have a Green Mana, we should not have gotten here!");
		}
		set_property("sl_combatHandler", combatState + "(giant growth)");
		return "skill " + $skill[Giant Growth];
	}

	if(!contains_text(combatState, "giant growth"))
	{
		print("In cs_combatLTB handler, should have used giant growth but didn't!! WTF!! (" + have_skill($skill[Giant Growth]) + ")", "red");
	}


	if(isFreeMonster(enemy))
	{
		return cs_combatNormal(round, opp, text);
	}

	if(!contains_text(combatState, "shattering punch") && have_skill($skill[Shattering Punch]) && (my_mp() >= mp_cost($skill[Shattering Punch])) && !isFreeMonster(enemy) && !enemy.boss && (get_property("_shatteringPunchUsed").to_int() < 3))
	{
		set_property("sl_combatHandler", combatState + "(shattering punch)");
		handleTracker(enemy, $skill[shattering punch], "sl_instakill");
		return "skill " + $skill[shattering punch];
	}

	if(!contains_text(combatState, "louder than bomb") && (item_amount($item[Louder Than Bomb]) > 0))
	{
		set_property("sl_combatHandler", combatState + "(louder than bomb)");

		if((item_amount($item[Seal Tooth]) > 0) && have_skill($skill[Ambidextrous Funkslinging]))
		{
			return "item louder than bomb, seal tooth";
		}
		return "item " + $item[Louder Than Bomb];
	}
	if(!contains_text(combatState, "tennis ball") && (item_amount($item[Tennis Ball]) > 0))
	{
		set_property("sl_combatHandler", combatState + "(tennis ball)");

		if((item_amount($item[Seal Tooth]) > 0) && have_skill($skill[Ambidextrous Funkslinging]))
		{
			return "item tennis ball, seal tooth";
		}
		return "item " + $item[Tennis Ball];
	}


	if(!contains_text(combatState, "power pill") && (item_amount($item[Power Pill]) > 0))
	{
		set_property("sl_combatHandler", combatState + "(power pill)");

		if((item_amount($item[Seal Tooth]) > 0) && have_skill($skill[Ambidextrous Funkslinging]))
		{
			return "item power pill, seal tooth";
		}
		return "item " + $item[Power Pill];
	}

	abort("Could not free kill our Giant Growth, uh oh.");
	return "fail";
}

boolean cs_giant_growth()
{
	if(have_effect($effect[Giant Growth]) > 0)
	{
		return true;
	}
	if(item_amount($item[Green Mana]) == 0)
	{
		return false;
	}
	if(!have_skill($skill[Giant Growth]))
	{
		return false;
	}

	if((isOverdueDigitize() || isOverdueArrow()) && elementalPlanes_access($element[stench]))
	{
		print("A Wanderer event is expected now and we want giant growth, diverting.... (Status: cs_giant_growth handler)", "blue");
		slAdv(1, $location[Barf Mountain], "cs_combatLTB");
		if(have_effect($effect[Giant Growth]) > 0)
		{
			return true;
		}
		return cs_giant_growth();
	}

	boolean fail = true;

	if(item_amount($item[Louder Than Bomb]) > 0)
	{
		fail = false;
	}
	if(item_amount($item[Power Pill]) > 0)
	{
		fail = false;
	}
	if(item_amount($item[Tennis Ball]) > 0)
	{
		fail = false;
	}
	if(have_skill($skill[Shattering Punch]))
	{
		fail = false;
	}
	if(have_familiar($familiar[Machine Elf]) && !is100FamiliarRun())
	{
		use_familiar($familiar[Machine Elf]);
		fail = false;
	}
	if(fail)
	{
		return false;
	}

#	print("Starting LTBs: " + item_amount($item[Louder Than Bomb]), "blue");

	if(my_familiar() == $familiar[Machine Elf])
	{
		backupSetting("choiceAdventure1119", 1);
		handleFamiliar($familiar[Machine Elf]);
		slAdv(1, $location[The Deep Machine Tunnels], "cs_combatLTB");
		restoreSetting("choiceAdventure1119");
		set_property("choiceAdventure1119", "");
	}
	else if(!godLobsterCombat($item[none], 3, "cs_combatLTB"))
	{
#		slAdv(1, $location[8-bit Realm], "cs_combatLTB");
		slAdv(1, $location[The Thinknerd Warehouse], "cs_combatLTB");
	}
#	print("Ending LTBs: " + item_amount($item[Louder Than Bomb]), "blue");
#	cli_execute("refresh inv");
#	print("Corrected LTBs: " + item_amount($item[Louder Than Bomb]), "blue");

	if(have_effect($effect[Giant Growth]) > 0)
	{
		return true;
	}
	abort("We should have Giant Growth active, but we do not :(");
	return cs_giant_growth();
}

boolean sl_csHandleGrapes()
{
	if(item_amount($item[Potion of Temporary Gr8ness]) > 0)
	{
		return false;
	}
	if(canYellowRay() && !get_property("_photocopyUsed").to_boolean() && ($classes[Pastamancer, Sauceror] contains my_class()))
	{
		if(yellowRayCombatString() == ("skill " + $skill[Open a Big Yellow Present]))
		{
			handleFamiliar("yellowray");
		}
		useCocoon();
		handleFaxMonster($monster[Sk8 gnome], "cs_combatYR");
	}
	if((item_amount($item[Gr8ps]) > 0) && (item_amount($item[Potion of Temporary Gr8ness]) == 0) && (have_effect($effect[Gr8tness]) == 0) && (npc_price($item[Delectable Catalyst]) < my_meat()) && (freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && have_skill($skill[Advanced Saucecrafting]) && ($classes[Pastamancer, Sauceror] contains my_class()) && have_skill($skill[The Way of Sauce]) && (sl_get_campground() contains $item[Dramatic&trade; Range]))
	{
		if(!have_skills($skills[Expert Corner-Cutter, Rapid Prototyping]) && have_skill($skill[Inigo\'s Incantation of Inspiration]))
		{
			shrugAT($effect[Inigo\'s Incantation of Inspiration]);
			buffMaintain($effect[Inigo\'s Incantation of Inspiration], 100, 1, 5);
		}
		cli_execute("make " + $item[Potion of Temporary Gr8ness]);
	}
	return (item_amount($item[Potion of Temporary Gr8ness]) > 0);
}

int estimate_cs_questCost(int quest)
{
	int retval = 60;
	switch(quest)
	{
	case 1:		retval = 60 - ((my_maxhp() - (my_buffedstat($stat[Muscle]) + 3)) / 30);	break;
	case 2:		retval = 60 - ((my_buffedstat($stat[Muscle]) - my_basestat($stat[Muscle])) / 30);	break;
	case 3:		retval = 60 - ((my_buffedstat($stat[Mysticality]) - my_basestat($stat[Mysticality])) / 30);	break;
	case 4:		retval = 60 - ((my_buffedstat($stat[Moxie]) - my_basestat($stat[Moxie])) / 30);	break;
	case 5:		retval = 60 - ((weight_adjustment() + familiar_weight(my_familiar())) / 5);	break;
	case 6:
		if(have_effect($effect[Bow-Legged Swagger]) > 0)
		{
			retval = 60 - (floor(numeric_modifier("weapon damage") / 25.0) + floor(numeric_modifier("weapon damage percent") / 25.0));
		}
		else
		{
			retval = 60 - (floor(numeric_modifier("weapon damage") / 50) + floor(numeric_modifier("weapon damage percent") / 50));
		}
		break;
	case 7:		retval = 60 - (floor(numeric_modifier("spell damage") / 50) + floor(numeric_modifier("spell damage percent") / 50));	break;
	case 8:		retval = 60 - (3 * min(5,floor((-1.0 * combat_rate_modifier()) / 5))) - (3 * max(0,floor((-1.0 * combat_rate_modifier()) - 25)));	break;
	case 9:		retval = 60 - (floor(numeric_modifier("item drop") / 30) + floor(numeric_modifier("booze drop") / 15));	break;
	case 10:	retval = 60 - elemental_resist($element[hot]);	break;
	case 11:	retval = 60;	break;
	}
	return max(retval, 1);
}

int [int] get_cs_questList()
{
	int [int] questList;
	if(my_path() != "Community Service")
	{
		return questList;
	}

	string page = visit_url("council.php");
	matcher quest_matcher = create_matcher("whichchoice value=1089><input type=hidden name=option value=(\\d+)(?:.*?)Perform Service [(](\\d+) Advent", page);

	while(quest_matcher.find())
	{
		int found = to_int(quest_matcher.group(1));
		int adv = to_int(quest_matcher.group(2));
		questList[found] = adv;

		if(adv != estimate_cs_questCost(found))
		{
			print("Incorrectly predicted quest " + found + " as " + estimate_cs_questCost(found) + ". Was: " + adv, "red");
		}
	}

	set_cs_questListFast(questList);
	return questList;
}

int expected_next_cs_quest()
{
	if(my_path() != "Community Service")
	{
		return 0;
	}

	int retval = expected_next_cs_quest_internal();
	if(retval > 0)
	{
		switch(retval)
		{
		case 1:		print("Community Service Quest  1: HP", "blue");								break;
		case 2:		print("Community Service Quest  2: Muscle", "blue");							break;
		case 3:		print("Community Service Quest  3: Mysticality", "blue");						break;
		case 4:		print("Community Service Quest  4: Moxie", "blue");								break;
		case 5:		print("Community Service Quest  5: Familiar Weight", "blue");					break;
		case 6:		print("Community Service Quest  6: Melee Damage", "blue");						break;
		case 7:		print("Community Service Quest  7: Spell Damage", "blue");						break;
		case 8:		print("Community Service Quest  8: Monsters Less Attracted to You", "blue");	break;
		case 9:		print("Community Service Quest  9: Item/Booze Drops", "blue");					break;
		case 10:	print("Community Service Quest 10: Hot Protection", "blue");					break;
		case 11:	print("Community Service Quest 11: Coiling Wire", "blue");						break;
		}
	}
	return retval;
}

string what_cs_quest(int quest)
{
	switch(quest)
	{
	case 1:		return "Community Service Quest 1: HP";
	case 2:		return "Community Service Quest 2: Muscle";
	case 3:		return "Community Service Quest 3: Mysticality";
	case 4:		return "Community Service Quest 4: Moxie";
	case 5:		return "Community Service Quest 5: Familiar Weight";
	case 6:		return "Community Service Quest 6: Melee Damage";
	case 7:		return "Community Service Quest 7: Spell Damage";
	case 8:		return "Community Service Quest 8: Monsters Less Attracted to You";
	case 9:		return "Community Service Quest 9: Item/Booze Drops";
	case 10:	return "Community Service Quest 10: Hot Protection";
	case 11:	return "Community Service Quest 11: Coiling Wire";
	default:	return "Community Service Quest 0: NULL";
	}
}

int expected_next_cs_quest_internal()
{
	if(my_path() != "Community Service")
	{
		return 0;
	}

	int [int] questList = get_cs_questList();
	boolean [int] questOrder = $ints[11, 6, 9, 7, 10, 1, 2, 3, 4, 5, 8];
	if((my_daycount() == 2) && (have_effect($effect[Margamergency]) == 0))
	{
		questOrder = $ints[11, 6, 9, 1, 2, 3, 4, 7, 10, 5, 8];
	}
	foreach quest in questOrder
	{
		if(questList contains quest)
		{
			return quest;
		}
	}
	return 0;
}

boolean do_cs_quest(int quest)
{
	if(my_path() != "Community Service")
	{
		return false;
	}

	switch(quest)
	{
	case 1:		slMaximize("hp, -equip snow suit", 1500, 0, false);					break;
	case 2:		slMaximize("muscle, -equip snow suit", 1500, 0, false);				break;
	case 3:		slMaximize("myst, -equip snow suit", 1500, 0, false);				break;
	case 4:		slMaximize("moxie, -equip snow suit", 1500, 0, false);				break;
	case 5:		slMaximize("familiar weight, -equip snow suit", 1500, 0, false);	break;
	case 6:		slMaximize("weapon damage, -equip snow suit", 1500, 0, false);		break;
	case 7:		slMaximize("spell damage, -equip snow suit", 1500, 0, false);		break;
	case 8:		slMaximize("-combat, -equip snow suit", 1500, 0, false);			break;
	case 9:		slMaximize("item, -equip snow suit, -equip broken champagne bottle", 1500, 0, false);				break;
	case 10:	slMaximize("hot res, -equip snow suit", 1500, 0, false);			break;
	}

	int [int] questList = get_cs_questList();
	int advs = my_adventures();
	if((advs < questList[quest]) && ((advs + 3) >= questList[quest]) && (item_amount($item[LOV Extraterrestrial Chocolate]) > 0))
	{
		use(1, $item[LOV Extraterrestrial Chocolate]);
		advs += 3;
	}
	if(((questList contains quest) && (advs >= questList[quest])) || (quest == 30))
	{
		string temp = visit_url("council.php");
		if(quest != 30)
		{
			temp = run_choice(quest);
			print(what_cs_quest(quest) + " completed for " + questList[quest] + " adventures.", "blue");
		}
		else
		{
			if(get_property("sl_stayInRun").to_boolean())
			{
				abort("User wanted to stay in run (sl_stayInRun), we are done.");
			}
			visit_url("choice.php?pwd&whichchoice=1089&option=30");
			print("Community Service Completed. Beep boop.", "blue");
		}
		return true;
	}
	else
	{
		return false;
	}
}

boolean do_cs_quest(string quest)
{
	return do_cs_quest(get_cs_questNum(quest));
}

int get_cs_questCost(int quest)
{
	if((quest < 0) || (quest > 11))
	{
		abort("Invalid quest value specified");
	}
	if(my_path() != "Community Service")
	{
		return -1;
	}

	int [int] questsLeft = get_cs_questList();
	return questsLeft[quest];
}

int get_cs_questCost(string input)
{
	return get_cs_questCost(get_cs_questNum(input));
}

int get_cs_questNum(string input)
{
	if(my_path() != "Community Service")
	{
		return -1;
	}
	input = to_lower_case(input);
	if(input == "hp")
	{
		return 1;
	}
	if((input == "mus") || (input == "muscle") || (input == "musc"))
	{
		return 2;
	}
	if((input == "myst") || (input == "mysticality"))
	{
		return 3;
	}
	if((input == "mox") || (input == "moxie"))
	{
		return 4;
	}
	if((input == "familiar weight") || (input == "familiar") || (input == "weight") || (input == "fam") || (input == "fam weight"))
	{
		return 5;
	}
	if((input == "weapon damage") || (input == "weapon") || (input == "damage") || (input == "weapon dmg") || (input == "wpn") || (input == "wpn dmg"))
	{
		return 6;
	}
	if((input == "spell damage") || (input == "spell"))
	{
		return 7;
	}
	if((input == "nc") || (input == "non-combat") || (input == "non combat") || (input == "combat"))
	{
		return 8;
	}
	if((input == "item") || (input == "item drop") || (input == "drop"))
	{
		return 9;
	}
	if((input == "hot resistance") || (input == "hot res") || (input == "resistance") || (input == "hot"))
	{
		return 10;
	}
	if((input == "coil") || (input == "wire") || (input == "crap"))
	{
		return 11;
	}
	abort("Incorrect Community Service Quest Specified: " + input);
	return -1;
}

void set_cs_questListFast(int[int] fast)
{
	int[int] empty;
	sl_cs_fastQuestList = empty;
	foreach idx, val in fast
	{
		sl_cs_fastQuestList[val] = val;
	}
}

boolean cs_preTurnStuff(int curQuest)
{
	if(my_path() != "Community Service")
	{
		return false;
	}

	int[int] questsLeft = sl_cs_fastQuestList;

	if(my_inebriety() > inebriety_limit())
	{
		abort("Too drunk, not sure if not aborting is safe yet");
	}

	if((sl_get_campground() contains $item[Packet Of Tall Grass Seeds]))
	{
		int[item] camp = sl_get_campground();
		if(camp[$item[Packet Of Tall Grass Seeds]] > 0)
		{
			cli_execute("garden pick");
		}
	}

	if(is_unrestricted($item[Bastille Battalion Control Rig]) && (storage_amount($item[Bastille Battalion Control Rig]) > 0))
	{
		string temp = visit_url("storage.php?action=pull&whichitem1=" + to_int($item[Bastille Battalion Control Rig]) + "&howmany1=1&pwd");
	}

	if((item_amount($item[Mumming Trunk]) > 0) && !get_property("_mummifyDone").to_boolean())
	{
		switch(my_daycount())
		{
		case 1:
			mummifyFamiliar($familiar[Ms. Puck Man], "myst");
			mummifyFamiliar($familiar[Puck Man], "myst");
			mummifyFamiliar($familiar[Rockin\' Robin], "mpregen");
			mummifyFamiliar($familiar[Machine Elf], "item");
			mummifyFamiliar($familiar[Galloping Grill], "muscle");
			mummifyFamiliar($familiar[Reanimated Reanimator], "hpregen");
			mummifyFamiliar($familiar[Bloovian Groose], "moxie");
			mummifyFamiliar($familiar[Intergnat], "moxie");
			mummifyFamiliar($familiar[Golden Monkey], "meat");
			set_property("_mummifyDone", true);
			break;
		case 2:
			mummifyFamiliar($familiar[Ms. Puck Man], "myst");
			mummifyFamiliar($familiar[Puck Man], "myst");
			mummifyFamiliar($familiar[Rockin\' Robin], "mpregen");
			mummifyFamiliar($familiar[Machine Elf], "item");
			mummifyFamiliar($familiar[Galloping Grill], "muscle");
			mummifyFamiliar($familiar[Reanimated Reanimator], "hpregen");
			mummifyFamiliar($familiar[Bloovian Groose], "moxie");
			mummifyFamiliar($familiar[Intergnat], "moxie");
			mummifyFamiliar($familiar[Hobo Monkey], "meat");
			set_property("_mummifyDone", true);
			break;
		}
	}

	if(possessEquipment($item[Latte Lovers Member\'s Mug]))
	{
		if(get_property("_latteRefillsUsed").to_int() == 0)
		{
			string opt1 = "S5ENw2oLpIrV44T64s7HS5GWxbdWfEajGLH6d5fPSyfFosMI94DC95VSyT3qR8kAeGhHMHZXV3Zobll3ZXF4WjZsdmxpQT09";
			string opt2 = "GasfMOkRT1QCrz1G7H9+lq6VcmDt65ZFLGVetRLQqa4vvoHHsWsa15LiGylFwCssT2oyYWJUL3E5Tmc5VmRvWWhqajdVQT09";
			string opt3 = "MUnOlP/vCrCbI5Kxs7WHG8aGvILUb0IFgi9p/vZOuAhivrjV6NL3ad97awbNvTU9MmNqZzFmR2RUbXg2TC9XYXRuNldjUT09";

			string page = visit_url("main.php?latte=1", false);
			string url = "choice.php?pwd=&whichchoice=1329&option=1&l1=" + opt1 + "&l2=" + opt2 + "&l3=" + opt3;
			page = visit_url(url);
		}
	}

	if(item_amount($item[Portable Pantogram]) > 0)
	{
		switch(my_daycount())
		{
		case 1:
			pantogramPants(my_primestat(), $element[hot], 1, 1, 1);
			break;
		case 2:
		case 3:
			pantogramPants($stat[Muscle], $element[hot], 1, 2, 1);
			break;
		}
	}

	if((januaryToteTurnsLeft($item[Makeshift Garbage Shirt]) > 0) && ((my_daycount() >= 2) || (curQuest == 9)))
	{
		januaryToteAcquire($item[Makeshift Garbage Shirt]);
	}
	else
	{
		januaryToteAcquire($item[Wad Of Used Tape]);
	}

	if(is100FamiliarRun())
	{
		if((my_familiar() != $familiar[Puck Man]) && (my_familiar() != $familiar[Ms. Puck Man]))
		{
			print("100% familiar is dangerous, to disable: set sl_100familiar=none", "red");
			string thing = "meatbag";
			if(my_name() == "Cheesecookie")
			{
				thing = "my robotic overlord";
			}
			print("I'm going to keep going anyway because, whatevs, your problem " + thing + ".", "red");
		}
		else
		{
			print("In 100% familiar mode with a Puck Person... well, good luck!", "red");
		}
	}

	if(get_property("_g9Effect").to_int() == 0)
	{
		string temp = visit_url("desc_item.php?whichitem=661049168", false);
	}

	cs_dnaPotions();
	use_barrels();
	cs_make_stuff(curQuest);
	sl_mayoItems();
	sl_voteSetup(0, 1, 3);

	if((item_amount($item[Gold Nuggets]) > 0) && (item_amount($item[Gold Nuggets]) <= 3))
	{
		autosell(item_amount($item[Gold Nuggets]), $item[Gold Nuggets]);
	}
	autosellCrap();

	if(item_amount($item[Metal Meteoroid]) > 0)
	{
		record meteor_item
		{
			item it;
			boolean want;
		};
		meteor_item[int] meteors;
		meteors[0].it = $item[Meteorthopedic Shoes];
		meteors[0].want = false;
		meteors[1].it = $item[Meteorite Guard];
		meteors[1].want = false;
		meteors[2].it = $item[Shooting Morning Star];
		meteors[2].want = false;
		meteors[3].it = $item[Meteortarboard];
		meteors[3].want = false;

		boolean haveHotRes = false;
		if(contains_text(get_property("latteUnlocks"), "chili"))
		{
			haveHotRes = true;
		}
		if(possessEquipment(meteors[1].it))
		{
			haveHotRes = true;
		}
		if(possessEquipment($item[Glass Pie Plate]))
		{
			haveHotRes = true;
		}

		boolean haveMuscle = false;
		if(possessEquipment($item[Dented Scepter]))
		{
			haveMuscle = true;
		}

		if(((curQuest == 7) || (curQuest == 4)) && !possessEquipment(meteors[0].it))
		{
			meteors[0].want = true;
		}
		if((curQuest == 10) && !haveHotRes && !possessEquipment(meteors[1].it))
		{
			meteors[1].want = true;
		}
		if(((questsLeft contains 1) || (questsLeft contains 2)) && (haveHotRes || !(questsLeft contains 10)) && !possessEquipment(meteors[2].it) && !haveMuscle)
		{
			meteors[2].want = true;
		}
		if((questsLeft contains 3) && (haveHotRes || !(questsLeft contains 10)) && !possessEquipment(meteors[3].it))
		{
			meteors[3].want = true;
		}

		foreach idx, meteorIt in meteors
		{
			item it = meteorIt.it;
			if(!possessEquipment(it) && meteorIt.want)
			{
				int choice = 1 + to_int(it) - to_int($item[Meteortarboard]);
				string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=9516");
				temp = visit_url("choice.php?pwd=&whichchoice=1264&option=" + choice);
				break;
			}
		}
	}

	if(item_amount($item[Cashew]) > 0)
	{
		if((item_amount($item[Cashew]) >= 1) && !possessEquipment($item[Glass Casserole Dish]) && ((item_amount($item[January\'s Garbage Tote]) == 0) || (get_property("sl_beatenUpCount").to_int() >= 3)))
		{
			cli_execute("make " + $item[Glass Casserole Dish]);
		}
		if((item_amount($item[Cashew]) >= 2) && !possessEquipment($item[Glass Pie Plate]) && !have_skill($skill[Meteor Lore]) && (questsLeft contains 10))
		{
			cli_execute("make " + $item[Glass Pie Plate]);
		}
	}

	if(isOverdueDigitize())
	{
		print("A Digitize event is expected now.", "blue");
	}
	if(isOverdueArrow())
	{
		print("An Arrow event is expected now.", "blue");
	}


	switch(my_daycount())
	{
	case 1:
		if(get_property("_horseryRented").to_int() == 0)
		{
			getHorse("regen");
		}
	case 2:
		if(get_property("_horseryRented").to_int() == 0)
		{
			getHorse("non-combat");
		}
	default:
		if(get_property("_horseryRented").to_int() == 0)
		{
			getHorse("non-combat");
		}
	}

	if((curQuest == 11) || (curQuest == 6))
	{
		if(item_amount($item[Punching Potion]) == 0)
		{
			songboomSetting("weapon damage");
		}
		else
		{
			songboomSetting("dr");
		}
	}
	else if((curQuest == 9) || (curQuest == 7))
	{
		songboomSetting($item[Special Seasoning]);
	}
	else
	{
		songboomSetting($item[Gathered Meat-Clip]);
	}

	LX_dolphinKingMap();

	return false;
}

