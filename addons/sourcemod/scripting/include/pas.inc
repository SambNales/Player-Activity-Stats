#if defined _pas_included
 #endinput
#endif
#define _pas_included

#define PLUGIN_VERSION 	"2.1"
#define PLUIGN_LINK 	"discord.gg/ChTyPUG"


typedef OnQueryResult = function void(int iCount, any data);	

typedef OnRowSelectedCB = function void(int iUid);

/** ... **/
forward void pas_OnClientSuccess(int iClient);

/** ... **/
forward void pas_OnPASDataLoaded();

/** ... **/
forward void pas_OnSuccess();

/** ... **/
forward Action pas_MenuMainSending(int iClient);


native bool pas_PluginStarted();

native int pas_GetPlayerTime(int iClient, bool All = true);

native int pas_GetPlayerConnections(int iClient, bool All = true);

native int pas_GetPlayerFirstConnection(int iClient, bool All = true);

native ArrayList pas_GetOnlineTOP(bool All = true);

native ArrayList pas_GetConnectionsTOP(bool All = true);

/**
 * Getting the number of unique users over a period of time
 *
 * @param cStartDate    Start date (Format: Y-m-d)
 * @param cStartDate    End date (Format: Y-m-d)
 * @param qOnResult		Callback for getting count (Use: OnQueryResult prototype)
 *                      
 * @noreturn
 */
//native void pas_GetCountPlayers(const char[] cStartDate, const char[] cEndDate, OnQueryResult qOnResult, any data);

/**
 * Getting the number of connections over a period of time
 *
 * @param cStartDate    Start date (Format: Y-m-d)
 * @param cStartDate    End date (Format: Y-m-d)
 * @param qOnResult		Callback for getting count (Use: OnQueryResult prototype)
 *                      
 * @noreturn
 */
//native void pas_GetCountConnections(const char[] cStartDate, const char[] cEndDate, OnQueryResult qOnResult, any data);

native int pas_GetMaxPlayers(bool All = true);

native int pas_GetMaxConnections(bool All = true);

native int pas_GetMaxTime(bool All = true);

native ArrayList pas_GetServerList();

native void pas_ResetTable();

native void pas_ResetPlayer(int iClient);

native void pas_ResetServer(const char[] cServerAddress);

native bool pas_RegMenuItem(const char[] szTrigger, OnRowSelectedCB onSelected);

native bool pas_DeleteMenuItem(const char[] szTrigger);

native void pas_GetServerAddress(char[] szTrigger, int iLen);

native bool pas_SendMainMenu(int iClient);

native void pas_TimeToChar(int iTime, char[] szTime, int iLen);

native void pas_SendMsg(int iClient, const char[] szMsg, any ...);

public SharedPlugin __pl_pas= 
{
	name = "pas",
	file = "pas.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_pas_SetNTVOptional()
{
	MarkNativeAsOptional("pas_GetPlayerTime");
	MarkNativeAsOptional("pas_GetPlayerConnections");
	MarkNativeAsOptional("pas_GetPlayerFirstConnection");
	MarkNativeAsOptional("pas_GetOnlineTOP");
	MarkNativeAsOptional("pas_GetConnectionsTOP");
	MarkNativeAsOptional("pas_GetMaxPlayers");
	MarkNativeAsOptional("pas_GetMaxConnections");
	MarkNativeAsOptional("pas_GetMaxTime");
	MarkNativeAsOptional("pas_ResetTable");
	MarkNativeAsOptional("pas_ResetPlayer");
	MarkNativeAsOptional("pas_ResetServer");
	MarkNativeAsOptional("pas_GetServerList");
	MarkNativeAsOptional("pas_GetServerAddress");
	MarkNativeAsOptional("pas_RegMenuItem");
	MarkNativeAsOptional("pas_DeleteMenuItem");
	MarkNativeAsOptional("pas_SendMainMenu");
	MarkNativeAsOptional("pas_TimeToChar");
	MarkNativeAsOptional("pas_SendMsg");
	MarkNativeAsOptional("pas_PluginStarted");
}
#endif