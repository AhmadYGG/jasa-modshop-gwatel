
#if defined _afk_included
    #endinput
#endif
#define _afk_included

#include <a_samp>
#include <sscanf2>
#include <foreach>

#define COLOR_RED 0xFF0000FF

enum pAFKInfo {
    afkStatus,
    afkTime,
    afkStartTime,
    afkPosX,
    afkPosY,
    afkPosZ,
    afkCode
};
new PlayerAFK[MAX_PLAYERS][pAFKInfo];
new PlayerText:AFKTextdraw[MAX_PLAYERS];

stock InitAFKSystem()
{
    SetTimer("CheckAFKStatus", 30000, true);
    return 1;
}

stock OnAFKPlayerConnect(playerid)
{
    AFKTextdraw[playerid] = CreatePlayerTextDraw(playerid, 320.0, 80.0, "");
    PlayerTextDrawAlignment(playerid, AFKTextdraw[playerid], 2);
    PlayerTextDrawFont(playerid, AFKTextdraw[playerid], 2);
    PlayerTextDrawLetterSize(playerid, AFKTextdraw[playerid], 0.25, 1.2);
    PlayerTextDrawColor(playerid, AFKTextdraw[playerid], -1);
    PlayerTextDrawSetOutline(playerid, AFKTextdraw[playerid], 1);
    PlayerTextDrawSetProportional(playerid, AFKTextdraw[playerid], 1);

    PlayerAFK[playerid][afkTime] = gettime();
    GetPlayerPos(playerid, PlayerAFK[playerid][afkPosX], PlayerAFK[playerid][afkPosY], PlayerAFK[playerid][afkPosZ]);
    return 1;
}

stock OnAFKPlayerUpdate(playerid)
{
    static Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if(floatcmp(x, PlayerAFK[playerid][afkPosX]) != 0 ||
       floatcmp(y, PlayerAFK[playerid][afkPosY]) != 0 ||
       floatcmp(z, PlayerAFK[playerid][afkPosZ]) != 0)
    {
        PlayerAFK[playerid][afkTime] = gettime();
        PlayerAFK[playerid][afkPosX] = x;
        PlayerAFK[playerid][afkPosY] = y;
        PlayerAFK[playerid][afkPosZ] = z;
    }
    return 1;
}

forward CheckAFKStatus();
public CheckAFKStatus()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;

        if(PlayerAFK[i][afkStatus] == 0)
        {
            if(gettime() - PlayerAFK[i][afkTime] >= 900)
            {
                PlayerAFK[i][afkStatus] = 1;
                PlayerAFK[i][afkStartTime] = gettime();
                PlayerAFK[i][afkCode] = 9000 + random(999);
                TogglePlayerControllable(i, 0);

                new msg[128];
                format(msg, sizeof(msg),
                "~r~You Are In AFK Mode\n~y~Use /afk %d to disable or get kicked in 3 minutes",
                PlayerAFK[i][afkCode]);
                PlayerTextDrawSetString(i, AFKTextdraw[i], msg);
                PlayerTextDrawShow(i, AFKTextdraw[i]);

                new msgAFK[128];
		format(msgAFK, sizeof(msgAFK), "Kamu AFK terlalu lama! Ketik /afk %d untuk kembali.", PlayerAFK[i][afkCode]);
		SendClientMessage(i, -1, msgAFK);
            }
        }
        else
        {
            if(gettime() - PlayerAFK[i][afkStartTime] >= 300)
            {
                SendClientMessage(i, -1, "Kamu di-kick karena terlalu lama dalam mode AFK.");
                Kick(i);
            }
        }
    }
    return 1;
}

CMD:afk(playerid, params[])
{
    new code;
    if(sscanf(params, "d", code)) return SendClientMessage(playerid, -1, "Usage: /afk [code]");
    if(PlayerAFK[playerid][afkStatus] == 0) return SendClientMessage(playerid, -1, "Kamu tidak sedang AFK.");
    if(code != PlayerAFK[playerid][afkCode]) return SendClientMessage(playerid, -1, "Kode salah!");

    PlayerAFK[playerid][afkStatus] = 0;
    TogglePlayerControllable(playerid, 1);
    PlayerAFK[playerid][afkTime] = gettime();
    PlayerTextDrawHide(playerid, AFKTextdraw[playerid]);

    SendClientMessage(playerid, -1, "AFK dinonaktifkan. Selamat datang kembali!");
    return 1;
}
