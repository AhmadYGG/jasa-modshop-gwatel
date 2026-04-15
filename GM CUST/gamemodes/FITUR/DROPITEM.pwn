#define MAX_DROPPED_ITEMS 1000
enum droppedItems
{
	droppedID,
	droppedItem[32],
	droppedPlayer[24],
	droppedModel,
	droppedQuantity,
	Float:droppedPos[3],
	droppedWeapon,
	droppedAmmo,
	droppedInt,
	droppedWorld,
	droppedObject,
	Text3D:droppedText3D
};

new DroppedItems[MAX_DROPPED_ITEMS][droppedItems],
	Iterator:DROPPED<MAX_DROPPED_ITEMS>;

epublic: Dropped_Load()
{
	new rows;
	cache_get_row_count(rows);
 	if(rows)
  	{
  		new id, i = 0;
    	while(i < rows)
		{
		    cache_get_value_name_int(i, "ID", id);
			cache_get_value_name(i, "itemName", DroppedItems[id][droppedItem]);
			cache_get_value_name_int(i, "itemModel", DroppedItems[id][droppedModel]);
			cache_get_value_name_int(i, "itemQuantity", DroppedItems[id][droppedQuantity]);
			cache_get_value_name_float(i, "itemX", DroppedItems[id][droppedPos][0]);
			cache_get_value_name_float(i, "itemY", DroppedItems[id][droppedPos][1]);
			cache_get_value_name_float(i, "itemZ", DroppedItems[id][droppedPos][2]);
			cache_get_value_name_int(i, "itemInt", DroppedItems[id][droppedInt]);
			cache_get_value_name_int(i, "itemWorld", DroppedItems[id][droppedWorld]);
			DroppedItems[id][droppedObject] = CreateDynamicObject(DroppedItems[id][droppedModel], DroppedItems[id][droppedPos][0], DroppedItems[id][droppedPos][1], DroppedItems[id][droppedPos][2], 0.0, 0.0, 0.0, DroppedItems[id][droppedWorld], DroppedItems[id][droppedInt]);
			DroppedItems[id][droppedText3D] = CreateDynamic3DTextLabel(DroppedItems[id][droppedItem], COLOR_YELLOW, DroppedItems[id][droppedPos][0], DroppedItems[id][droppedPos][1], DroppedItems[id][droppedPos][2], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, DroppedItems[id][droppedWorld], DroppedItems[id][droppedInt]);
			Iter_Add(DROPPED, id);
			i++;
		}
		printf("[DROPITEM] Loaded: %d Dropped Items", i);
	}
}

Dropped_Save(id)
{
	new cQuery[512];
	format(cQuery, sizeof(cQuery), "UPDATE dropped SET itemName='%s', itemModel='%d', itemQuantity='%d', itemX='%f', itemY='%f', itemZ='%f', itemInt='%d', itemWorld='%d' WHERE ID='%d'",
	DroppedItems[id][droppedItem],
	DroppedItems[id][droppedModel],
	DroppedItems[id][droppedQuantity],
	DroppedItems[id][droppedPos][0],
	DroppedItems[id][droppedPos][1],
	DroppedItems[id][droppedPos][2],
	DroppedItems[id][droppedInt],
	DroppedItems[id][droppedWorld],
	id
	);
	return mysql_tquery(mMysql, cQuery);
}

epublic: DropItem(name[], itemid, value, Float:x, Float:y, Float:z, interior, world)
{
	new
	    query[512];

	new id = Iter_Free(DROPPED);
	
    format(DroppedItems[id][droppedItem], 32, name);

	DroppedItems[id][droppedModel] = itemid;
	DroppedItems[id][droppedPos][0] = x;
	DroppedItems[id][droppedPos][1] = y;
	DroppedItems[id][droppedPos][2] = z;
	DroppedItems[id][droppedQuantity] = value;
	DroppedItems[id][droppedInt] = interior;
	DroppedItems[id][droppedWorld] = world;
	printf("DropItem: %d", value);

	DroppedItems[id][droppedObject] = CreateDynamicObject(itemid, x, y, z, 0.0, 0.0, 0.0, world, interior);

	DroppedItems[id][droppedText3D] = CreateDynamic3DTextLabel(name, COLOR_YELLOW, x, y, z, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, world, interior);

	Iter_Add(DROPPED, id);
	mysql_format(mMysql, query, sizeof(query), "INSERT INTO dropped SET ID='%d', itemName='%s', itemModel='%d', itemQuantity='%d', itemX='%.4f', itemY='%.4f', itemZ='%.4f', itemInt='%d', itemWorld='%d'", id, name, itemid, value, x, y, z, interior, world);
	mysql_tquery(mMysql, query, "OnDroppedItem", "d", id);
	return 1;
}

epublic: OnDroppedItem(id)
{
	Dropped_Save(id);
	return 1;
}

epublic: DropPlayerItem(playerid, itemid, name[], value)
{
    new str[500], Float:x, Float:y, Float:z, Float:angle;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, angle);

    if(!strcmp(name, "Component"))
	{
	    if(PlayerInfo[playerid][pComponent] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");
	
		itemid = 3096;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Component", str, 3096, 5);
		PlayerInfo[playerid][pComponent] -= value;
		OnPlayerUpdateAccountsPer(playerid, "pComponent", PlayerInfo[playerid][pComponent]);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Jus", true))
	{
    	if(PlayerInfo[playerid][pDrink] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 1546;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Jus", str, 1546, 5);
        PlayerInfo[playerid][pDrink] -= value;
        OnPlayerUpdateAccountsPer(playerid, "pDrink", PlayerInfo[playerid][pDrink]);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Burger", true))
	{
        if(PlayerInfo[playerid][pFood] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 2880;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Burger", str, 2880, 5);
        PlayerInfo[playerid][pFood] -= value;
        OnPlayerUpdateAccountsPer(playerid, "pFood", PlayerInfo[playerid][pFood]);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Vest", true))
	{
	    if(PlayerInfo[playerid][pVest] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 1242;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Vest", str, 1242, 5);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Perban", true))
	{
	    if(PlayerInfo[playerid][pHeals] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 11736;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Perban", str, 11736, 5);
        PlayerInfo[playerid][pHeals] -= value;
        OnPlayerUpdateAccountsPer(playerid, "pHeals", PlayerInfo[playerid][pHeals]);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Repairkit", true))
	{
    	if(PlayerInfo[playerid][pRepairKit] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 1010;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Repairkit", str, 1010, 5);
        PlayerInfo[playerid][pRepairKit] -= value;
        OnPlayerUpdateAccountsPer(playerid, "pRepairKit", PlayerInfo[playerid][pRepairKit]);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Jerigen", true))
	{
	    if(PlayerInfo[playerid][pJerigen] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 1650;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Jerigen", str, 1650, 5);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Hand_Phone", true))
	{
	    if(PlayerInfo[playerid][pProducts][0] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");
	
		itemid = 18867;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Hand_Phone", str, 18867, 5);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Ktp", true))
	{
	    if(PlayerInfo[playerid][pKtp] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 1581;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Ktp", str, 1581, 5);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Jam", true))
	{
	    if(PlayerInfo[playerid][pClock] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 19039;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Jam", str, 19039, 5);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Mask", true))
	{
	    if(PlayerInfo[playerid][pMask] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 19036;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Mask", str, 19036, 5);
        PlayerInfo[playerid][pMask] -= value;
        OnPlayerUpdateAccountsPer(playerid, "pMask", PlayerInfo[playerid][pMask]);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Drugs", true))
	{
	    if(PlayerInfo[playerid][pDrugs] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 1580;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Drugs", str, 1580, 5);
        PlayerInfo[playerid][pDrugs] -= value;
        OnPlayerUpdateAccountsPer(playerid, "pDrugs", PlayerInfo[playerid][pDrugs]);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Marijuana", true))
	{
	    if(PlayerInfo[playerid][pMicin] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 19473;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Marijuana", str, 19473, 5);
        PlayerInfo[playerid][pMicin] -= value;
        OnPlayerUpdateAccountsPer(playerid, "pMicin", PlayerInfo[playerid][pMicin]);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Rokok", true))
	{
	    if(PlayerInfo[playerid][pRokok] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 19625;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Rokok", str, 19625, 5);
        PlayerInfo[playerid][pRokok] -= value;
        OnPlayerUpdateAccountsPer(playerid, "pRokok", PlayerInfo[playerid][pRokok]);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Boombox", true))
	{
	    if(PlayerInfo[playerid][pBoombox] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 2226;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Boombox", str, 2226, 5);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
	else if(!strcmp(name, "Radio", true))
	{
	    if(PlayerInfo[playerid][pRadio] < GiveAmount[playerid]) return SCM(playerid, COLOR_RED, "ERROR: "W"Barang Anda Tidak Mencukupi!");

		itemid = 19942;
		format(str, sizeof(str), "Removed_%dx", GiveAmount[playerid]);
		ShowItemBox(playerid, "Radio", str, 19942, 5);
        Inventory_Close(playerid);
	    ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 4.1, 0, 0, 0, 0, 0, 1);
	}
		
    printf("Itemid: %d, Name: %s, value: %d", itemid, name, value);

	DropItem(name, itemid, value, x, y, z - 0.9, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
    
	return Inventory_Close(playerid);
}

NearItemDropped(playerid, targetid, Float:radius)
{
    return (IsPlayerInRangeOfPoint(playerid, radius, DroppedItems[targetid][droppedPos][0], DroppedItems[targetid][droppedPos][1], DroppedItems[targetid][droppedPos][2]));
}

epublic: TakePlayerItem(playerid, id, name[])
{
	new str[50], query[512];
	DestroyDynamicObject(DroppedItems[id][droppedObject]);
	DestroyDynamic3DTextLabel(DroppedItems[id][droppedText3D]);
	DroppedItems[id][droppedObject] = -1;
	DroppedItems[id][droppedText3D] = Text3D: -1;
	Iter_Remove(DROPPED, id);

	if(!strcmp(name, "Jus", true))
	{
        PlayerInfo[playerid][pDrink] += DroppedItems[id][droppedQuantity];
        OnPlayerUpdateAccountsPer(playerid, "pDrink", PlayerInfo[playerid][pDrink]);
                
        mysql_format(mMysql, query, sizeof(query), "DELETE FROM dropped WHERE id= %d", id);
	    mysql_tquery(mMysql, query);

	    format(str, sizeof(str), "Received_%dx", DroppedItems[id][droppedQuantity]);
	    ShowItemBox(playerid, DroppedItems[id][droppedItem], str, DroppedItems[id][droppedModel], 3);
	    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,0,0,0,0,0);
	}
	else if(!strcmp(name, "Burger", true))
	{
        PlayerInfo[playerid][pFood] += DroppedItems[id][droppedQuantity];
        OnPlayerUpdateAccountsPer(playerid, "pFood", PlayerInfo[playerid][pFood]);
                
        mysql_format(mMysql, query, sizeof(query), "DELETE FROM dropped WHERE id= %d", id);
	    mysql_tquery(mMysql, query);

	    format(str, sizeof(str), "Received_%dx", DroppedItems[id][droppedQuantity]);
	    ShowItemBox(playerid, DroppedItems[id][droppedItem], str, DroppedItems[id][droppedModel], 3);
	    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,0,0,0,0,0);
	}
	else if(!strcmp(name, "Perban", true))
	{
        PlayerInfo[playerid][pHeals] += DroppedItems[id][droppedQuantity];
        OnPlayerUpdateAccountsPer(playerid, "pHeals", PlayerInfo[playerid][pHeals]);
                
        mysql_format(mMysql, query, sizeof(query), "DELETE FROM dropped WHERE id= %d", id);
	    mysql_tquery(mMysql, query);

	    format(str, sizeof(str), "Received_%dx", DroppedItems[id][droppedQuantity]);
	    ShowItemBox(playerid, DroppedItems[id][droppedItem], str, DroppedItems[id][droppedModel], 3);
	    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,0,0,0,0,0);
	}
	else if(!strcmp(name, "Repairkit", true))
	{
        PlayerInfo[playerid][pRepairKit] += DroppedItems[id][droppedQuantity];
        OnPlayerUpdateAccountsPer(playerid, "pRepairKit", PlayerInfo[playerid][pRepairKit]);
                
        mysql_format(mMysql, query, sizeof(query), "DELETE FROM dropped WHERE id= %d", id);
	    mysql_tquery(mMysql, query);

	    format(str, sizeof(str), "Received_%dx", DroppedItems[id][droppedQuantity]);
	    ShowItemBox(playerid, DroppedItems[id][droppedItem], str, DroppedItems[id][droppedModel], 3);
	    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,0,0,0,0,0);
	}
	else if(!strcmp(name, "Component", true))
	{
        PlayerInfo[playerid][pComponent] += DroppedItems[id][droppedQuantity];
        OnPlayerUpdateAccountsPer(playerid, "pComponent", PlayerInfo[playerid][pComponent]);
                
        mysql_format(mMysql, query, sizeof(query), "DELETE FROM dropped WHERE id= %d", id);
	    mysql_tquery(mMysql, query);

	    format(str, sizeof(str), "Received_%dx", DroppedItems[id][droppedQuantity]);
	    ShowItemBox(playerid, DroppedItems[id][droppedItem], str, DroppedItems[id][droppedModel], 3);
	    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,0,0,0,0,0);
	}
	else if(!strcmp(name, "Drugs", true))
	{
        PlayerInfo[playerid][pDrugs] += DroppedItems[id][droppedQuantity];
        OnPlayerUpdateAccountsPer(playerid, "pDrugs", PlayerInfo[playerid][pDrugs]);
                
        mysql_format(mMysql, query, sizeof(query), "DELETE FROM dropped WHERE id= %d", id);
	    mysql_tquery(mMysql, query);

	    format(str, sizeof(str), "Received_%dx", DroppedItems[id][droppedQuantity]);
	    ShowItemBox(playerid, DroppedItems[id][droppedItem], str, DroppedItems[id][droppedModel], 3);
	    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,0,0,0,0,0);
	}
	else if(!strcmp(name, "Marijuana", true))
	{
        PlayerInfo[playerid][pMicin] += DroppedItems[id][droppedQuantity];
        OnPlayerUpdateAccountsPer(playerid, "pMicin", PlayerInfo[playerid][pMicin]);
                
        mysql_format(mMysql, query, sizeof(query), "DELETE FROM dropped WHERE id= %d", id);
	    mysql_tquery(mMysql, query);

	    format(str, sizeof(str), "Received_%dx", DroppedItems[id][droppedQuantity]);
	    ShowItemBox(playerid, DroppedItems[id][droppedItem], str, DroppedItems[id][droppedModel], 3);
	    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,0,0,0,0,0);
	}
	else if(!strcmp(name, "Rokok", true))
	{
        PlayerInfo[playerid][pRokok] += DroppedItems[id][droppedQuantity];
        OnPlayerUpdateAccountsPer(playerid, "pRokok", PlayerInfo[playerid][pRokok]);
        
        mysql_format(mMysql, query, sizeof(query), "DELETE FROM dropped WHERE id= %d", id);
	    mysql_tquery(mMysql, query);

	    format(str, sizeof(str), "Received_%dx", DroppedItems[id][droppedQuantity]);
	    ShowItemBox(playerid, DroppedItems[id][droppedItem], str, DroppedItems[id][droppedModel], 3);
	    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,0,0,0,0,0);
	}
	return 1;
}

CMD:takedrop(playerid)
{
	new count = 0, str[500], strr[500];
	foreach(new i : DROPPED) if(NearItemDropped(playerid, i, 3))
	{
		format(str, sizeof(str), "%d. %s\tAmount: %d\n", i, DroppedItems[i][droppedItem], DroppedItems[i][droppedQuantity]);
		strcat(strr, str);
		SetPlayerListitemValue(playerid, count++, i);
	}
	if(!count) SCM(playerid, COLOR_RED, "ERROR: "W"Tidak ada item yang terbuang di dekat anda");
	else ShowPlayerDialog(playerid, DIALOG_TAKE, DIALOG_STYLE_LIST, "Kota Asia - Item Drop", strr, "Ambil", "Tutup");
}
