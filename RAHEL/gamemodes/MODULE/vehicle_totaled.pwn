// Vehicle Totaled with Explosion after 3 minutes



enum e_vehicletotalled_data
{
    vtExhaustTimer,
    vtTimer, 
    vtFire,
    Text3D:vtLabel,
    bool:vtFired
};

new 
    TotaledData[MAX_VEHICLES][e_vehicletotalled_data],
    playerExhaustTimer[MAX_PLAYERS]
;

hook OnGameModeInit() 
{
    SetTimer("VehicleTotaledCheck", 1000, true);
    return 1;
}

hook OnVehicleCreated(vehicleid)
{
    TotaledData[vehicleid][vtExhaustTimer] = 0;
    TotaledData[vehicleid][vtTimer] = 0;
    TotaledData[vehicleid][vtFire] = INVALID_OBJECT_ID;
    TotaledData[vehicleid][vtFired] = false;
    return 1;
}

VehicleTotaled_Label(vehicleid, bool:show = true)
{
    if(IsValidDynamic3DTextLabel(TotaledData[vehicleid][vtLabel]))
        DestroyDynamic3DTextLabel(TotaledData[vehicleid][vtLabel]);

    if(show) TotaledData[vehicleid][vtLabel] = CreateDynamic3DTextLabel("Loading Vehicle Label", COLOR_RED, 0.0, 0.0, 0.30, 10.0, INVALID_PLAYER_ID, vehicleid);
    return 1;
}

public:VehicleTotaledCheck()
{
    forex(fan, MAX_VEHICLES) if(IsValidVehicle(fan))
    {
        new Float:health;
        GetVehicleHealth(fan, health);

        if(health <= 350.0)
        {
            if(TotaledData[fan][vtTimer] == 0)
            {
                if(IsValidDynamicObject(TotaledData[fan][vtFire])) 
                    DestroyDynamicObject(TotaledData[fan][vtFire]);

                new Float:pos[7], Float:attached[3];
                TotaledData[fan][vtFired] = true;
                TotaledData[fan][vtTimer] = gettime() + 180;
                SetValidVehicleHealth(fan, 350.0);

                foreach(new playerid : Player) if(IsPlayerInVehicle(playerid, fan))
                {
                    SendCustomMessage(playerid, "VEHICLE", "Kendaraan ingin meledak! panggil Fire Department!");
                    RemovePlayerFromVehicle(playerid);
                }

                GetVehiclePos(fan, pos[0], pos[1], pos[2]);
                GetVehicleZAngle(fan, pos[3]);
                SetVehicleZAngle(fan, pos[3]); // fix the rot x & y to 0.0
                if(modelid == 568 || modelid == 483 || modelid == 415
		        || modelid == 431 || modelid == 437 || modelid == 451) // The Engine is behind of vehicle
                    Tryg3D::GetVehiclePartPos(fan, VEHICLE_PART_TRUNK, pos[4], pos[5], pos[6]);
                else
                    Tryg3D::GetVehiclePartPos(fan, VEHICLE_PART_HOOD, pos[4], pos[5], pos[6]);

                new modelid = GetVehicleModel(fan);
                if(modelid == 568 || modelid == 483 || modelid == 415
		        || modelid == 431 || modelid == 437 || modelid == 451) // The Engine is behind of vehicle
                {
                    pos[4] += 1.4 * floatsin(-pos[3], degrees);
                    pos[5] += 1.4 * floatcos(-pos[3], degrees);
                }
                else // The Engine is front of vehicle
                {
                    pos[4] -= 1.4 * floatsin(-pos[3], degrees);
                    pos[5] -= 1.4 * floatcos(-pos[3], degrees);
                }
                /* 
                    menghitung offset saat disatukan/attached ke kendaraan 
                    agar tidak menjadi kekeliruan posisi saat kendaraan tidak berada pada angle 0.0
                */
                attached[0] = ((pos[4] - pos[0]) * floatcos(pos[3], degrees)) + ((pos[5] - pos[1]) * floatsin(pos[3], degrees));
                attached[1] = ((pos[5] - pos[1]) * floatcos(pos[3], degrees)) - ((pos[4] - pos[0]) * floatsin(pos[3], degrees));
                attached[2] = (pos[6] - pos[2]) - 1.3;

                TotaledData[fan][vtFire] = CreateDynamicObject(18690, pos[0], pos[1], pos[2], 0.0, 0.0, 0.0);
                AttachDynamicObjectToVehicle(TotaledData[fan][vtFire], fan, attached[0], attached[1], attached[2], 0.0, 0.0, 0.0);

                VehicleTotaled_Label(fan);
            }
            else
            {
                if(TotaledData[fan][vtTimer] <= gettime())
                {
                    new pvid;
                    
                    TotaledData[fan][vtFired] = false;
                    TotaledData[fan][vtTimer] = 0;
                    if((pvid = Vehicle_GetID(fan)) != -1 && !VehicleData[pvid][cRent])
                    {
                        mysql_tquery(g_SQL, sprintf("DELETE FROM vehiclestorage WHERE `owner` = '%d'", VehicleData[pvid][cID]));
                        VehicleStorage_Reset(pvid);

                        if(VehicleData[pvid][cInsu] > 0)
                        {
                            VehicleData[pvid][cDeath] = 0;
                            VehicleData[pvid][cInsu]--;
                            VehicleData[pvid][cClaim] = 1;
                            VehicleData[pvid][cClaimTime] = gettime() + (3 * 3600);
                            foreach(new pid : Player) if (Vehicle_IsOwner(pid, pvid))
                            {
                                SendCustomMessage(pid, "VEHICLE", "{ffff00}%s{ffffff} anda hancur dan anda masih memiliki insuransi.", GetVehicleModelName(VehicleData[pvid][cModel]));
                                SendCustomMessage(pid, "VEHICLE", "{ffff00}%s{ffffff} baru dapat diclaim setelah 3 jam.", GetVehicleModelName(VehicleData[pvid][cModel]));
                            }

                            VehicleData[pvid][cGasOil] = 
                            VehicleData[pvid][cCoal] =
                            VehicleData[pvid][cProduct] = 
                            VehicleData[pvid][cMetal] =
                            VehicleData[pvid][cLumber] = 
                            VehicleData[pvid][cCargoMat] =
                            VehicleData[pvid][cCargoCompo] =
                            VehicleData[pvid][cCargoMilk] = 0;
                            
                            VehicleData[pvid][cVeh] = INVALID_VEHICLE_ID;
                        }
                        else
                        {
                            new query[128];
                            mysql_format(g_SQL, query, sizeof(query), "DELETE FROM vehicle WHERE id = '%d'", VehicleData[pvid][cID]);
                            mysql_tquery(g_SQL, query);

                            VehicleData[pvid][cVeh] = INVALID_VEHICLE_ID;

                            VehicleData[pvid][cGasOil] = 
                            VehicleData[pvid][cCoal] =
                            VehicleData[pvid][cProduct] = 
                            VehicleData[pvid][cMetal] =
                            VehicleData[pvid][cLumber] = 
                            VehicleData[pvid][cCargoMat] =
                            VehicleData[pvid][cCargoCompo] =
                            VehicleData[pvid][cCargoMilk] = 0;

                            foreach(new pid : Player) if (Vehicle_IsOwner(pid, pvid))
                            {
                                SendCustomMessage(pid, "VEHICLE", "Kendaraan anda hancur dan tidak memiliki insuransi.");
                            }
                            Iter_Remove(PlayerVehicles, pvid);
                            VehicleData[pvid][cDeath] = 0;
                        }
                    }
                    VehicleTotaled_Label(fan, false);
                    if(IsValidDynamicObject(TotaledData[fan][vtFire]))
                        DestroyDynamicObject(TotaledData[fan][vtFire]);
                        
                    DestroyVehicle(fan);
                    // Explode Vehicle
                    new Float:posX, Float:posY, Float:posZ;
                    GetVehiclePos(fan, posX, posY, posZ);
                    CreateExplosion(posX, posY, posZ, 10, 2.0);
                }
                else
                {
                    SetValidVehicleHealth(fan, 350.0);
                    if(IsValidDynamic3DTextLabel(TotaledData[fan][vtLabel]))
                    {
                        UpdateDynamic3DTextLabelText(TotaledData[fan][vtLabel], COLOR_RED, sprintf("Vehicle will explode in %s!", ReturnTimelapse(gettime(), TotaledData[fan][vtTimer])));
                    }
                }
            }
        }
        else 
        {
            if(TotaledData[fan][vtFired]) 
            {
                TotaledData[fan][vtFired] = false;
                if(IsValidDynamicObject(TotaledData[fan][vtFire]))
                    DestroyDynamicObject(TotaledData[fan][vtFire]);
                    
                GameTextForPlayer(GetVehicleDriver(fan), "Vehicle Repaired!", 2000, 3);
                TotaledData[fan][vtExhaustTimer] = 0;
                TotaledData[fan][vtTimer] = 0;
                VehicleTotaled_Label(fan, false);
            }
        }
    }
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if(TotaledData[vehicleid][vtFired])
    {
        new Float:pos[3];
        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        SendCustomMessage(playerid, "VEHICLE", "Kendaraan ini dalam kondisi kritis dan sedang terbakar! Segera panggil Fire Department.");
    }
    return 1;
}

/*hook OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    if(hittype == BULLET_HIT_TYPE_VEHICLE && IsValidVehicle(hitid) && TotaledData[hitid][vtFired])
    {
        if(weaponid == WEAPON_FIREEXTINGUISHER)
        {
            TotaledData[hitid][vtExhaustTimer]++;
            GameTextForPlayer(playerid, "%d/100", 2000, 3, TotaledData[hitid][vtExhaustTimer]);
            if(TotaledData[hitid][vtExhaustTimer] >= 100)
            {
                if(IsValidDynamicObject(TotaledData[hitid][vtFire]))
                    DestroyDynamicObject(TotaledData[hitid][vtFire]);

                TotaledData[hitid][vtFired] = false;
                TotaledData[hitid][vtTimer] = 0;
                TotaledData[hitid][vtExhaustTimer] = 0;
                SetVehicleHealth(hitid, 500.0); // Repair Vehicle
                GameTextForPlayer(playerid, "Vehicle Repaired!", 2000, 3);
            }
        }
    }
    return 1;
}*/

hook OnPlayerConnect(playerid)
{
    playerExhaustTimer[playerid] = SetTimerEx("Player_FireExhausting", 1000, true, "d", playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    if(IsValidTimer(playerExhaustTimer[playerid]))
        KillTimer(playerExhaustTimer[playerid]);
        
    return 1;
}

hook Player_FireExhausting(playerid)
{
    new vehicleid = GetNearestVehicleToPlayer(playerid, 5.0), KEY:keys, updown, leftright;
    if(vehicleid != INVALID_VEHICLE_ID && TotaledData[vehicleid][vtFired])
    {
        GetPlayerKeys(playerid, keys, updown, leftright);
        if(keys & KEY_FIRE)
        {
            if(GetPlayerWeapon(playerid) == WEAPON_FIREEXTINGUISHER)
            {
                TotaledData[vehicleid][vtExhaustTimer]++;
                GameTextForPlayer(playerid, "~y~Exhausting~n~~w~%d/100", 2000, 3, TotaledData[vehicleid][vtExhaustTimer]);
                if(TotaledData[vehicleid][vtExhaustTimer] >= 100)
                {
                    if(IsValidDynamicObject(TotaledData[vehicleid][vtFire]))
                        DestroyDynamicObject(TotaledData[vehicleid][vtFire]);

                    TotaledData[vehicleid][vtFired] = false;
                    TotaledData[vehicleid][vtTimer] = 0;
                    TotaledData[vehicleid][vtExhaustTimer] = 0;
                    SetVehicleHealth(vehicleid, 500.0); // Repair Vehicle
                    GameTextForPlayer(playerid, "Vehicle Exhausted!", 2000, 3);
                }
            }
        }
    }
    return 1;
}