void SendBaseTransactions(int iClient)
{
   Transaction trLocal = new Transaction();

   char szQuery[256];
   int iUid = GetClientUserId(iClient);

   q_GetCFullTime(pPlayer[iClient].cSteam, SZ(szQuery), true);
   //LogMessage("FullTime1: %s", szQuery);
   trLocal.AddQuery(szQuery, 1);

   q_GetCConnections(pPlayer[iClient].cSteam, SZ(szQuery), true);
   //LogMessage("Con1: %s", szQuery);
   trLocal.AddQuery(szQuery, 3);

   q_GetCFirstCon(pPlayer[iClient].cSteam, SZ(szQuery), true);
   //LogMessage("FCon1: %s", szQuery);
   trLocal.AddQuery(szQuery, 5);

   q_GetCFullTime(pPlayer[iClient].cSteam, SZ(szQuery));
   //LogMessage("FullTime2: %s", szQuery);
   trLocal.AddQuery(szQuery, 0);

   q_GetCConnections(pPlayer[iClient].cSteam, SZ(szQuery));
   //LogMessage("Con2: %s", szQuery);
   trLocal.AddQuery(szQuery, 2);

   q_GetCFirstCon(pPlayer[iClient].cSteam, SZ(szQuery));
   //LogMessage("FCon2: %s", szQuery);
   trLocal.AddQuery(szQuery, 4);

   dBase.Execute(trLocal, OnSuccessTr, OnFailureTr, iUid);
}

public void OnFailureTr(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
   if(!error[0])
      return;
   
   LogError("Failed on client data transaction: %s | Executed queries: %i | Fail Index: %i", error, numQueries, failIndex);
}

public void OnSuccessTr(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
   data = GetClientOfUserId(data);
   if(!data)
      return;

   int mod;
   
   for(int i; i < numQueries; i++)
   {
      mod = queryData[i]%2;
      results[i].Rewind();

      if(queryData[i] < 2)
         Stat[mod].iPlayTime[data] = (results[i].FetchRow()) ? results[i].FetchInt(0) : 0;
      else if(queryData[i] > 1 && queryData[i] < 4)
         Stat[mod].iPlayerCon[data] = (results[i].FetchRow()) ? results[i].FetchInt(0) : 0;
      else
         Stat[mod].iPlayerFirst[data] = (results[i].FetchRow()) ? results[i].FetchInt(0) : 0;
   }

   Cache nCache;
   nCache.Build(pPlayer[data].cSteam);
   nCache.Open("w");
   nCache.WriteToCache(data);
   nCache.Destroy();

   ClientLoaded(data);
}

void OnBaseNotNull()
{
   Transaction trLocal = new Transaction();

   char szQuery[256];

   dBase.Format(SZ(szQuery), Querys[pClearInvalides]);
   trLocal.AddQuery(szQuery, pClearInvalides);

   dBase.Format(SZ(szQuery), "SELECT `server_ip` FROM `player_analytics` GROUP BY `server_ip`");
   trLocal.AddQuery(szQuery, 0);

   if(bErase)
   {
      int iTime = GetTime();
      dBase.Format(SZ(szQuery), Querys[pServerStatus], iTime - iDelPending*60, iTime);
      trLocal.AddQuery(szQuery, pServerStatus);
   }

   dBase.Execute(trLocal, OnSuccessBase, OnFailureBase);
}

public void OnFailureBase(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
   if(!error[0])
      return;
   
   LogError("Failed on server data transaction: %s | Executed queries: %i | Fail Index: %i", error, numQueries, failIndex);
}

public void OnSuccessBase(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
   char cAddress[32];

   if(results[1].FetchRow())
   {
      API.aServers.Clear();
      while(results[1].FetchRow())
      {
         results[1].FetchString(0, SZ(cAddress));
         API.aServers.PushString(cAddress);
      }
   }

   if(!bErase || !results[2].FetchRow())
   {
      LastTransaction();
      return;
   }
   
   results[2].Rewind();
   
   int iRow = results[2].RowCount - 1;
   int i;

   char cBuffer[512];

   FormatEx(SZ(cBuffer), "DELETE FROM `player_analytics` WHERE");
   while(results[2].FetchRow())
   {
      results[2].FetchString(0, SZ(cAddress));
      Format(SZ(cBuffer), "%s `server_ip` != '%s'%s", cBuffer, cAddress, (i < iRow) ? " AND" : "");	

      i++;
   }

   dBase.Format(SZ(cBuffer), cBuffer);
   LogMessage(cBuffer);
   dBase.Query(queryBuffer, cBuffer);


   LastTransaction();
}

void LastTransaction()
{
   //LogMessage("Last");
   Transaction trLocal = new Transaction();

   char szQuery[512];

   q_GetTCP(SZ(szQuery));
   trLocal.AddQuery(szQuery, 0);

   q_GetTCP(SZ(szQuery), true);
   trLocal.AddQuery(szQuery, 1);

   q_GetTopTime(SZ(szQuery));
   trLocal.AddQuery(szQuery, 2);

   q_GetTopTime(SZ(szQuery), true);
   trLocal.AddQuery(szQuery, 3);
   
   q_GetTopCon(SZ(szQuery));
   trLocal.AddQuery(szQuery, 4);

   q_GetTopCon(SZ(szQuery), true);
   trLocal.AddQuery(szQuery, 5);

   dBase.Execute(trLocal, OnSuccessLast, OnFailureLast);
}

public void OnFailureLast(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
   if(!error[0])
      return;
   
   LogError("Failed on last data transaction: %s | Executed queries: %i | Fail Index: %i", error, numQueries, failIndex);
}

public void OnSuccessLast(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
   int a, mod;
   char cBuffer[PMP], cTime[64];

   for(int i; i < numQueries; i++)
   {
      if(!results[i].FetchRow())
         continue;

      if(queryData[i] < 2)
      {
         Stat[queryData[i]].iMaxCon = results[i].FetchInt(0);
         Stat[queryData[i]].iMaxPlayers = results[i].FetchInt(1);
         Stat[queryData[i]].iPlayedTime = results[i].FetchInt(2);

         continue;
      }

      results[i].Rewind();
      mod = queryData[i]%2;

      if(queryData[i] < 4)
         Stat[mod].aOnline.Clear();
      else
         Stat[mod].aConnections.Clear();

      a = 1;
      while(results[i].FetchRow())
      {
         results[i].FetchString(ZERO, SZ(cBuffer));

         if(queryData[i] < 4)
            GetStringTime(results[i].FetchInt(1), SZ(cTime));
         else
            FormatEx(SZ(cTime), "%i", results[i].FetchInt(1));

         Format(SZ(cBuffer), "#%i | %s | %s", a, (!cBuffer[ZERO]) ? "*Hidden*" : cBuffer, cTime);

         if(queryData[i] < 4)
            Stat[mod].aOnline.PushString(cBuffer);
         else
            Stat[mod].aConnections.PushString(cBuffer);

         a++;
      }
   }

   Call_StartForward(gfDataLoaded);
   Call_Finish();
}