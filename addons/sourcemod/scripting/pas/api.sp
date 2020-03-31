enum struct pAPI
{
   ArrayList aMenuItems;
   ArrayList aServers;
}

pAPI API;

enum TYPE_STAT
{
   eServer = 0,
   eGlobal
};

#define TYPES_STAT 2

enum struct eSTAT
{
   int iPlayTime[MPL];
   int iPlayerCon[MPL];
   int iPlayerFirst[MPL];

   int iMaxPlayers; 
   int iMaxCon;
   int iPlayedTime;

   ArrayList aOnline;
   ArrayList aConnections;
}

eSTAT Stat[TYPES_STAT];


void CreateAPI()
{
   gfClientLoaded = new GlobalForward("pas_OnClientSuccess", ET_Ignore, Param_Cell);
   gfDataLoaded = new GlobalForward("pas_OnPASDataLoaded", ET_Ignore);
   
   CreateNative("pas_GetPlayerTime", Native_GetPlayerMaxTime);
   CreateNative("pas_GetPlayerConnections", Native_GetPlayerCon);
   CreateNative("pas_GetPlayerFirstConnection", Native_GetPlayerFirstCon);

   CreateNative("pas_GetOnlineTOP", Native_GetOnlineTOP);
   CreateNative("pas_GetConnectionsTOP", Native_GetConTOP);

   CreateNative("pas_GetMaxPlayers", Native_GetMaxPlayers);
   CreateNative("pas_GetMaxConnections", Native_GetMaxConnections);
   CreateNative("pas_GetMaxTime", Native_GetMaxTime);

   CreateNative("pas_ResetTable", Native_ResetTable);
   CreateNative("pas_ResetPlayer", Native_ResetPlayer);
   CreateNative("pas_ResetServer", Native_ResetServer);
   
   CreateNative("pas_GetServerList", Native_GetServerList);

   CreateNative("pas_GetServerAddress", Native_GetServerAddress);
   
   CreateNative("pas_RegMenuItem", Native_RegMenuItem);
   CreateNative("pas_DeleteMenuItem", Native_DeleteMenuItem);

   CreateNative("pas_SendMainMenu", Native_SendMainMenu);

   CreateNative("pas_TimeToChar", Native_TimeToChar);
   CreateNative("pas_SendMsg", Native_SendMsg);

   CreateNative("pas_PluginStarted", Native_State);

   API.aServers = new ArrayList(32, 0);
   API.aMenuItems = new ArrayList(32, 0);

   for(int i; i < TYPES_STAT; i++)
   {
      Stat[i].aOnline = new ArrayList(PMP, 0);
      Stat[i].aConnections = new ArrayList(PMP, 0);
   }
}

public int Native_GetPlayerMaxTime(Handle hPlugin, int iArgs)
{
   int iClient = GetNativeCell(1);
   if(!IsClientInGame(iClient) || IsFailClient(iClient))
      return ThrowNativeError(SP_ERROR_INDEX, "Invalid client index: %i", iClient);
   
   return Stat[GetNativeCell(2)].iPlayTime[iClient];
}

public int Native_GetPlayerCon(Handle hPlugin, int iArgs)
{
   int iClient = GetNativeCell(1);
   if(!IsClientInGame(iClient) || IsFailClient(iClient))
      return ThrowNativeError(SP_ERROR_INDEX, "Invalid client index: %i", iClient);
   
   return Stat[GetNativeCell(2)].iPlayerCon[iClient];
}

public int Native_GetPlayerFirstCon(Handle hPlugin, int iArgs)
{
   int iClient = GetNativeCell(1);
   if(!IsClientInGame(iClient) || IsFailClient(iClient))
      return ThrowNativeError(SP_ERROR_INDEX, "Invalid client index: %i", iClient);
   
   return Stat[GetNativeCell(2)].iPlayerFirst[iClient];
}

public int Native_GetOnlineTOP(Handle hPlugin, int iArgs)
{
   return view_as<int>(Stat[GetNativeCell(1)].aOnline.Clone());
}

public int Native_State(Handle hPlugin, int iArgs)
{
   return view_as<int>(PluginStarted());
}

public int Native_GetConTOP(Handle hPlugin, int iArgs)
{
   return view_as<int>(Stat[GetNativeCell(1)].aConnections.Clone());
}

public int Native_GetMaxPlayers(Handle hPlugin, int iArgs)
{
   return Stat[GetNativeCell(1)].iMaxPlayers;
}

public int Native_GetMaxConnections(Handle hPlugin, int iArgs)
{
   return Stat[GetNativeCell(1)].iMaxCon;
}

public int Native_GetMaxTime(Handle hPlugin, int iArgs)
{
   return Stat[GetNativeCell(1)].iPlayedTime;
}

public int Native_GetServerList(Handle hPlugin, int iArgs)
{
   return view_as<int>(API.aServers.Clone());
}

public int Native_ResetTable(Handle hPlugin, int iArgs)
{
   char szQuery[512];
	dBase.Format(SZ(szQuery), "DELETE FROM `player_analytics`");
	dBase.Query(queryBuffer, szQuery, -1);
   
   return 1;
}

public int Native_ResetPlayer(Handle hPlugin, int iArgs)
{
   int iClient = GetNativeCell(1);
   if(!IsClientInGame(iClient) || IsFailClient(iClient))
      return ThrowNativeError(SP_ERROR_INDEX, "Invalid client index: %i", iClient);

   char szQuery[512];
	dBase.Format(SZ(szQuery), "DELETE FROM `player_analytics` WHERE `auth` = '%s'", pPlayer[iClient].cSteam);
	dBase.Query(queryBuffer, szQuery, -1);
   
   return 1;
}

public int Native_ResetServer(Handle hPlugin, int iArgs)
{
   char chServer[32];
   GetNativeString(1, SZ(chServer));

   TrimString(chServer);
   if(!chServer[0] || API.aServers.FindString(chServer) == -1)
      return ThrowNativeError(SP_ERROR_PARAM, "Invalid server address: %s", chServer);

   char szQuery[512];
	dBase.Format(SZ(szQuery), "DELETE FROM `player_analytics` WHERE `server_ip` = '%s'", chServer);
	dBase.Query(queryBuffer, szQuery, -1);
   
   return 1;
}

/*public int Native_GetCountPlayers(Handle hPlugin, int iArgs)
{
   char cStart[32], cEnd[32];

   GetNativeString(1, SZ(cStart));
   GetNativeString(2, SZ(cEnd));
   Function hFunc = GetNativeFunction(3);
   if(!hFunc)
      return ThrowNativeError(SP_ERROR_NOT_RUNNABLE, "Invalid function");

   DataPack hData = new DataPack();
   hData.WriteCell(view_as<int>(hPlugin));
   hData.WriteFunction(hFunc);
   hData.WriteCell(GetNativeCell(4));

   char szQuery[512];
	dBase.Format(SZ(szQuery), apiQuerys[qPlayersCount], cStart, cEnd);
	dBase.Query(apiGetCount, szQuery, hData, DBPrio_High);
   
   return 1;
}

public int Native_GetCountConnections(Handle hPlugin, int iArgs)
{
   char cStart[32], cEnd[32];

   GetNativeString(1, SZ(cStart));
   GetNativeString(2, SZ(cEnd));
   Function hFunc = GetNativeFunction(3);
   if(!hFunc)
      return ThrowNativeError(SP_ERROR_NOT_RUNNABLE, "Invalid function");

   DataPack hData = new DataPack();
   hData.WriteCell(view_as<int>(hPlugin));
   hData.WriteFunction(hFunc);
   hData.WriteCell(GetNativeCell(4));

   char szQuery[512];
	dBase.Format(SZ(szQuery), apiQuerys[qConnectionsCount], cStart, cEnd);
	dBase.Query(apiGetCount, szQuery, hData, DBPrio_High);

   return 1;
}
*/

public int Native_RegMenuItem(Handle hPlugin, int iArgs)
{
   char cTrigger[32];

   GetNativeString(1, SZ(cTrigger));
   
   if(API.aMenuItems.FindString(cTrigger) != -1)
      return 0;

   DataPack hData = new DataPack();
   
   hData.WriteCell(hPlugin);
   hData.WriteFunction(GetNativeFunction(2));
   
   API.aMenuItems.PushString(cTrigger);
   API.aMenuItems.Push(hData);
   
   return 1;
}

public int Native_DeleteMenuItem(Handle hPlugin, int iArgs)
{
   char cTrigger[32];

   GetNativeString(1, SZ(cTrigger));
   int iPos = API.aMenuItems.FindString(cTrigger);

   if(iPos == -1)
      return 0;
   
   API.aMenuItems.Erase(iPos);

   DataPack data = API.aMenuItems.Get(iPos);
   data.Close();

   API.aMenuItems.Erase(iPos);

   return 1;
}

public int Native_GetServerAddress(Handle hPlugin, int iArgs)
{
   SetNativeString(1, SZ(cHost));
   SetNativeCellRef(2, sizeof cHost);

   return 1;
}

public int Native_SendMainMenu(Handle hMenu, int iArgs)
{
   int iClient = GetNativeCell(1);
   if(!iClient || !IsClientInGame(iClient) || IsFailClient(iClient))
      return ThrowNativeError(SP_ERROR_INDEX, "Invalid client index: %i", iClient);
   
   if(MenuMainSending(iClient) != Plugin_Handled)
   {
      pas_MainMenu(iClient).Display(iClient, MENU_TIME_FOREVER);
      return 1;
   }

   return 0;
}

public int Native_TimeToChar(Handle hPlugin, int iArgs)
{
   int iTime = GetNativeCell(1);
   
   char szBuffer[64];
   GetStringTime(iTime, SZ(szBuffer));

   SetNativeString(2, SZ(szBuffer));
   SetNativeCellRef(3, sizeof szBuffer);

   return 1;
}

public int Native_SendMsg(Handle hPlugin, int iArgs)
{
   char szBuffer[PMP];
   FormatNativeString(0, 2, 3, sizeof(szBuffer), _, szBuffer);
   if(szBuffer[0])
      SendColorMsg(GetNativeCell(1), szBuffer);
}

Action MenuMainSending(int iClient)
{
   static GlobalForward hForward;
   if(!hForward)
      hForward = new GlobalForward("pas_MenuMainSending", ET_Event, Param_Cell);
   
   Action acNow = Plugin_Continue;
   Call_StartForward(hForward);
   Call_PushCell(iClient);
   Call_Finish(acNow);

   return acNow;
}

public void apiGetCount(Database hDB, DBResultSet hResult, const char[] error, any data)
{
	if(hResult == null || error[ZERO])
	{
		LogError("[PA] Failed on apiGetCount() << %s", error);
		return;
	}

   if(!hResult.FetchRow())
      return;
   
   DataPack hPack = data;
   hPack.Reset();
   Handle hPlug = view_as<Handle>(hPack.ReadCell());
   Function hFunc = hPack.ReadFunction();
   any cdata = hPack.ReadCell();
   hPack.Close();

   if(!hPlug || !hFunc)
      return;

   int iCount = hResult.FetchInt(0);

   Call_StartFunction(hPlug, hFunc);
   Call_PushCell(iCount);
   Call_PushCell(cdata);
   Call_Finish();
}

void OnStarted()
{
   static GlobalForward hForward;
	if(!hForward)
		hForward = new GlobalForward("pas_OnSuccess", ET_Ignore);
	
	Call_StartForward(hForward);
	Call_Finish();
}

void ClientLoaded(int iClient)
{
   Call_StartForward(gfClientLoaded);
   Call_PushCell(iClient);
   Call_Finish();
}

static const char Q_REQ[][256]=
{
   "SELECT SUM(`duration`) as `dur` FROM `player_analytics` WHERE `auth` = '%s'%s GROUP BY `auth`;",
   "SELECT COUNT(`id`) FROM `player_analytics` WHERE `auth` = '%s'%s",
   "SELECT `connect_time` FROM `player_analytics` WHERE `auth` = '%s'%s ORDER BY `id` ASC LIMIT 1;",
   "SELECT COUNT(`id`), COUNT(DISTINCT(`auth`)), SUM(`duration`) FROM `player_analytics`%s",
   "SELECT `name`, SUM(`duration`) as `dur` FROM `player_analytics`%s GROUP BY `auth` ORDER BY `dur` DESC LIMIT %i;",
   "SELECT `name`, COUNT(`id`) as `cid` FROM `player_analytics`%s GROUP BY `auth` ORDER BY `cid` DESC LIMIT %i;"/*,
   "SELECT COUNT(`id`) FROM `player_analytics` WHERE%s `connect_date` BETWEEN '%s' AND '%s'",
   "SELECT COUNT(DISTINCT(`auth`)) FROM `player_analytics` WHERE%s `connect_date` BETWEEN '%s' AND '%s'"*/
};

enum Q_NUM
{
   Q_CFULLTIME = 0,
   Q_CCONNECTIONS,
   Q_CFIRSTCON,
   Q_TCP,
   Q_TOPTIME,
   Q_TOPCON/*,
   Q_CONBYPERIOD,
   Q_PLAYERSBYPER*/
};

void q_GetCFullTime(const char[] szAuth, char[] szBuffer, int iLen, bool IsGlobal = false)
{
   //LogMessage(szAuth);
   if(IsGlobal)
   {
      dBase.Format(szBuffer, iLen, Q_REQ[Q_CFULLTIME], szAuth, "");
      return;
   }

   FormatEx(szBuffer, iLen, Q_REQ[Q_CFULLTIME], szAuth, " AND `server_ip` = '%s'");
   dBase.Format(szBuffer, iLen, szBuffer, cHost);
}

void q_GetCConnections(const char[] szAuth, char[] szBuffer, int iLen, bool IsGlobal = false)
{
   if(IsGlobal)
   {
      dBase.Format(szBuffer, iLen, Q_REQ[Q_CCONNECTIONS], szAuth, "");
      return;
   }

   FormatEx(szBuffer, iLen, Q_REQ[Q_CCONNECTIONS], szAuth, " AND `server_ip` = '%s'");
   dBase.Format(szBuffer, iLen, szBuffer, cHost);
}

void q_GetCFirstCon(const char[] szAuth, char[] szBuffer, int iLen, bool IsGlobal = false)
{
   if(IsGlobal)
   {
      dBase.Format(szBuffer, iLen, Q_REQ[Q_CFIRSTCON], szAuth, "");
      return;
   }

   FormatEx(szBuffer, iLen, Q_REQ[Q_CFIRSTCON], szAuth, " AND `server_ip` = '%s'");
   dBase.Format(szBuffer, iLen, szBuffer, cHost);
}

void q_GetTCP(char[] szBuffer, int iLen, bool IsGlobal = false)
{
   if(IsGlobal)
   {
      dBase.Format(szBuffer, iLen, Q_REQ[Q_TCP], "");
      return;
   }

   FormatEx(szBuffer, iLen, Q_REQ[Q_TCP], " WHERE `server_ip` = '%s'");
   dBase.Format(szBuffer, iLen, szBuffer, cHost);
}

void q_GetTopTime(char[] szBuffer, int iLen, bool IsGlobal = false)
{
   if(IsGlobal)
   {
      dBase.Format(szBuffer, iLen, Q_REQ[Q_TOPTIME], "", iTopCount);
      return;
   }
   
   FormatEx(szBuffer, iLen, Q_REQ[Q_TOPTIME], " WHERE `server_ip` = '%s'", iTopCount);
   dBase.Format(szBuffer, iLen, szBuffer, cHost);
}

void q_GetTopCon(char[] szBuffer, int iLen, bool IsGlobal = false)
{
   if(IsGlobal)
   {
      dBase.Format(szBuffer, iLen, Q_REQ[Q_TOPCON], "", iTopCount);
      return;
   }

   FormatEx(szBuffer, iLen, Q_REQ[Q_TOPCON], " WHERE `server_ip` = '%s'", iTopCount);
   dBase.Format(szBuffer, iLen, szBuffer, cHost);
}

/*void q_GetCon_ByPeriod(char[] szBuffer, int iLen, bool IsGlobal = false)
{
   if(IsGlobal)
   {
      dBase.Format(szBuffer, iLen, Q_REQ[Q_TOPCON], "", iTopCount);
      return;
   }

   FormatEx(szBuffer, iLen, Q_REQ[Q_TOPCON], " WHERE `server_ip` = '%s'", iTopCount);
   dBase.Format(szBuffer, iLen, szBuffer, cHost);
}*/
