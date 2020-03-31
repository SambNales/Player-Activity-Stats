#include sourcemod
#include pas

public Plugin myinfo =
{
	name		= "[OPTIONAL] Server TOP playes",
	author		= "nullent?",
	description	= "...",
	version		= PLUGIN_VERSION,
	url			= PLUIGN_LINK
};

static const char sName[][] = {"pas_ServerTop", "pas_ServerTop_title"};

//char sBack[5] = "back";

int iCount;

ArrayList alTop;

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
    alTop = pas_GetOnlineTOP(false);
    iCount = alTop.Length;
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
    //char szBack[32];

    SetGlobalTransTarget(iClient);
    hMenu.SetTitle("%t \n \n", sName[1], iCount);

    char szTop[PLATFORM_MAX_PATH];
    for(int i; i < iCount; i++)
    {
        alTop.GetString(i, szTop, PLATFORM_MAX_PATH);
        hMenu.AddItem(NULL_STRING, szTop, ITEMDRAW_DISABLED);
    }
    //FormatEx(szBack, sizeof szBack, "%t", sBack);
    
    hMenu.ExitBackButton = true;
    //hMenu.AddItem(NULL_STRING, szBack);

    return hMenu;
}

public int OnMenuCB(Menu hMenu, MenuAction action, int iOpt1, int iOpt2)
{
    if(action == MenuAction_End)
        hMenu.Close();
    
    else if(action == MenuAction_Cancel && iOpt2 == MenuCancel_ExitBack)
        pas_SendMainMenu(iOpt1);
}