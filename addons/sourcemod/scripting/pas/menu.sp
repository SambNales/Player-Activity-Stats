Menu pas_MainMenu(int iClient)
{
   Menu hMenu = new Menu(CB_PAS);

   SetGlobalTransTarget(iClient);

   char cBuffer[PMP], cTrigger[32];

   FormatEx(SZ(cBuffer), "%t", cMenuItem_Profile);

	hMenu.SetTitle("%t \n \n", cMenuTitle);
   hMenu.AddItem("profile", cBuffer);

   for(int i; i < API.aMenuItems.Length; i += 2)
   {
      API.aMenuItems.GetString(i, SZ(cTrigger));      
      FormatEx(SZ(cBuffer), "%t", cTrigger);
      hMenu.AddItem(cTrigger, cBuffer);
   }

   return hMenu;
}

public int CB_PAS(Menu hMenu, MenuAction action, int iClient, int iopt)
{
	if(action == MenuAction_End)
   {
      delete hMenu;
      return;
   }

   else if(action == MenuAction_Select)
   {
      char cTrigger[32];
      hMenu.GetItem(iopt, SZ(cTrigger));

      if(!strcmp(cTrigger, "profile"))
      {
         playerProfile(iClient).Display(iClient, MENU_TIME_FOREVER);
         return;
      }

      int iPos = API.aMenuItems.FindString(cTrigger);

      DataPack dPack = API.aMenuItems.Get(iPos+1);
      Handle hPlugin;
      Function hFunc;

      if(dPack)
      {
         dPack.Reset();
         hPlugin = dPack.ReadCell();
         hFunc = dPack.ReadFunction();
      }

      if(!hFunc || !hPlugin || GetPluginStatus(hPlugin) != Plugin_Running)
      {
         API.aMenuItems.Erase(iPos);
         LogError("Invalid methods for plugin: %x | State: %i", hPlugin, GetPluginStatus(hPlugin));
         return;
      }

      Call_StartFunction(hPlugin, hFunc);
      Call_PushCell(GetClientUserId(iClient));
      Call_Finish();
   }
}

Menu playerProfile(int iClient)
{
   Menu hMenu = new Menu(cbMenuProfile);
   char szTime[64], szMaxTime[64], szFCon[64], szFCon_Server[64];
   SetGlobalTransTarget(iClient);

   FormatTime(SZ(szFCon_Server), cTimeFormat, Stat[eServer].iPlayerFirst[iClient]);
   FormatTime(SZ(szFCon), cTimeFormat, Stat[eGlobal].iPlayerFirst[iClient]);
   
   GetStringTime(Stat[eGlobal].iPlayTime[iClient], SZ(szMaxTime));
   GetStringTime(Stat[eServer].iPlayTime[iClient], SZ(szTime));

	hMenu.SetTitle(
      "%t \n \n", cMenuTitle_Profile, szTime, szMaxTime, 
      Stat[eGlobal].iPlayerCon[iClient], Stat[eServer].iPlayerCon[iClient], 
      szFCon, szFCon_Server
   );
   
   hMenu.ExitBackButton = false;

   char cBack[16];
   FormatEx(SZ(cBack), "%t", szBack);

   hMenu.AddItem(NULL_STRING, cBack);

   return hMenu;
}

public int cbMenuProfile(Menu hMenu, MenuAction action, int iClient, int iopt)
{
	if(action == MenuAction_End)
   {
      delete hMenu;
      return;
   }

   else if(action == MenuAction_Select)
      pas_MainMenu(iClient).Display(iClient, MENU_TIME_FOREVER);
}