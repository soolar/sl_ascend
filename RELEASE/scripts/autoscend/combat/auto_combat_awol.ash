//Path specific combat handling functions for Avatar of West of Loathing

void awol_helper(string page)
{
	//Let us self-contain this so it is quick to remove later.
	if((my_daycount() == 1) && (my_turncount() < 10))
	{
		set_property("auto_noSnakeOil", 0);
	}

	string combatState = get_property("auto_combatHandler");
	if(contains_text(page, "Your oil extractor is completely clogged up at this point"))
	{
		set_property("auto_noSnakeOil", my_daycount());
	}
	if(get_property("_oilExtracted").to_int() >= 100)
	{
		set_property("auto_noSnakeOil", my_daycount());
	}

	if((!contains_text(combatState, "extractSnakeOil")) && (get_property("auto_noSnakeOil").to_int() == my_daycount()))
	{
		set_property("auto_combatHandler", combatState + "(extractSnakeOil)");
	}
}