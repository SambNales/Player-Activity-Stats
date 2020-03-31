#include sourcemod
#include pas

public Plugin myinfo =
{
	name		= "[OPTIONAL] Server Stats",
	author		= "nullent?",
	description	= "...",
	version		= PLUGIN_VERSION,
	url			= PLUIGN_LINK
};

static const char sName[][] = {"pas_Server", "pas_Server_title"};

char sBack[5] = "back";

enum struct eStatGrub
{
    int eMaxTime;
    int eMaxConn;
    int eMaxPlayers;
}

eStatGrub eStat;

public void OnPluginStart()
{
    LoadTranslations("pas.phrases.txt");
    if(pas_PluginStarted())
    {
        pas_OnSuccess();
        pas_OnPASDataLoaded();
    }
}

public void pas_OnSuccess()
{
    pas_RegMenuItem(sName[0], OnSelectedThis);
}

public void pas_OnPASDataLoaded()
{
    eStat.eMaxTime = pas_GetMaxTime(false);
    eStat.eMaxConn = pas_GetMaxConnections(false);
    eStat.eMaxPlayers = pas_GetMaxPlayers(false);
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
    
    GlobalInfoMenu(iClient).Display(iClient, MENU_TIME_FOREVER);
}

Menu GlobalInfoMenu(int iClient)
{
    Menu hMenu = new Menu(OnMenuCB);
    char szBack[32], szMaxTime[64];

    pas_TimeToChar(eStat.eMaxTime, szMaxTime, sizeof szMaxTime);

    SetGlobalTransTarget(iClient);
    hMenu.SetTitle(
        "%t \n \n", sName[1], 
        szMaxTime, eStat.eMaxConn, 
        eStat.eMaxPlayers
    );
    
    FormatEx(szBack, sizeof szBack, "%t", sBack);
    
    hMenu.ExitBackButton = false;
    hMenu.AddItem(NULL_STRING, szBack);

    return hMenu;
}

public int OnMenuCB(Menu hMenu, MenuAction action, int iOpt1, int iOpt2)
{
    if(action == MenuAction_End)
        hMenu.Close();
    
    else if(action == MenuAction_Select)
        pas_SendMainMenu(iOpt1);
}