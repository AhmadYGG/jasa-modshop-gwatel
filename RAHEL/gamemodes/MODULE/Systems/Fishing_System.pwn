new PlayerText: FishingTD[MAX_PLAYERS][12];
#define MAX_FISH_PROGRESS 109.0
#define FISH_INCREASE     15.0
#define FISH_DECREASE     3.0

new bool:IsFishing[MAX_PLAYERS], 
    Float:FishProgress[MAX_PLAYERS], 
    FishClicks[MAX_PLAYERS], 
    FishTimer[MAX_PLAYERS], 
    bool:PressingY[MAX_PLAYERS],
    STREAMER_TAG_AREA:FishingArea[15];
    
new bool:GlobalFishingLuck = false;
new GlobalLuckMultiplier = 1;
new GlobalLuckTimer;

CreateMancingTD(playerid)
{
    FishingTD[playerid][0] = CreatePlayerTextDraw(playerid, 295.000, 350.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][0], 45.000, 25.000);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, FishingTD[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, FishingTD[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][0], 1);

    FishingTD[playerid][1] = CreatePlayerTextDraw(playerid, 297.000, 338.000, "_");
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][1], 40.000, 50.000);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][1], 1);
    PlayerTextDrawColor(playerid, FishingTD[playerid][1], 255);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][1], 0);
    PlayerTextDrawFont(playerid, FishingTD[playerid][1], 5);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][1], 0);
    PlayerTextDrawSetPreviewModel(playerid, FishingTD[playerid][1], 19630);
    PlayerTextDrawSetPreviewRot(playerid, FishingTD[playerid][1], 0.000, 0.000, 0.000, 1.000);
    PlayerTextDrawSetPreviewVehCol(playerid, FishingTD[playerid][1], 0, 0);

    FishingTD[playerid][2] = CreatePlayerTextDraw(playerid, 319.000, 357.000, "?");
    PlayerTextDrawLetterSize(playerid, FishingTD[playerid][2], 0.260, 1.099);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][2], 2);
    PlayerTextDrawColor(playerid, FishingTD[playerid][2], -1);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][2], 150);
    PlayerTextDrawFont(playerid, FishingTD[playerid][2], 1);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][2], 1);

    FishingTD[playerid][3] = CreatePlayerTextDraw(playerid, 185.000, 351.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][3], 110.000, 1.000);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][3], 1);
    PlayerTextDrawColor(playerid, FishingTD[playerid][3], -1);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][3], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][3], 255);
    PlayerTextDrawFont(playerid, FishingTD[playerid][3], 4);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][3], 1);

    FishingTD[playerid][4] = CreatePlayerTextDraw(playerid, 185.000, 373.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][4], 110.000, 1.000);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][4], 1);
    PlayerTextDrawColor(playerid, FishingTD[playerid][4], -1);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][4], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][4], 255);
    PlayerTextDrawFont(playerid, FishingTD[playerid][4], 4);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][4], 1);

    FishingTD[playerid][5] = CreatePlayerTextDraw(playerid, 340.000, 351.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][5], 110.000, 1.000);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][5], 1);
    PlayerTextDrawColor(playerid, FishingTD[playerid][5], -1);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][5], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][5], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][5], 255);
    PlayerTextDrawFont(playerid, FishingTD[playerid][5], 4);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][5], 1);

    FishingTD[playerid][6] = CreatePlayerTextDraw(playerid, 340.000, 373.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][6], 110.000, 1.000);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][6], 1);
    PlayerTextDrawColor(playerid, FishingTD[playerid][6], -1);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][6], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][6], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][6], 255);
    PlayerTextDrawFont(playerid, FishingTD[playerid][6], 4);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][6], 1);

    FishingTD[playerid][7] = CreatePlayerTextDraw(playerid, 185.000, 373.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][7], 1.000, -21.000);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][7], 1);
    PlayerTextDrawColor(playerid, FishingTD[playerid][7], -1);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][7], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][7], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][7], 255);
    PlayerTextDrawFont(playerid, FishingTD[playerid][7], 4);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][7], 1);

    FishingTD[playerid][8] = CreatePlayerTextDraw(playerid, 449.000, 373.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][8], 1.000, -21.000);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][8], 1);
    PlayerTextDrawColor(playerid, FishingTD[playerid][8], -1);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][8], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][8], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][8], 255);
    PlayerTextDrawFont(playerid, FishingTD[playerid][8], 4);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][8], 1);

    FishingTD[playerid][9] = CreatePlayerTextDraw(playerid, 295.000, 352.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][9], -109.000, 21.000);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][9], 1);
    PlayerTextDrawColor(playerid, FishingTD[playerid][9], 16423679);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][9], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][9], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][9], 255);
    PlayerTextDrawFont(playerid, FishingTD[playerid][9], 4);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][9], 1);

    FishingTD[playerid][10] = CreatePlayerTextDraw(playerid, 340.000, 352.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][10], 109.000, 21.000);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][10], 1);
    PlayerTextDrawColor(playerid, FishingTD[playerid][10], 16423679);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][10], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][10], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][10], 255);
    PlayerTextDrawFont(playerid, FishingTD[playerid][10], 4);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][10], 1);

    FishingTD[playerid][11] = CreatePlayerTextDraw(playerid, 317.000, 335.000, "Y to click fast (000)");
    PlayerTextDrawLetterSize(playerid, FishingTD[playerid][11], 0.190, 1.099);
    PlayerTextDrawAlignment(playerid, FishingTD[playerid][11], 2);
    PlayerTextDrawColor(playerid, FishingTD[playerid][11], -1);
    PlayerTextDrawSetShadow(playerid, FishingTD[playerid][11], 0);
    PlayerTextDrawSetOutline(playerid, FishingTD[playerid][11], 0);
    PlayerTextDrawBackgroundColor(playerid, FishingTD[playerid][11], 150);
    PlayerTextDrawFont(playerid, FishingTD[playerid][11], 1);
    PlayerTextDrawSetProportional(playerid, FishingTD[playerid][11], 1);
}

forward FishingUpdate(playerid);
public FishingUpdate(playerid)
{
    if(!IsFishing[playerid]) return 0;

    if(PressingY[playerid])
    {
        FishProgress[playerid] += FISH_INCREASE;
        PressingY[playerid] = false;
    }
    else
    {
        FishProgress[playerid] -= FISH_DECREASE;
    }

    if(FishProgress[playerid] <= 0.0)
    {
        FailFishing(playerid);
        return 0;
    }

    if(FishProgress[playerid] >= MAX_FISH_PROGRESS)
    {
        FinishFishing(playerid);
        return 0;
    }

    UpdateFishingBar(playerid);
    return 1;
}

UpdateFishingBar(playerid)
{
    new Float:left = -FishProgress[playerid];
    new Float:right = FishProgress[playerid];

    PlayerTextDrawTextSize(playerid, FishingTD[playerid][9], left, 21.0);
    PlayerTextDrawTextSize(playerid, FishingTD[playerid][10], right, 21.0);

    PlayerTextDrawShow(playerid, FishingTD[playerid][9]);
    PlayerTextDrawShow(playerid, FishingTD[playerid][10]);
}

UpdateFishingClicksTD(playerid)
{
    new str[64];
    format(str, sizeof(str), "Y to click fast (%03d)", FishClicks[playerid]);
    PlayerTextDrawSetString(playerid, FishingTD[playerid][11], str);
    PlayerTextDrawShow(playerid, FishingTD[playerid][11]);
}

stock BroadcastFishing(type, playerid)
{
    new name[MAX_PLAYER_NAME], msg[144];
    GetPlayerName(playerid, name, sizeof(name));

    if(type == 1)
    {
        format(msg, sizeof(msg),
            "SERVER: %s mendapatkan MYTHIC SEA TURTLE.",
            name);
        SendClientMessageToAll(COLOR_RED, msg);
    }
    else if(type == 2)
    {
        format(msg, sizeof(msg),
            "SERVER: %s mendapatkan MYTHIC DOLPHIN.",
            name);
        SendClientMessageToAll(COLOR_RED, msg);
    }
    else if(type == 3)
    {
        format(msg, sizeof(msg),
            "SERVER: %s mendapatkan SECRET SHARK.",
            name);
        SendClientMessageToAll(0x00FF66FF, msg);
    }
    else if(type == 4)
    {
        format(msg, sizeof(msg),
            "SERVER: %s mendapatkan SECRET MEGALODON.",
            name);
        SendClientMessageToAll(0x00FF66FF, msg);
    }
    return 1;
}

FinishFishing(playerid)
{
    IsFishing[playerid] = false;
    KillTimer(FishTimer[playerid]);
    ClearAnimations(playerid, 1);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    RemovePlayerAttachedObject(playerid, 9);

    for(new i = 0; i < 12; i++)
        PlayerTextDrawHide(playerid, FishingTD[playerid][i]);

    PlayerInfo[playerid][pCaught]++;
    OnPlayerUpdateAccountsPer(playerid, "pCaught",
        PlayerInfo[playerid][pCaught]);

	new Float:chanceMakarel = 47.0;
	new Float:chanceBlue    = 47.0;

	new Float:chancePenyu   = 2.0;
	new Float:chanceDolphin = 2.0;

	new Float:chanceHiu     = 1.0;
	new Float:chanceMega    = 1.0;

	if(GlobalFishingLuck)
	{
        chanceMakarel -= 7.0;
        chanceBlue    -= 7.0;
        
	    if(GlobalLuckMultiplier >= 2)
	    {
	        chancePenyu   += 0.4;
	        chanceDolphin += 0.4;
            chanceHiu     += 0.2;
	        chanceMega    += 0.2;
	    }
	    if(GlobalLuckMultiplier >= 4)
	    {
	        chancePenyu   += 0.6;
	        chanceDolphin += 0.6;
	        chanceHiu     += 0.4;
	        chanceMega    += 0.4;
	    }
	    if(GlobalLuckMultiplier >= 6)
	    {
	        chancePenyu   += 0.8;
	        chanceDolphin += 0.8;
	        chanceHiu     += 0.6;
	        chanceMega    += 0.6;
	    }
	    if(GlobalLuckMultiplier >= 8)
	    {
	        chancePenyu   += 1.0;
	        chanceDolphin += 1.0;
	        chanceHiu     += 0.8;
	        chanceMega    += 0.8;
	    }
        if(GlobalLuckMultiplier >= 10)
	    {
	        chancePenyu   += 1.5;
	        chanceDolphin += 1.5;
	        chanceHiu     += 1.0;
	        chanceMega    += 1.0;
        }
	}

	if(chancePenyu   > 5.0) chancePenyu   = 5.0;
	if(chanceDolphin > 5.0) chanceDolphin = 5.0;

	if(chanceHiu  > 2.5) chanceHiu  = 2.5;
	if(chanceMega > 2.5) chanceMega = 2.5;

	new Float:totalChance =
	    chanceMakarel + chanceBlue +
	    chancePenyu + chanceDolphin +
	    chanceHiu + chanceMega;

    new Float:roll = float(random(10000)) / 10000.0 * totalChance;

	if(roll < chanceMakarel)
	{
	    PlayerInfo[playerid][pFish]++;
	    Inventory_Add(playerid, "Ikan_Makarel", 19630);
	    ShowItemBox(playerid, "Received 1x", "Ikan_Makarel", 19630, 2);
	    SendClientMessage(playerid, COLOR_BLUE, "Anda mendapatkan Ikan Makarel.");
	}
	else if((roll -= chanceMakarel) < chanceBlue)
	{
	    PlayerInfo[playerid][pFish]++;
	    Inventory_Add(playerid, "Blue_Fish", 1604);
	    ShowItemBox(playerid, "Received 1x", "Blue_Fish", 1604, 2);
	    SendClientMessage(playerid, COLOR_BLUE, "Anda mendapatkan Blue Fish.");
	}
	else if((roll -= chanceBlue) < chancePenyu)
	{
	    PlayerInfo[playerid][pPenyu]++;
	    Inventory_Add(playerid, "Sea_Turtle", 1609);
	    ShowItemBox(playerid, "Received 1x", "Sea_Turtle", 1609, 2);
	    BroadcastFishing(1, playerid);
	}
	else if((roll -= chancePenyu) < chanceDolphin)
	{
	    PlayerInfo[playerid][pDolphin]++;
	    Inventory_Add(playerid, "Dolphin", 1607);
	    ShowItemBox(playerid, "Received 1x", "Dolphin", 1607, 2);
	    BroadcastFishing(2, playerid);
	}
	else if((roll -= chanceDolphin) < chanceHiu)
	{
	    PlayerInfo[playerid][pHiu]++;
	    Inventory_Add(playerid, "Shark", 1608);
	    ShowItemBox(playerid, "Received 1x", "Shark", 1608, 2);
	    BroadcastFishing(3, playerid);
	}
	else
	{
	    PlayerInfo[playerid][pMegalodon]++;
	    Inventory_Add(playerid, "Megalodon", 1608);
	    ShowItemBox(playerid, "Received 1x", "Megalodon", 1608, 2);
	    BroadcastFishing(4, playerid);
	}
    return 1;
}

FailFishing(playerid)
{
    IsFishing[playerid] = false;
    KillTimer(FishTimer[playerid]);
    ClearAnimations(playerid, 1);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    RemovePlayerAttachedObject(playerid, 9);

    for(new i; i < 12; i++)
        PlayerTextDrawHide(playerid, FishingTD[playerid][i]);

    SendClientMessage(playerid, -1, "Ikan berhasil kabur, kamu gagal!");
    return 1;
}
