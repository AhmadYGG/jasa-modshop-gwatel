

CreatePlayerTextDraws(playerid)
{	
    Compas_Cord[0] = TextDrawCreate(105.000, 373.000, "");
	TextDrawLetterSize(Compas_Cord[0], 0.187, 0.999);
	TextDrawAlignment(Compas_Cord[0], 1);
	TextDrawColor(Compas_Cord[0], 1432642815);
	TextDrawSetShadow(Compas_Cord[0], 0);
	TextDrawSetOutline(Compas_Cord[0], 1);
	TextDrawBackgroundColor(Compas_Cord[0], 150);
	TextDrawFont(Compas_Cord[0], 1);
	TextDrawSetProportional(Compas_Cord[0], 1);

	// Compas
	Compas_Dir[playerid][0] = CreatePlayerTextDraw(playerid, 115.000, 347.000, "");
	PlayerTextDrawLetterSize(playerid, Compas_Dir[playerid][0], 0.388, 1.998);
	PlayerTextDrawAlignment(playerid, Compas_Dir[playerid][0], 2);
	PlayerTextDrawColor(playerid, Compas_Dir[playerid][0], 512819199);
	PlayerTextDrawSetShadow(playerid, Compas_Dir[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, Compas_Dir[playerid][0], 1);
	PlayerTextDrawBackgroundColor(playerid, Compas_Dir[playerid][0], 150);
	PlayerTextDrawFont(playerid, Compas_Dir[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, Compas_Dir[playerid][0], 1);

	Compas_Dir[playerid][1] = CreatePlayerTextDraw(playerid, 105.000, 364.000, "");
	PlayerTextDrawLetterSize(playerid, Compas_Dir[playerid][1], 0.187, 0.999);
	PlayerTextDrawAlignment(playerid, Compas_Dir[playerid][1], 1);
	PlayerTextDrawColor(playerid, Compas_Dir[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, Compas_Dir[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, Compas_Dir[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, Compas_Dir[playerid][1], 150);
	PlayerTextDrawFont(playerid, Compas_Dir[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, Compas_Dir[playerid][1], 1);
	}