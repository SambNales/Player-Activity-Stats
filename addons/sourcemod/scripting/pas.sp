#include sourcemod
#include geoip

#define PLUGININFO

#define	PlugAuth "nullent?"
#define	PlugUrl  "discord.gg/ChTyPUG"
#define	PlugName "[PAStat] Player Activity Statistics"
#define	PlugDesc "Records detailed statistics of player activity"
#define PlugVer  "2.1"

#include std

char Querys[][] =
{
	"CREATE TABLE IF NOT EXISTS `player_analytics` (`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY, `server_ip` VARCHAR(32) NOT NULL, `server_name` VARCHAR(32) NOT NULL,`name` VARCHAR(32), `auth` VARCHAR(32), `connect_time` INT NOT NULL, `connect_date` DATE NOT NULL, `numplayers` INT NOT NULL, `map` VARCHAR(64) NOT NULL, `duration` INT NOT NULL, `ip` VARCHAR(32) NOT NULL, `country` varchar(45) NOT NULL, `country_code` VARCHAR(3) NOT NULL, `country_code3` VARCHAR(4) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
	"DELETE FROM `player_analytics` WHERE `connect_time` = 0",
	"INSERT INTO `player_analytics` (`server_ip`, `server_name`, `name`, `auth`, `connect_time`, `connect_date`, `numplayers`, `map`, `duration`, `ip`, `country`, `country_code`, `country_code3`) VALUES ('%s', '%s', '%s', '%s', %i, '%s', %i, '%s', %i, '%s', '%s', '%s', '%s')",
	"SELECT `server_ip` FROM `player_analytics` WHERE `connect_time` BETWEEN %i AND %i GROUP BY `server_ip`"
};

enum nQuerys
{
	pTable = 0,
	pClearInvalides, // ??
	pWriteLine,
	pServerStatus
};

#define BUILD(%0,%1) BuildPath(Path_SM, %0, sizeof(%0), %1)
#define ZERO 0

Database dBase;

bool bErase;

char
	cServer[32],
	cHost[32],
	cCmd[32],
	cConName[32],
	cMap[32],
	cMenuTitle[PMP], 
	cMenuItem_Profile[PMP],
	cMenuTitle_Profile[PMP],
	szBack[6] = "back",
	cTimeFormat[32];

int
	iTopCount,
	iMinTime,
	iDelPending,
	iCacheTime;

#define SIZE 32
enum struct PlayerAnalytics
{
	int iConnectTime;
	//int iAccountId;
	char cSteam[32];
	char cName[MAX_TARGET_LENGTH];
	char cIP[32];
	char cCountry[32];
}

PlayerAnalytics
	pPlayer[MPL];

GlobalForward 
	gfClientLoaded,
	gfDataLoaded;

#include "pas/api.sp"
#include "pas/caching.sp"
#include "pas/menu.sp"
#include "pas/requests.sp"

bool PluginStarted(bool update = false)
{
	static bool state;

	if(update)
		state = !state;
	
	return state;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	eGame = GetEngineVersion();
	
  	CreateAPI();
	RegPluginLibrary("pas");
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("pas.phrases.txt");
	ReadConfig();

	RegConsoleCmd(cCmd, cmdPAS);

	Database.Connect(OnBaseConnected, cConName);
}

void ReadConfig()
{
	char ConfigPath[PLATFORM_MAX_PATH];
	BUILD(ConfigPath, "configs/pas/config.ini");

	SMCParser smParser = new SMCParser();
	smParser.OnKeyValue = OnKeyValueRead;
	smParser.OnEnd = OnReadEnd;

	if(!FileExists(ConfigPath))
		SetFailState("Where is my config???: %s", ConfigPath);

	int iLine;
	SMCError smError = smParser.ParseFile(ConfigPath, iLine);

	if(smError != SMCError_Okay)
	{
		char sError[PMP];
		SMC_GetErrorString(smError, SZ(sError));
		LogError("Error on parse file: | %s | on | %d | line", ConfigPath, iLine);
	}
}

SMCResult OnKeyValueRead(SMCParser SMC, const char[] sKey, const char[] sValue, bool bKey_quotes, bool bValue_quotes)
{
	if (!sKey[0] || !sValue[0])
		return SMCParse_Continue;

	if(!strcmp(sKey, "CmdName"))
		strcopy(SZ(cCmd), sValue);
    
	else if(!strcmp(sKey, "DatabaseConnect"))
		strcopy(SZ(cConName), sValue);
	
	else if(!strcmp(sKey, "MainMenuTitle"))
		strcopy(SZ(cMenuTitle), sValue);
		
	else if(!strcmp(sKey, "MenuItem_Profile"))
		strcopy(SZ(cMenuItem_Profile), sValue);
	
	else if(!strcmp(sKey, "MenuTitle_Profile"))
		strcopy(SZ(cMenuTitle_Profile), sValue);
		
	else if(!strcmp(sKey, "ServerName"))
		strcopy(SZ(cServer), sValue);
    
	else if(!strcmp(sKey, "EraseServers"))
		bErase = view_as<bool>(StringToInt(sValue));
    
	else if(!strcmp(sKey, "DeletePending"))
		iDelPending = StringToInt(sValue);
    
	else if(!strcmp(sKey, "TopCount"))
		iTopCount = StringToInt(sValue);

	else if(!strcmp(sKey, "MinTime"))
		iMinTime = StringToInt(sValue);
	
	else if(!strcmp(sKey, "CachingTime"))
		iCacheTime = StringToInt(sValue);
	
	else if(!strcmp(sKey, "InProfile_TimeFormat"))
		strcopy(SZ(cTimeFormat), sValue);

	return SMCParse_Continue;
}

public void OnReadEnd(SMCParser smc, bool halted, bool failed)
{
	delete smc;
}

public void OnMapStart()
{
	ReadConfig();

	cHost = GetIP(FindConVar("hostip").IntValue);
	GetCurrentMap(SZ(cMap));

	if(!dBase)
		return;
	
	OnBaseNotNull();
}

public void OnPluginEnd()
{
	if(PluginStarted())
		PluginStarted(true);
}

public void OnBaseConnected(Database hDB, const char[] error, any data)
{
	//PrintToServer("cConName: %s", cConName);
	if(!hDB || error[ZERO])
		SetFailState("[PA] Failed OnBaseConnected << %s", error);
	
	dBase = hDB;
	dBase.SetCharset("utf8mb4");

	char szQuery[512];
	dBase.Format(SZ(szQuery), Querys[pTable]);
	dBase.Query(queryCallBack, szQuery);
}

public void OnClientPutInServer(int iClient)
{
	pPlayer[iClient].iConnectTime = 0;

	if(!dBase || IsFailClient(iClient) || !GetClientAuthId(iClient, AuthId_Steam2, pPlayer[iClient].cSteam, sizeof(pPlayer[].cSteam)))
		return;

	pPlayer[iClient].iConnectTime = GetTime();
	if(!pPlayer[iClient].iConnectTime)
		return;

	Cache nCache;
	nCache.Build(pPlayer[iClient].cSteam);
	if(!nCache.IsCachingExists())
		nCache.CreateCache();
	
	if(nCache.CacheOutdated())
	{
		nCache.Destroy();
		SendBaseTransactions(iClient);
	}	
	else
	{
		nCache.LoadFromCache(iClient);
		nCache.Destroy();
		ClientLoaded(iClient);
	}
	
	GetClientIP(iClient, pPlayer[iClient].cIP, sizeof(pPlayer[].cIP));
	GeoipCountry(pPlayer[iClient].cIP, pPlayer[iClient].cCountry, sizeof(pPlayer[].cCountry));
	
	TrimString(pPlayer[iClient].cCountry);
	if(IsNullString(pPlayer[iClient].cCountry))
		pPlayer[iClient].cCountry = "Russian Federation";
	
}

public void OnClientDisconnect(int iClient)
{
	if(IsFailClient(iClient) || !pPlayer[iClient].iConnectTime || !dBase)
		return;
	
	int iTime = GetTime();
	UpdateDatabase(iClient, iTime);
}

void UpdateDatabase(int iClient, int &iTime)
{
	int iClientCount;
	iClientCount = GetClientCount(true);

	int iDuration;
	iDuration = iTime - pPlayer[iClient].iConnectTime;

	if(iDuration < iMinTime)
		return;
	
	char sBuffer[32];
	GetClientName(iClient, SZ(sBuffer));
	dBase.Escape(sBuffer, pPlayer[iClient].cName, sizeof(pPlayer[].cName));

	char cConDate[32];
	FormatTime(SZ(cConDate), "%Y-%m-%d", pPlayer[iClient].iConnectTime);

	char sCC[3], sCC3[4];
	if(GeoipCode2(pPlayer[iClient].cIP, sCC))
		GeoipCode3(pPlayer[iClient].cIP, sCC3);
		
	if(!sCC[0])
	{
		sCC = "RU";
		sCC3 = "RUS";
	}

	char szQuery[512];
	dBase.Format(SZ(szQuery), 
		Querys[pWriteLine], cHost, cServer, pPlayer[iClient].cName, 
		pPlayer[iClient].cSteam,pPlayer[iClient].iConnectTime, cConDate, 
		iClientCount, cMap, iDuration, pPlayer[iClient].cIP, pPlayer[iClient].cCountry, 
		sCC, sCC3
	);

	dBase.Query(queryBuffer, szQuery, _, DBPrio_High);
}

public void queryCallBack(Database hDB, DBResultSet hResult, const char[] error, any data)
{
	if(!hResult || error[ZERO])
	{
		LogError("[PA] Failed on apiCQuerysCallBack() << %s", error);
		return;
	}

	if(!PluginStarted())
		PluginStarted(true);

	OnStarted();
	OnBaseNotNull();

	FORITER(i, 1, MaxClients)
	{
		if(!IsClientInGame(i))
			continue;
			
		OnClientPutInServer(i);
	}
}

public void queryBuffer(Database hDB, DBResultSet hResult, const char[] error, any data)
{
	if(!hResult || error[ZERO])
		LogError("[PA] Failed on queryBuffer() << %s", error);

}

Action cmdPAS(int iClient, int args)
{
	if(!iClient || !IsClientInGame(iClient) /*|| mSend(u) != Plugin_Continue*/)
		return Plugin_Handled;

	if(MenuMainSending(iClient) != Plugin_Handled)
		pas_MainMenu(iClient).Display(iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

void GetStringTime(int time, char[] buffer, int maxlength)
{
	static int dims[] = {60, 60, 24, 30, 365, cellmax};
	static char sign[][] = {"с", "м", "ч", "д", "м", "г"};
	static char form[][] = {"%02i%s%s", "%02i%s %s", "%i%s %s"};
	buffer[ZERO] = EOS;
	int i = ZERO, f = -1;
	bool cond = false;
	while (!cond)
	{
		if (f++ == 1)
			cond = true;
		do
		{
			Format(buffer, maxlength, form[f], time % dims[i], sign[i], buffer);
			if (time /= dims[i++], time == ZERO)
				return;  
		} 
		while (cond);
	}
}

char GetIP(int iHostIP)
{
	char cIP[32];
	FormatEx(cIP, sizeof(cIP), "%d.%d.%d.%d:%d", ((iHostIP & 0xFF000000) >> 24) & 0xFF, ((iHostIP & 0x00FF0000) >> 16) & 0xFF, ((iHostIP & 0x0000FF00) >>  8) & 0xFF, ((iHostIP & 0x000000FF) >>  ZERO) & 0xFF, GetConVarInt(FindConVar("hostport")));
	return cIP;
}

bool IsFailClient(int iClient)
{
	return IsFakeClient(iClient) || IsClientSourceTV(iClient);
}