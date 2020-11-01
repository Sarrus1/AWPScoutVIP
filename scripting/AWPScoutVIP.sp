#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <clientprefs>
#pragma newdecls required
#pragma semicolon 1


Handle g_hScoutCookie;
int g_iHealth, g_Armor;

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
	HookEvent("player_hurt", OnPlayerHurt, EventHookMode_Pre);

	
	g_iHealth = FindSendPropInfo("CCSPlayer", "m_iHealth");
	if (g_iHealth == -1)
	{
		SetFailState("[Headshot Only] Error - Unable to get offset for CSSPlayer::m_iHealth");
	}

	g_Armor = FindSendPropInfo("CCSPlayer", "m_ArmorValue");
	if (g_Armor == -1)
	{
		SetFailState("[Headshot Only] Error - Unable to get offset for CSSPlayer::m_ArmorValue");
	}
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
	if (cookieValue == 1)
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


public Action OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int hitgroup = GetEventInt(event, "hitgroup");
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int dhealth = GetEventInt(event, "dmg_health");
	int darmor = GetEventInt(event, "dmg_armor");
	int health = GetEventInt(event, "health");
	int armor = GetEventInt(event, "armor");
	char weapon[128];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	if (StrEqual(weapon, "ssg08", false))
	{
		if (hitgroup == 1)
		{
			return Plugin_Continue;
		}
		else if (attacker != victim && victim != 0 && attacker != 0)
		{
			PrintToChat(attacker, "You can only headshot somebody with the scout!");
			if (dhealth > 0)
			{
				SetEntData(victim, g_iHealth, (health + dhealth), 4, true);
			}
			if (darmor > 0)
			{
				SetEntData(victim, g_Armor, (armor + darmor), 4, true);
			}
		}
	}
	return Plugin_Continue;
}