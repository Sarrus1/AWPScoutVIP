#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <clientprefs>
#pragma newdecls required
#pragma semicolon 1


Handle g_hScoutCookie;

public Plugin myinfo =
{
	name = "AWP and Scouts for VIP",
	author = "Sarrus",
	description = "Everyplayer get an AWP on spawn but VIP can choose to get a scout.",
	version = "1.0",
	url = "https://github.com/Sarrus1/"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_scout", CmdScout, ADMFLAG_CUSTOM6, "Switches between AWP and scout");
	g_hScoutCookie = RegClientCookie("ScoutCookie", "Cookie that defines wether or not you'll receive a scout instead of an AWP", CookieAccess_Protected);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
}

public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int userid, client;
	char sCookieValue[12];
	userid = event.GetInt("userid");
	client = GetClientOfUserId(userid);
	GetClientCookie(client, g_hScoutCookie, sCookieValue, sizeof(sCookieValue));
	int cookieValue = StringToInt(sCookieValue);
	if (cookieValue == 1)
	{
		if (GetPlayerWeaponSlot(client, 0) != -1)
			GivePlayerItem(client, "weapon_ssg08");
	}
	else
	{
		if (GetPlayerWeaponSlot(client, 0) != -1)
			GivePlayerItem(client, "weapon_awp");
	}
	return Plugin_Continue;
}

public Action CmdScout(int client, int args)
{
	if (AreClientCookiesCached(client))
	{
		char sCookieValue[12];
		GetClientCookie(client, g_hScoutCookie, sCookieValue, sizeof(sCookieValue));
		int cookieValue = StringToInt(sCookieValue);
		if (cookieValue == 0)
		{
			cookieValue = 1;
			PrintToChat(client, "You are now using the Scout.");
		}
		else
		{
			cookieValue = 0;
			PrintToChat(client, "You are now using the AWP.");
		}
		IntToString(cookieValue, sCookieValue, sizeof(sCookieValue));
		SetClientCookie(client, g_hScoutCookie, sCookieValue);
	}
	return Plugin_Handled;
}