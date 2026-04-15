#if defined _bitcoin_included
    #endinput
#endif
#define _bitcoin_included

// Dialog IDs
#define DLG_BTC_MAIN   8001
#define DLG_BTC_BUY    8002
#define DLG_BTC_SELL   8003

// Config
#define BTC_STOCK_MAX 100
#define BTC_PRICE_MIN 300000
#define BTC_PRICE_MAX 3000000
#define BTC_UPDATE_INTERVAL_MS 60000   // 1 menit
#define BTC_RESET_INTERVAL_MS 600000   // 10 menit
#define BTC_MAX_STEP 400

// Data arrays
new BitcoinPrice = BTC_PRICE_MIN;
new PlayerBitcoin[MAX_PLAYERS];
new BitcoinStock[MAX_PLAYERS];

// Forwards (agar aman)
forward Bitcoin_Init();
forward Bitcoin_PlayerConnect(playerid);
forward Bitcoin_PlayerDisconnect(playerid);
forward Bitcoin_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
forward Bitcoin_UpdatePriceTimer();
forward Bitcoin_ResetStockTimer();

// ------------------------------------------------------------------
// Random tier price
// ------------------------------------------------------------------
stock GetRandomBitcoinPrice()
{
    new r = random(100); // 0..99
    if (r < 12) return 5000;
    if (r < 45) return 2500;
    if (r < 75) return 1500;
    return 160;
}

// ------------------------------------------------------------------
// Init & hooks (dipanggil dari gm)
// ------------------------------------------------------------------
stock Bitcoin_Init()
{
    new i;
    for (i = 0; i < MAX_PLAYERS; i++)
    {
        PlayerBitcoin[i] = 0;
        BitcoinStock[i]  = BTC_STOCK_MAX;
    }

    SetTimer("Bitcoin_UpdatePriceTimer", BTC_UPDATE_INTERVAL_MS, true);
    SetTimer("Bitcoin_ResetStockTimer",  BTC_RESET_INTERVAL_MS,  true);

    return 1;
}

stock Bitcoin_GetPath(playerid, path[], len)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof name);
    format(path, len, "btc/%s.ini", name);
}

stock Bitcoin_SavePlayer(playerid)
{
    new path[64];
    Bitcoin_GetPath(playerid, path, sizeof path);

    if (!dini_Exists(path))
        dini_Create(path);

    dini_IntSet(path, "Bitcoin", PlayerBitcoin[playerid]);
    dini_IntSet(path, "Stock",   BitcoinStock[playerid]);
    return 1;
}

stock Bitcoin_LoadPlayer(playerid)
{
    new path[64];
    Bitcoin_GetPath(playerid, path, sizeof path);

    if (dini_Exists(path))
    {
        PlayerBitcoin[playerid] = dini_Int(path, "Bitcoin");
        BitcoinStock[playerid]  = dini_Int(path, "Stock");
        if (BitcoinStock[playerid] <= 0)
            BitcoinStock[playerid] = BTC_STOCK_MAX;
    }
    else
    {
        PlayerBitcoin[playerid] = 0;
        BitcoinStock[playerid]  = BTC_STOCK_MAX;
    }
    return 1;
}

stock Bitcoin_PlayerConnect(playerid)
{
    Bitcoin_LoadPlayer(playerid);
    return 1;
}

stock Bitcoin_PlayerDisconnect(playerid)
{
    Bitcoin_SavePlayer(playerid);
    return 1;
}

// ------------------------------------------------------------------
// Dialog handler (dipanggil dari gm OnDialogResponse)
// ------------------------------------------------------------------
stock Bitcoin_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == DLG_BTC_MAIN)
    {
        if (!response) return 1;

        if (listitem == 0)
        {
            ShowPlayerDialog(playerid, DLG_BTC_BUY, DIALOG_STYLE_INPUT,
                "Buy BTC",
                "Masukkan jumlah BTC (1-100):",
                "Beli", "Batal");
        }
        else if (listitem == 1)
        {
            ShowPlayerDialog(playerid, DLG_BTC_SELL, DIALOG_STYLE_INPUT,
                "Sell BTC",
                "Masukkan jumlah BTC yang ingin dijual:",
                "Jual", "Batal");
        }
        return 1;
    }

    if (dialogid == DLG_BTC_BUY)
    {
        if (!response) return 1;

        new amount;
        if (sscanf(inputtext, "i", amount))
        {
            SendClientMessage(playerid, -1, "{FF0000}[BTC] Jumlah invalid.");
            return 1;
        }
        return DoBuyBTC(playerid, amount);
    }

    if (dialogid == DLG_BTC_SELL)
    {
        if (!response) return 1;

        new amount;
        if (sscanf(inputtext, "i", amount))
        {
            SendClientMessage(playerid, -1, "{FF0000}[BTC] Jumlah invalid.");
            return 1;
        }
        return DoSellBTC(playerid, amount);
    }

    return 0;
}

// ------------------------------------------------------------------
// Timer: update price tiap 10 menit (transisi halus ke target)
// ------------------------------------------------------------------
public Bitcoin_UpdatePriceTimer()
{
    new old = BitcoinPrice;
    new target = GetRandomBitcoinPrice();

    new diff = target - BitcoinPrice;
    if (diff > BTC_MAX_STEP) diff = BTC_MAX_STEP;
    else if (diff < -BTC_MAX_STEP) diff = -BTC_MAX_STEP;

    BitcoinPrice += diff;

    if (BitcoinPrice < BTC_PRICE_MIN) BitcoinPrice = BTC_PRICE_MIN;
    if (BitcoinPrice > BTC_PRICE_MAX) BitcoinPrice = BTC_PRICE_MAX;

    new buf[128];
    if (BitcoinPrice > old)
        format(buf, sizeof buf, "{00FF00}[BTC] Harga naik: %d -> %d", old, BitcoinPrice);
    else if (BitcoinPrice < old)
        format(buf, sizeof buf, "{FF0000}[BTC] Harga turun: %d -> %d", old, BitcoinPrice);
    else
        format(buf, sizeof buf, "{FFFF00}[BTC] Harga tetap: %d", BitcoinPrice);

    // kirim pesan via buffer (tidak langsung format ke SendClientMessageToAll)
    SendClientMessageToAll(-1, buf);
    return 1;
}

// ------------------------------------------------------------------
// Timer: reset stock per player setiap 1 jam
// ------------------------------------------------------------------
public Bitcoin_ResetStockTimer()
{
    new i;
    new notify[96];
    for (i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i))
        {
            BitcoinStock[i] = BTC_STOCK_MAX;
            format(notify, sizeof notify, "{00CCFF}[BTC] Stock BTC kamu telah direset menjadi %d.", BTC_STOCK_MAX);
            SendClientMessage(i, -1, notify);
        }
    }
    return 1;
}

// ------------------------------------------------------------------
// Buy / Sell logic (mengurangi/menambah uang sesuai price * amount)
// ------------------------------------------------------------------
stock DoBuyBTC(playerid, amount)
{
    if (!IsPlayerConnected(playerid)) return 0;

    if (amount < 1 || amount > BTC_STOCK_MAX)
    {
        SendClientMessage(playerid, -1, "{FF0000}[BTC] Masukkan jumlah antara 1 sampai 100.");
        return 1;
    }

    if (amount > BitcoinStock[playerid])
    {
        SendClientMessage(playerid, -1, "{FF0000}[BTC] Stock BTC-mu tidak cukup.");
        return 1;
    }

    new pricePer = BitcoinPrice;
    new total = pricePer * amount;

    // gunakan sistem uang bawaan gamemode: GetPlayerMoney / GivePlayerMoneyEx
    if (GetPlayerMoney(playerid) < total)
    {
        SendClientMessage(playerid, -1, "{FF0000}[BTC] Uangmu tidak cukup untuk pembelian ini.");
        return 1;
    }

    // kurangi uang player
    GivePlayerMoneyEx(playerid, -total, "Beli BTC");

    // update btc & stock
    PlayerBitcoin[playerid] += amount;
    BitcoinStock[playerid] -= amount;

    // kirim info rapi ke player (single literal di format)
    new out[256];
    format(out, sizeof out,
        "{00FF00}[BTC] Pembelian Berhasil!\n{FFFFFF}Jumlah: %d BTC\n{FFFFFF}Harga per BTC: $%d\n{FFFFFF}Total Dibayar: $%d\n{FFFFFF}Sisa Stock: %d",
        amount, pricePer, total, BitcoinStock[playerid]);
    SendClientMessage(playerid, -1, out);

    // broadcast ringkas di langit (pakai buffer)
    new name[MAX_PLAYER_NAME], sky[128];
    GetPlayerName(playerid, name, sizeof name);
    format(sky, sizeof sky, "{00FF00}[BTC] %s membeli %d BTC (harga $%d).", name, amount, pricePer);
    SendClientMessageToAll(-1, sky);

    return 1;
}

stock DoSellBTC(playerid, amount)
{
    if (!IsPlayerConnected(playerid)) return 0;

    if (amount < 1)
    {
        SendClientMessage(playerid, -1, "{FF0000}[BTC] Jumlah invalid.");
        return 1;
    }

    if (PlayerBitcoin[playerid] < amount)
    {
        SendClientMessage(playerid, -1, "{FF0000}[BTC] BTC-mu tidak cukup untuk menjual.");
        return 1;
    }

    new pricePer = BitcoinPrice;
    new total = pricePer * amount;

    // kurangi BTC, tambahkan uang player
    PlayerBitcoin[playerid] -= amount;
    GivePlayerMoneyEx(playerid, total, "Jual BTC");

    // kirim info rapi ke player
    new out2[256];
    format(out2, sizeof out2,
        "{00CCFF}[BTC] Penjualan Berhasil!\n{FFFFFF}Jumlah: %d BTC\n{FFFFFF}Harga per BTC: $%d\n{FFFFFF}Total Diterima: $%d",
        amount, pricePer, total);
    SendClientMessage(playerid, -1, out2);

    // broadcast ringkas di langit
    new name2[MAX_PLAYER_NAME], sky2[128];
    GetPlayerName(playerid, name2, sizeof name2);
    format(sky2, sizeof sky2, "{00CCFF}[BTC] %s menjual %d BTC (harga $%d).", name2, amount, pricePer);
    SendClientMessageToAll(-1, sky2);

    return 1;
}

// ------------------------------------------------------------------
// Commands
// ------------------------------------------------------------------
CMD:btc(playerid, params[])
{
    new info[256];
    format(info, sizeof info,
        "Harga 1btc/$: $%d\nStock: %d\nBTC-mu: %d",
        BitcoinPrice, BitcoinStock[playerid], PlayerBitcoin[playerid]);

    // Untuk DIALOG_STYLE_LIST, daftar item harus di-line separated
    new listtext[256];
    format(listtext, sizeof listtext, "Buy\nSell\nClose");

    ShowPlayerDialog(playerid, DLG_BTC_MAIN, DIALOG_STYLE_LIST,
        "Bitcoin Market", info, listtext, "Close");

    return 1;
}

CMD:buybtc(playerid, params[])
{
    new amount;
    if (sscanf(params, "i", amount))
    {
        SendClientMessage(playerid, -1, "{FFFF00}Gunakan: {FFFFFF}/buybtc [jumlah]");
        return 1;
    }
    return DoBuyBTC(playerid, amount);
}

CMD:sellbtc(playerid, params[])
{
    new amount;
    if (sscanf(params, "i", amount))
    {
        SendClientMessage(playerid, -1, "{FFFF00}Gunakan: {FFFFFF}/sellbtc [jumlah]");
        return 1;
    }
    return DoSellBTC(playerid, amount);
}

// EOF