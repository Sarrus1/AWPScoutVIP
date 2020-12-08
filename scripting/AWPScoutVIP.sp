#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <clientprefs>
#include <cstrike>
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
	for(int client = 1; client <= MaxClients; client++) 
	{
		if(client > 0 && client <= MaxClients && IsClientInGame(client)) 
			SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}


public void OnClientPutInServer(int client) 
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}


public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	StripAllWeapons(client);
	RequestFrame(SetWeapons, client);
}

public void SetWeapons(int client) 
{ 
if(IsValidClient(client) && IsPlayerAlive(client)) 
{ 
	char sCookieValue[12];
	GetClientCookie(client, g_hScoutCookie, sCookieValue, sizeof(sCookieValue));
	int cookieValue = StringToInt(sCookieValue);
	if ((cookieValue == 1) && (CheckCommandAccess(client, "sm_scout", ADMFLAG_CUSTOM6)))
	{
		GivePlayerItem(client, "weapon_ssg08");
		PrintCenterText(client, "HS ONLY ON");
	}
	else
	{
		GivePlayerItem(client, "weapon_awp");
	}
	if (GetClientTeam(client) == 2)
		GivePlayerItem(client, "weapon_knife_t");
	else
		GivePlayerItem(client, "weapon_knife");
}
return;
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
			PrintCenterText(client, "HS ONLY ON");
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

stock void StripAllWeapons(int client) 
{
	if (!IsValidClient(client, false))
		return;

	int weapon;
	for (int i; i < 4; i++) {

		if ((weapon = GetPlayerWeaponSlot(client, i)) != -1) {

			if (IsValidEntity(weapon)) {

				RemovePlayerItem(client, weapon);
				AcceptEntityInput(weapon, "Kill");
			}
		}
	}
}

stock bool IsValidClient(int client, bool noBots=true) 
{
	if (client < 1 || client > MaxClients)
		return false;

	if (!IsClientInGame(client))
		return false;

	if (!IsClientConnected(client))
		return false;

	if (noBots)
		if (IsFakeClient(client))
			return false;

	if (IsClientSourceTV(client))
		return false;

	return true;

}


public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(IsValidClient(victim)) 
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		if(StrEqual(sWeapon, "weapon_ssg08", false))
		{
			if (damagetype & CS_DMG_HEADSHOT)
				return Plugin_Continue;
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}