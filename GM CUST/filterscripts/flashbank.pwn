// =============================================================
//  FlashBank Filterscript for SA:MP 0.3.7 + SAMP Mobile
//  Weapon 17 (Teargas) diubah menjadi Smoke Bomb / FlashBank
// =============================================================

#include <a_samp>

// --------------------------------------------------
//  Defines
// --------------------------------------------------
#define FLASHBANK_RADIUS        50.0        // [FIX] 1000m -> 50m (realistis)
#define FLASHBANK_DURATION      5000        // 5 detik efek
#define BLINK_INTERVAL          700         // [FIX] 400ms -> 700ms (tidak brutal di mobile)
#define SMOKE_LIFETIME          15000
#define THROW_DELAY             1500        // 1.5 detik waktu terbang
#define MAX_SMOKE_OBJ           23
#define FLASHBANK_DRUNK         50000       // [NEW] Ganti fullscreen box dengan DrunkLevel

#define OBJ_SMOKE_SMALL         18728
#define OBJ_SMOKE_LARGE         3781

#define PRESSED(%0)             (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

// --------------------------------------------------
//  Variables
// --------------------------------------------------
// [FIX] Hapus ptdWhite - ROOT CAUSE bug layar brutal di SAMP Mobile
// TextDraw box 640x480 menyebabkan rendering artifacts yang parah di mobile
new PlayerText:ptdText[MAX_PLAYERS];

new bool:g_Affected[MAX_PLAYERS];
new g_EndTimer[MAX_PLAYERS];
new g_BlinkTimer[MAX_PLAYERS];
new g_BlinkState[MAX_PLAYERS];

new Float:g_ThrowX[MAX_PLAYERS];
new Float:g_ThrowY[MAX_PLAYERS];
new Float:g_ThrowZ[MAX_PLAYERS];
new g_ThrowTimer[MAX_PLAYERS];

new g_SmokeObj[MAX_SMOKE_OBJ];
new g_SmokeCount;
new g_SmokeTimer;

// --------------------------------------------------
//  Forwards
// --------------------------------------------------
forward FlashBankEnd(playerid);
forward FlashBankBlink(playerid);
forward FlashBankClearSmoke();
forward FlashBankLand(playerid);
forward Float:FB_GetDist(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2);

main() {}

// =============================================================
//   FILTER SCRIPT INIT / EXIT
// =============================================================

public OnFilterScriptInit()
{
    for(new i = 0; i < MAX_SMOKE_OBJ; i++)
        g_SmokeObj[i] = -1;

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        g_Affected[i]    = false;
        g_EndTimer[i]    = -1;
        g_BlinkTimer[i]  = -1;
        g_BlinkState[i]  = 0;
        g_ThrowTimer[i]  = -1;
        g_ThrowX[i]      = 0.0;
        g_ThrowY[i]      = 0.0;
        g_ThrowZ[i]      = 0.0;
        ptdText[i]       = PlayerText:INVALID_TEXT_DRAW;

        // [FIX] Buat textdraw untuk player yang sudah connect saat FS di-load
        // Versi lama tidak handle ini -> crash/bug jika FS di-load saat ada player
        if(IsPlayerConnected(i) && !IsPlayerNPC(i))
            FB_CreateTextDraws(i);
    }
    g_SmokeCount = 0;
    g_SmokeTimer = -1;

    print(" ");
    print(" [FlashBank] ==============================================");
    print(" [FlashBank]  FlashBank v2.0 - No Bug Edition             ");
    print(" [FlashBank]  Author : GeeStore                           ");
    print(" [FlashBank]  Mobile 100% Compatible - No Screen Glitch   ");
    print(" [FlashBank] ==============================================");
    print(" ");
    return 1;
}

public OnFilterScriptExit()
{
    // Hapus semua objek asap
    for(new i = 0; i < MAX_SMOKE_OBJ; i++)
    {
        if(g_SmokeObj[i] != -1) { DestroyObject(g_SmokeObj[i]); g_SmokeObj[i] = -1; }
    }
    if(g_SmokeTimer != -1) { KillTimer(g_SmokeTimer); g_SmokeTimer = -1; }

    // [FIX] Cleanup semua player dengan benar
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;

        // Stop efek jika sedang aktif
        if(g_Affected[i]) FB_StopEffect(i);

        // Kill throw timer
        if(g_ThrowTimer[i] != -1) { KillTimer(g_ThrowTimer[i]); g_ThrowTimer[i] = -1; }

        // [FIX] Destroy textdraw saat FS unload (versi lama tidak melakukan ini)
        if(ptdText[i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(i, ptdText[i]);
            ptdText[i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }

    print(" [FlashBank] Filterscript UNLOADED.");
    return 1;
}

// =============================================================
//   PLAYER CALLBACKS
// =============================================================

public OnPlayerConnect(playerid)
{
    g_Affected[playerid]   = false;
    g_EndTimer[playerid]   = -1;
    g_BlinkTimer[playerid] = -1;
    g_BlinkState[playerid] = 0;
    g_ThrowTimer[playerid] = -1;
    g_ThrowX[playerid]     = 0.0;
    g_ThrowY[playerid]     = 0.0;
    g_ThrowZ[playerid]     = 0.0;
    ptdText[playerid]      = PlayerText:INVALID_TEXT_DRAW;

    FB_CreateTextDraws(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    // Kill semua timer aktif
    if(g_EndTimer[playerid] != -1)
    {
        KillTimer(g_EndTimer[playerid]);
        g_EndTimer[playerid] = -1;
    }
    if(g_BlinkTimer[playerid] != -1)
    {
        KillTimer(g_BlinkTimer[playerid]);
        g_BlinkTimer[playerid] = -1;
    }
    if(g_ThrowTimer[playerid] != -1)
    {
        KillTimer(g_ThrowTimer[playerid]);
        g_ThrowTimer[playerid] = -1;
    }

    g_Affected[playerid]   = false;
    g_BlinkState[playerid] = 0;

    // [FIX] Reset DrunkLevel saat disconnect agar tidak carry ke sesi berikutnya
    SetPlayerDrunkLevel(playerid, 0);

    // Destroy textdraw
    if(ptdText[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, ptdText[playerid]);
        ptdText[playerid] = PlayerText:INVALID_TEXT_DRAW;
    }
    return 1;
}

// =============================================================
//   KEY STATE CHANGE - Deteksi throw teargas
//   Bekerja di PC dan SAMP Mobile 1.0.6
// =============================================================

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(PRESSED(KEY_FIRE) || PRESSED(KEY_SECONDARY_ATTACK))
    {
        if(GetPlayerWeapon(playerid) == 17 && GetPlayerAmmo(playerid) > 0)
        {
            new Float:px, Float:py, Float:pz, Float:angle;
            GetPlayerPos(playerid, px, py, pz);
            GetPlayerFacingAngle(playerid, angle);

            // Estimasi titik landing teargas (15 unit ke depan player)
            g_ThrowX[playerid] = px + 15.0 * floatsin(-angle, degrees);
            g_ThrowY[playerid] = py + 15.0 * floatcos(-angle, degrees);
            g_ThrowZ[playerid] = pz;

            // Cancel timer sebelumnya jika lempar lagi
            if(g_ThrowTimer[playerid] != -1)
            {
                KillTimer(g_ThrowTimer[playerid]);
                g_ThrowTimer[playerid] = -1;
            }

            g_ThrowTimer[playerid] = SetTimerEx("FlashBankLand", THROW_DELAY, false, "i", playerid);
        }
    }
    return 1;
}

// =============================================================
//   PUBLIC TIMER CALLBACKS
// =============================================================

// Dipanggil setelah THROW_DELAY ms (teargas landing)
public FlashBankLand(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    g_ThrowTimer[playerid] = -1;

    new Float:ex = g_ThrowX[playerid];
    new Float:ey = g_ThrowY[playerid];
    new Float:ez = g_ThrowZ[playerid];

    // Ledakan di titik landing
    CreateExplosion(ex, ey, ez, 3, 10.0);

    // Spawn asap putih
    FB_SpawnSmoke(ex, ey, ez);

    // Efek ke semua player dalam radius 50m
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(IsPlayerNPC(i))        continue;

        new Float:px, Float:py, Float:pz;
        GetPlayerPos(i, px, py, pz);

        if(FB_GetDist(px, py, pz, ex, ey, ez) <= FLASHBANK_RADIUS)
            FB_StartEffect(i);
    }
    return 1;
}

// Hentikan efek setelah 5 detik
public FlashBankEnd(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    FB_StopEffect(playerid);
    g_EndTimer[playerid] = -1;
    return 1;
}

// Toggle teks berkedip tiap 700ms
public FlashBankBlink(playerid)
{
    if(!IsPlayerConnected(playerid) || !g_Affected[playerid]) return 0;

    // [FIX] Cek validitas textdraw sebelum Show/Hide
    if(ptdText[playerid] == PlayerText:INVALID_TEXT_DRAW) return 0;

    if(g_BlinkState[playerid] == 0)
    {
        PlayerTextDrawShow(playerid, ptdText[playerid]);
        g_BlinkState[playerid] = 1;
    }
    else
    {
        PlayerTextDrawHide(playerid, ptdText[playerid]);
        g_BlinkState[playerid] = 0;
    }
    return 1;
}

// Hapus objek asap setelah 15 detik
public FlashBankClearSmoke()
{
    for(new i = 0; i < MAX_SMOKE_OBJ; i++)
    {
        if(g_SmokeObj[i] != -1) { DestroyObject(g_SmokeObj[i]); g_SmokeObj[i] = -1; }
    }
    g_SmokeCount = 0;
    g_SmokeTimer = -1;
    return 1;
}

// =============================================================
//   INTERNAL STOCK FUNCTIONS
// =============================================================

stock FB_CreateTextDraws(playerid)
{
    // [FIX] Destroy textdraw lama dulu sebelum create baru
    // Versi lama langsung create -> TextDraw slot leak jika dipanggil 2x
    if(ptdText[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, ptdText[playerid]);
        ptdText[playerid] = PlayerText:INVALID_TEXT_DRAW;
    }

    // [FIX] Hanya buat satu textdraw kecil di tengah layar
    // TIDAK ADA box fullscreen (ptdWhite dihapus total)
    // Box fullscreen adalah ROOT CAUSE layar bergerak brutal di SAMP Mobile
    ptdText[playerid] = CreatePlayerTextDraw(playerid, 320.0, 185.0, "~r~~h~! FLASHBANK !");
    PlayerTextDrawAlignment(playerid, ptdText[playerid], 2);
    PlayerTextDrawFont(playerid, ptdText[playerid], 2);
    PlayerTextDrawLetterSize(playerid, ptdText[playerid], 0.55, 2.8);
    PlayerTextDrawColor(playerid, ptdText[playerid], 0xFFFFFFFF);
    PlayerTextDrawSetOutline(playerid, ptdText[playerid], 2);
    PlayerTextDrawSetShadow(playerid, ptdText[playerid], 1);
    PlayerTextDrawSetProportional(playerid, ptdText[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, ptdText[playerid], 0x000000CC);
    // Tidak ada UseBox / BoxColor -> tidak ada fullscreen overlay
}

stock FB_StartEffect(playerid)
{
    // Kill timer aktif jika efek sebelumnya belum selesai
    if(g_Affected[playerid])
    {
        if(g_EndTimer[playerid] != -1)   { KillTimer(g_EndTimer[playerid]);   g_EndTimer[playerid] = -1; }
        if(g_BlinkTimer[playerid] != -1) { KillTimer(g_BlinkTimer[playerid]); g_BlinkTimer[playerid] = -1; }
    }

    g_Affected[playerid]   = true;
    g_BlinkState[playerid] = 0;

    // [FIX] Ganti ptdWhite fullscreen box dengan SetPlayerDrunkLevel
    // Efek visual goyang layar yang RINGAN dan mobile-safe
    // Tidak ada rendering artifacts seperti textdraw box fullscreen
    SetPlayerDrunkLevel(playerid, FLASHBANK_DRUNK);

    // Sound flashbang
    PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);

    // [FIX] Cek validitas textdraw sebelum Show
    if(ptdText[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawShow(playerid, ptdText[playerid]);
        g_BlinkState[playerid] = 1;
    }

    // GameText tambahan untuk efek flash putih singkat (aman di mobile)
    GameTextForPlayer(playerid, "~w~~h~~h~~h~.", 800, 6);

    // Start timers
    g_BlinkTimer[playerid] = SetTimerEx("FlashBankBlink",  BLINK_INTERVAL,    true,  "i", playerid);
    g_EndTimer[playerid]   = SetTimerEx("FlashBankEnd",    FLASHBANK_DURATION, false, "i", playerid);
}

stock FB_StopEffect(playerid)
{
    g_Affected[playerid] = false;

    if(g_BlinkTimer[playerid] != -1)
    {
        KillTimer(g_BlinkTimer[playerid]);
        g_BlinkTimer[playerid] = -1;
    }

    // [FIX] Reset DrunkLevel saat efek selesai
    SetPlayerDrunkLevel(playerid, 0);

    // Hide textdraw dengan cek validitas
    if(ptdText[playerid] != PlayerText:INVALID_TEXT_DRAW)
        PlayerTextDrawHide(playerid, ptdText[playerid]);

    g_BlinkState[playerid] = 0;
}

stock FB_SpawnSmoke(Float:x, Float:y, Float:z)
{
    // Kill smoke timer lama & destroy semua objek asap sebelumnya
    if(g_SmokeTimer != -1) { KillTimer(g_SmokeTimer); g_SmokeTimer = -1; }
    for(new i = 0; i < MAX_SMOKE_OBJ; i++)
    {
        if(g_SmokeObj[i] != -1) { DestroyObject(g_SmokeObj[i]); g_SmokeObj[i] = -1; }
    }
    g_SmokeCount = 0;

    // Tengah
    g_SmokeObj[g_SmokeCount++] = CreateObject(OBJ_SMOKE_SMALL, x, y, z + 0.5, 0.0, 0.0, 0.0, 300.0);

    // Ring 1 - 6 titik radius 8m
    for(new i = 0; i < 6 && g_SmokeCount < MAX_SMOKE_OBJ; i++)
    {
        new Float:ang = float(i) * 60.0;
        g_SmokeObj[g_SmokeCount++] = CreateObject(OBJ_SMOKE_SMALL,
            x + 8.0 * floatsin(ang, degrees),
            y + 8.0 * floatcos(ang, degrees),
            z + 0.3, 0.0, 0.0, 0.0, 300.0);
    }

    // Ring 2 - 8 titik radius 18m
    for(new i = 0; i < 8 && g_SmokeCount < MAX_SMOKE_OBJ; i++)
    {
        new Float:ang = float(i) * 45.0;
        g_SmokeObj[g_SmokeCount++] = CreateObject(OBJ_SMOKE_LARGE,
            x + 18.0 * floatsin(ang, degrees),
            y + 18.0 * floatcos(ang, degrees),
            z + 0.5, 0.0, 0.0, 0.0, 300.0);
    }

    // Ring 3 - 8 titik radius 30m (elevated)
    for(new i = 0; i < 8 && g_SmokeCount < MAX_SMOKE_OBJ; i++)
    {
        new Float:ang = float(i) * 45.0 + 22.5;
        g_SmokeObj[g_SmokeCount++] = CreateObject(OBJ_SMOKE_SMALL,
            x + 30.0 * floatsin(ang, degrees),
            y + 30.0 * floatcos(ang, degrees),
            z + 2.5, 0.0, 0.0, 0.0, 300.0);
    }

    g_SmokeTimer = SetTimer("FlashBankClearSmoke", SMOKE_LIFETIME, false);
}

stock Float:FB_GetDist(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
    return VectorSize(x2 - x1, y2 - y1, z2 - z1);
}

// =============================================================
//   END OF FILTERSCRIPT - FlashBank v2.0 No Bug Edition
// =============================================================
