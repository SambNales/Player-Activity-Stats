#if defined PLUGININFO

	#define PlName(%0) name = %0
	#define PlAuth(%0) author = %0
	#define PlDesc(%0) description = %0
	#define PlVer(%0) version = %0
	#define PlUrl(%0) url = %0

		#if defined STANDART_INFO
			#define	PlugAuth "wAries"
			#define	PlugUrl  "discord.gg/ChTyPUG"
			#define	PlugName "[ANY] IngameFilters"
			#define	PlugVer  "2.0"
			#define	PlugDesc "Фильтр всего, что дышит"
		#endif

	public Plugin myinfo = 
	{
		PlName(PlugName),
		PlAuth(PlugAuth),
		PlDesc(PlugDesc),
		PlVer(PlugVer),
		PlUrl(PlugUrl)
	};

#endif

#define SZ(%0)	%0, sizeof(%0)
#define SZF(%0) SZ(%0)

#define FORITER(%0,%1,%2) for(int %0 = %1; %0 < %2; %0++)

#define PMP PLATFORM_MAX_PATH
#define MPL MAXPLAYERS+1


stock char g_cColorsTag[][] = {"{WHITE}", "{RED}", "{LIME}", "{LIGHTGREEN}", "{LIGHTRED}", "{GRAY}", "{LIGHTOLIVE}", "{OLIVE}", "{LIGHTBLUE}", "{BLUE}", "{PURPLE}"}, \
	g_cColorsCSGO[][] = {"\x01", "\x02", "\x05", "\x06", "\x07", "\x08", "\x09", "\x10", "\x0B", "\x0C", "\x0E"};
stock int	g_iColorsCSSOB[] = {0xFFFFFF, 0xFF0000, 0x00FF00, 0x99FF99, 0xFF4040, 0xCCCCCC, 0xFFBD6B, 0xFA8B00, 0x99CCFF, 0x3D46FF, 0xFA00FA};

stock EngineVersion eGame;

stock void SendColorMsg(int iClient, const char[] sMsg, any ...)
{
	static char szBuffer[PMP];

	SetGlobalTransTarget(iClient);
	VFormat(SZ(szBuffer), sMsg, 3);

	if(eGame == Engine_CSGO)
	{
		for(int i = 1; i < 11; i++){
            ReplaceString(SZ(szBuffer), g_cColorsTag[i], g_cColorsCSGO[i], false);
        }
	}
	else if(eGame == Engine_CSS)
	{
		char sBuffer[32];
		for(int i; i < 11; i++)
		{
			FormatEx(SZ(sBuffer), "\x07%06X", g_iColorsCSSOB[i]);
			ReplaceString(SZ(szBuffer), g_cColorsTag[i], sBuffer, false);
		}
	}
	
	ReplaceString(SZ(szBuffer), "{DEFAULT}", g_cColorsCSGO[0], false);
	ReplaceString(SZ(szBuffer), "{TEAM}", "\x03", false);
	ReplaceString(SZ(szBuffer), "{GREEN}", "\x04", false);

	if(!iClient || IsClientSourceTV(iClient)) PrintToChatAll(szBuffer);
	else PrintToChat(iClient, szBuffer);
}