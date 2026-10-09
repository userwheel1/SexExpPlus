Scriptname SXP_McmQuest extends MCM_ConfigBase
{MCM host for Sex Grants Experience Plus.

The menu itself is described by MCM\Config\SexExpPlus\config.json; this script only
has to exist and be attached to a start-game-enabled quest (plus a player alias with
SKI_PlayerLoadGameAlias), which is what MCM Helper requires. Every option the menu
writes is read back in SXP_Config through MCM.GetModSetting<Type>().}

Event OnConfigInit()
	SXP_Log.Info("MCM initialised")
EndEvent

Event OnSettingChange(string a_ID)
	if SXP_Config.GetBool("bLogConsole", true)
		SXP_Log.Info("Setting changed: " + a_ID)
	endif
EndEvent
