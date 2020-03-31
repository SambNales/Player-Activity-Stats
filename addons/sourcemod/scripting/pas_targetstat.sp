#pragma newdecls required

#include pas
#include sdktools_functions

public Plugin myinfo =
{
	name		= "[OPTIONAL] Target stat",
	author		= "nullent?",
	description	= "...",
	version		= PLUGIN_VERSION,
	url			= PLUIGN_LINK
};

static const char sName[][] = {"pas_AIMStat", "pas_AIMList", "pas_AIMTarget_Title"};

char sBack[5] = "back";

//char cHost[32];

public void OnPluginStart()
{
    LoadTranslations("pas.phrases.txt");
    RegConsoleCmd("sm_seestat", Cmd_AIMStat);

    if(pas_PluginStarted())
        pas_OnSuccess();
}

public Action Cmd_AIMStat(int iClient, int iArgs)
{
    if(!iClient || !IsClientInGame(iClient) || IsFakeClient(iClient) || IsClientSourceTV(iClient))
        return Plugin_Handled;
    
    int iTarget = GetClientAimTarget(iClient, true);
    if(iTarget < 1 || IsFakeClient(iTarget) || !IsPlayerAlive(iTarget))
        return Plugin_Handled;
    
    ClientStat(iTarget).Display(iClient, MENU_TIME_FOREVER);
    return Plugin_Handled;
}

public void pas_OnSuccess()
{
    pas_RegMenuItem(sName[0], OnSelectedThis);
    //pas_GetServerAddress(cHost, sizeof cHost);
}

public void OnPluginEnd()
{
    if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "pas_DeleteMenuItem") == FeatureStatus_Available)
        pas_DeleteMenuItem(sName[0]);
}

public void OnSelectedThis(int iClient)
{
    iClient = GetClientOfUserId(iClient);
    if(!iClient)
        return;
    
    TargetsList().Display(iClient, MENU_TIME_FOREVER);
}

Menu TargetsList()
{
    Menu hMenu = new Menu(OnMenuCB);
    hMenu.ExitBackButton = true;
    hMenu.SetTitle("%t \n \n", sName[1]);

    char cBuffer[128], uid[16];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsClientInGame(i) || IsFakeClient(i) || IsClientSourceTV(i))
            continue;

        GetClientName(i, cBuffer, 110);
        
        IntToString(GetClientUserId(i), uid, sizeof uid);
        Format(cBuffer, sizeof(cBuffer), "ID: %s | %s", uid, cBuffer);

        hMenu.AddItem(uid, cBuffer);
    }

    return hMenu;
}

public int OnMenuCB(Menu hMenu, MenuAction action, int iOpt1, int iOpt2)
{
    if(action == MenuAction_End)
    {
        delete hMenu;
        return;
    }
    
    else if(action == MenuAction_Cancel && iOpt2 == MenuCancel_ExitBack)
        pas_SendMainMenu(iOpt1);
    
    else if(action == MenuAction_Select)
    {
        char uid[16];
        hMenu.GetItem(iOpt2, uid, sizeof uid);

        int data = GetClientOfUserId(StringToInt(uid));
        if(!data)
            return;
        
        ClientStat(data).Display(iOpt1, MENU_TIME_FOREVER);
    }
}

Menu ClientStat(int iTarget)
{
    Menu hMenu = new Menu(ClientStat_CB);
    //hMenu.ExitBackButton = true;

    int iCount[2];
    char cTime[2][32];
    char cDate[2][32];

    for(int i; i < 2; i++)
    {
        pas_TimeToChar(pas_GetPlayerTime(iTarget, view_as<bool>(i)), cTime[i], sizeof(cTime[]));
        iCount[i] = pas_GetPlayerConnections(iTarget, view_as<bool>(i));
        FormatTime(cDate[i], sizeof(cDate[]), "%d.%m.%Y | %H:%m", pas_GetPlayerFirstConnection(iTarget, view_as<bool>(i)));
    }


    hMenu.SetTitle(
        "%t \n \n", 
        sName[2], iTarget, 
        cTime[0], cTime[1], 
        iCount[0], iCount[1],
        cDate[0], cDate[1]
    );

    char szBack[16];
    FormatEx(szBack, sizeof szBack, "%t", sBack);
    hMenu.AddItem(sBack, szBack);

    return hMenu;
}

public int ClientStat_CB(Menu hMenu, MenuAction action, int iOpt1, int iOpt2)
{
    if(action == MenuAction_End)
    {
        delete hMenu;
        return;
    }

    else if(action == MenuAction_Select)
        TargetsList().Display(iOpt1, MENU_TIME_FOREVER);
}

