Scriptname SXP_Main extends Quest
{Sex Grants Experience Plus 2.0 - quest script.

The quest exists to host the player alias that carries SXP_PlayerAlias; the event
handling itself lives there, because only an alias script receives
OnPlayerLoadGame (mod event registrations are not stored in a save and have to be
re-armed after every load). This script only reports that the quest came up.}

Event OnInit()
	SXP_Log.Info("Sex Grants Experience Plus started (quest " + GetFormID() + ")")
EndEvent
