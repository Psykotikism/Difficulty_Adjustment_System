// Difficulty Adjustment System
#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required
#define DAS_VERSION "13.5"
#define DAS_URL "https://forums.alliedmods.net/showthread.php?t=303117"

public Plugin myinfo =
{
	name = "Difficulty Adjustment System",
	author = "Psykotik (Crasher_3637)",
	description = "Adjusts difficulty based on the number of alive non-idle human survivors on the server.",
	version = DAS_VERSION,
	url = DAS_URL
};

bool g_bAdvanced;
bool g_bEasy;
bool g_bExpert;
bool g_bNormal;
bool g_bTimerOn;
ConVar g_cvDASAdvanced;
ConVar g_cvDASAnnounceDifficulty;
ConVar g_cvDASDifficulty;
ConVar g_cvDASDisabledGameModes;
ConVar g_cvDASEasy;
ConVar g_cvDASEnabledGameModes;
ConVar g_cvDASEnable;
ConVar g_cvDASExpert;
ConVar g_cvDASGameMode;
ConVar g_cvDASNormal;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "The Difficulty Adjustment System only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_cvDASAdvanced = CreateConVar("das_advanceddifficulty", "3", "Minimum players required for Advanced.");
	g_cvDASAnnounceDifficulty = CreateConVar("das_announcedifficulty", "1", "Announce the difficulty when it is changed?\n(0: OFF)\n(1: ON)");
	g_cvDASDifficulty = FindConVar("z_difficulty");
	g_cvDASDisabledGameModes = CreateConVar("das_disabledgamemodes", "versus,realismversus,survival,scavenge", "Disable the Difficulty Adjustment System in these game modes.\nGame mode limit: 64\nCharacter limit for each game mode: 32\n(Empty: None)\n(Not empty: Disabled in these game modes.)");
	g_cvDASEasy = CreateConVar("das_easydifficulty", "1", "Minimum players required for Easy.");
	g_cvDASEnabledGameModes = CreateConVar("das_enabledgamemodes", "coop,realism,mutation1,mutation12", "Enable the Difficulty Adjustment System in these game modes.\nGame mode limit: 64\nCharacter limit for each game mode: 32\n(Empty: None)\n(Not empty: Enabled in these game modes.)");
	g_cvDASEnable = CreateConVar("das_enableplugin", "1", "Enable the Difficulty Adjustment System?\n(0: OFF)\n(1: ON)");
	g_cvDASExpert = CreateConVar("das_expertdifficulty", "4", "Minimum players required for Expert.");
	g_cvDASGameMode = FindConVar("mp_gamemode");
	g_cvDASNormal = CreateConVar("das_normaldifficulty", "2", "Minimum players required for Normal.");
	CreateConVar("das_pluginversion", DAS_VERSION, "Difficulty Adjustment System version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	HookEvent("round_start", vStartTimer);
	HookEvent("round_end", vStopTimer);
	HookEvent("finale_win", vStopTimer);
	HookEvent("mission_lost", vStopTimer);
	HookEvent("map_transition", vStopTimer);
	g_cvDASDifficulty.AddChangeHook(vDASDifficultyCvar);
	AutoExecConfig(true, "difficulty_adjustment_system");
}

public void OnMapStart()
{
	g_bEasy = false;
	g_bNormal = false;
	g_bAdvanced = false;
	g_bExpert = false;
}

public void OnConfigsExecuted()
{
	vCreateConfigFiles();
	if (g_cvDASDifficulty != null)
	{
		char sDifficultyConfig[512];
		g_cvDASDifficulty.GetString(sDifficultyConfig, sizeof(sDifficultyConfig));
		Format(sDifficultyConfig, sizeof(sDifficultyConfig), "cfg/sourcemod/difficulty_adjustment_system/%s.cfg", sDifficultyConfig);
		if (FileExists(sDifficultyConfig, true))
		{
			strcopy(sDifficultyConfig, sizeof(sDifficultyConfig), sDifficultyConfig[4]);
			ServerCommand("exec \"%s\"", sDifficultyConfig);
		}
		else if (!FileExists(sDifficultyConfig, true))
		{
			vCreateConfigFile("cfg/sourcemod/", "difficulty_adjustment_system/", sDifficultyConfig, sDifficultyConfig);
		}
	}
}

public void OnMapEnd()
{
	g_bEasy = false;
	g_bNormal = false;
	g_bAdvanced = false;
	g_bExpert = false;
}

public void vStartTimer(Event event, const char[] name, bool dontBroadcast)
{
	g_bTimerOn = true;
	CreateTimer(1.0, tTimerUpdatePlayerCount, _, TIMER_REPEAT);
}

public void vStopTimer(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bTimerOn)
	{
		g_bTimerOn = false;
	}
}

public void vDASDifficultyCvar(ConVar convar, const char[] oldvalue, const char[] newvalue)
{
	char sDifficultyConfig[512];
	g_cvDASDifficulty.GetString(sDifficultyConfig, sizeof(sDifficultyConfig));
	Format(sDifficultyConfig, sizeof(sDifficultyConfig), "cfg/sourcemod/difficulty_adjustment_system/%s.cfg", sDifficultyConfig);
	if (FileExists(sDifficultyConfig, true))
	{
		strcopy(sDifficultyConfig, sizeof(sDifficultyConfig), sDifficultyConfig[4]);
		ServerCommand("exec \"%s\"", sDifficultyConfig);
	}
}

void vCreateConfigFiles()
{
	if (!g_cvDASEnable.BoolValue)
	{
		return;
	}
	CreateDirectory("cfg/sourcemod/difficulty_adjustment_system/", 511);
	char sDifficulty[32];
	for (int iDifficulty = 0; iDifficulty <= 3; iDifficulty++)
	{
		switch (iDifficulty)
		{
			case 0: sDifficulty = "easy";
			case 1: sDifficulty = "normal";
			case 2: sDifficulty = "hard";
			case 3: sDifficulty = "impossible";
		}
		vCreateConfigFile("cfg/sourcemod/", "difficulty_adjustment_system/", sDifficulty, sDifficulty);
	}
}

void vCreateConfigFile(const char[] filepath, const char[] folder, const char[] filename, const char[] label = "")
{
	char sConfigFilename[128];
	char sConfigLabel[128];
	File fFilename;
	Format(sConfigFilename, sizeof(sConfigFilename), "%s%s%s.cfg", filepath, folder, filename);
	if (FileExists(sConfigFilename))
	{
		return;
	}
	fFilename = OpenFile(sConfigFilename, "w+");
	strlen(label) > 0 ? strcopy(sConfigLabel, sizeof(sConfigLabel), label) : strcopy(sConfigLabel, sizeof(sConfigLabel), sConfigFilename);
	if (fFilename != null)
	{
		fFilename.WriteLine("// This config file was auto-generated by the Difficulty Adjustment System v%s (%s)", DAS_VERSION, DAS_URL);
		fFilename.WriteLine("");
		fFilename.WriteLine("");
		delete fFilename;
	}
}

public Action tTimerUpdatePlayerCount(Handle timer)
{
	if (!g_bTimerOn || g_cvDASDifficulty == null)
	{
		return Plugin_Stop;
	}
	if (!g_cvDASEnable.BoolValue || !bIsSystemValid())
	{
		return Plugin_Continue;
	}
	int iEasy = g_cvDASEasy.IntValue;
	int iNormal = g_cvDASNormal.IntValue;
	int iAdvanced = g_cvDASAdvanced.IntValue;
	int iExpert = g_cvDASExpert.IntValue;
	int iPlayerCount = iGetPlayerCount();
	if (!g_bEasy && (iPlayerCount == iEasy || (iPlayerCount > iEasy && iPlayerCount < iNormal)))
	{
		g_cvDASDifficulty.SetString("easy");
		g_bEasy = true;
		g_bNormal = false;
		g_bAdvanced = false;
		g_bExpert = false;
		if (g_bEasy && g_cvDASAnnounceDifficulty.BoolValue)
		{
			PrintToChatAll("\x04[DAS]\x01 Difficulty changed to\x03 Easy\x01.");
		}
	}
	else if (!g_bNormal && (iPlayerCount == iNormal || (iPlayerCount > iNormal && iPlayerCount < iAdvanced)))
	{
		g_cvDASDifficulty.SetString("normal");
		g_bEasy = false;
		g_bNormal = true;
		g_bAdvanced = false;
		g_bExpert = false;
		if (g_bNormal && g_cvDASAnnounceDifficulty.BoolValue)
		{
			PrintToChatAll("\x04[DAS]\x01 Difficulty changed to\x03 Normal\x01.");
		}
	}
	else if (!g_bAdvanced && (iPlayerCount == iAdvanced || (iPlayerCount > iAdvanced && iPlayerCount < iExpert)))
	{
		g_cvDASDifficulty.SetString("hard");
		g_bEasy = false;
		g_bNormal = false;
		g_bAdvanced = true;
		g_bExpert = false;
		if (g_bAdvanced && g_cvDASAnnounceDifficulty.BoolValue)
		{
			PrintToChatAll("\x04[DAS]\x01 Difficulty changed to\x03 Advanced\x01.");
		}
	}
	else if (!g_bExpert && (iPlayerCount == iExpert || iPlayerCount > iExpert))
	{
		g_cvDASDifficulty.SetString("impossible");
		g_bEasy = false;
		g_bNormal = false;
		g_bAdvanced = false;
		g_bExpert = true;
		if (g_bExpert && g_cvDASAnnounceDifficulty.BoolValue)
		{
			PrintToChatAll("\x04[DAS]\x01 Difficulty changed to\x03 Expert\x01.");
		}
	}
	return Plugin_Continue;
}

stock int iGetPlayerCount()
{
	int iPlayerCount = 0;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsHumanSurvivor(iPlayer))
		{
			iPlayerCount += 1;
		}
	}
	return iPlayerCount;
}

stock bool bHasIdlePlayer(int client)
{
	int iIdler = GetClientOfUserId(GetEntData(client, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID")));
	if (iIdler)
	{
		if (IsClientInGame(iIdler) && !IsFakeClient(iIdler) && (GetClientTeam(iIdler) != 2))
		{
			return true;
		}
	}
	return false;
}

stock bool bIsHumanSurvivor(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && !IsFakeClient(client) && !bHasIdlePlayer(client) && !bIsPlayerIdle(client);
}

stock bool bIsPlayerIdle(int client)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!IsClientConnected(iPlayer) || !IsClientInGame(iPlayer) || GetClientTeam(iPlayer) != 2 || !IsFakeClient(iPlayer) || !bHasIdlePlayer(iPlayer))
		{
			continue;
		}
		int iIdler = GetClientOfUserId(GetEntData(iPlayer, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID")));
		if (iIdler == client)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsSystemValid()
{
	char sGameMode[32];
	char sConVarModes[32];
	g_cvDASGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);
	g_cvDASEnabledGameModes.GetString(sConVarModes, sizeof(sConVarModes));
	if (strcmp(sConVarModes, ""))
	{
		Format(sConVarModes, sizeof(sConVarModes), ",%s,", sConVarModes);
		if (StrContains(sConVarModes, sGameMode, false) == -1)
		{
			return false;
		}
	}
	g_cvDASDisabledGameModes.GetString(sConVarModes, sizeof(sConVarModes));
	if (strcmp(sConVarModes, ""))
	{
		Format(sConVarModes, sizeof(sConVarModes), ",%s,", sConVarModes);
		if (StrContains(sConVarModes, sGameMode, false) != -1)
		{
			return false;
		}
	}
	return true;
}