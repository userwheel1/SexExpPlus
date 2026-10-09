Scriptname SXP_Log Hidden
{Logging for Sex Grants Experience Plus. Global functions, no quest, no properties.}

string Function Prefix() global
	return "[SexExpPlus] "
EndFunction

; Normal informational message: always written to the Papyrus log, optionally to
; the console and/or as a corner notification (both switchable in the settings).
Function Info(string asText) global
	Debug.Trace(Prefix() + asText)
	if SXP_Config.GetBool("bLogConsole", true)
		MiscUtil.PrintConsole(Prefix() + asText)
	endif
	if SXP_Config.GetBool("bLogNotifications", false)
		Debug.Notification(Prefix() + asText)
	endif
EndFunction

; Errors and warnings are always traced, regardless of the settings.
Function Warn(string asText) global
	Debug.Trace(Prefix() + "WARNING: " + asText)
	if SXP_Config.GetBool("bLogConsole", true)
		MiscUtil.PrintConsole(Prefix() + "WARNING: " + asText)
	endif
EndFunction

Function Error(string asText) global
	Debug.Trace(Prefix() + "ERROR: " + asText)
	MiscUtil.PrintConsole(Prefix() + "ERROR: " + asText)
EndFunction
