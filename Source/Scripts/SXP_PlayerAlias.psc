Scriptname SXP_PlayerAlias extends ReferenceAlias
{Event host for Sex Grants Experience Plus.

This script lives on the player alias of the mod's quest. It is the only place
that owns a form, because mod event registrations are not stored in a save: they
have to be re-established on every game load, and a player alias is the standard
way to get OnPlayerLoadGame without touching any other mod.}

import StorageUtil

; ---------------------------------------------------------------------------
;  Lifecycle
; ---------------------------------------------------------------------------

Event OnInit()
	SetUp()
EndEvent

; Fires on every save load, which is where the framework hooks must be re-armed.
Event OnPlayerLoadGame()
	SetUp()
EndEvent

Function SetUp()
	UnregisterAll()

	if !SXP_Config.GetBool("bEnabled", true)
		SXP_Log.Info("Disabled in settings, no events registered")
		return
	endif

	RegisterSexLab()
	RegisterOStim()
EndFunction

Function UnregisterAll()
	UnregisterForModEvent("HookAnimationStart")
	UnregisterForModEvent("HookAnimationEnd")
	UnregisterForModEvent("HookOrgasmEnd")
	UnregisterForModEvent("SexLabOrgasmSeparate")
	UnregisterForModEvent("OStim_Start")
	UnregisterForModEvent("OStim_SceneChanged")
	UnregisterForModEvent("OStim_End")
	UnregisterForModEvent("OStim_Orgasm")
EndFunction

; ---------------------------------------------------------------------------
;  SexLab (classic 1.6x and P+ 2.x share the Hook* events)
; ---------------------------------------------------------------------------

bool Function RegisterSexLab()
	if !Game.GetFormFromFile(0xD62, "SexLab.esm")
		SXP_Log.Info("SexLab not installed")
		return false
	endif

	int version = SexLabUtil.GetVersion()
	SXP_Log.Info("SexLab " + SexLabUtil.GetStringVer() + " (numeric " + version + "), P+ = " + ((version >= 20000) as int))

	; Hook* events carry (int threadID, bool hasPlayer) in both frameworks, and
	; the legacy AnimationStart/AnimationEnd events are still alive in P+ - so
	; registering both kinds would grant the reward twice.
	RegisterForModEvent("HookAnimationStart", "OnSceneStart")
	RegisterForModEvent("HookAnimationEnd", "OnSceneEnd")
	RegisterForModEvent("HookOrgasmEnd", "OnOrgasmEnd")
	RegisterForModEvent("SexLabOrgasmSeparate", "OnOrgasmSeparate")
	return true
EndFunction

Event OnSceneStart(int threadID, bool hasPlayer)
	if hasPlayer
		sceneOrgasm = false
	endif
EndEvent

Event OnOrgasmEnd(int threadID, bool hasPlayer)
	if hasPlayer
		sceneOrgasm = true
	endif
EndEvent

Event OnOrgasmSeparate(Form actorRef, int threadID)
	sslThreadController thread = SexLabUtil.GetAPI().GetController(threadID)
	if !thread
		return
	endif
	if thread.FindSlot(thread.PlayerRef) == -1
		return
	endif
	sceneOrgasm = true
EndEvent

Event OnSceneEnd(int threadID, bool hasPlayer)
	if !hasPlayer
		return
	endif

	sslThreadController thread = SexLabUtil.GetAPI().GetController(threadID)
	if !thread
		SXP_Log.Warn("Scene ended but thread " + threadID + " is gone")
		return
	endif
	if thread.FindSlot(thread.PlayerRef) == -1
		return
	endif

	; In P+ this event arrives while the thread is in STATUS_ENDING: the data is
	; still there, but be defensive about it.
	sslBaseAnimation animation = thread.Animation
	if !animation && thread.Animations.Length > 0
		animation = thread.Animations[0]
	endif

	int score
	if animation
		score = ScoreTags(animation.GetTags())
	else
		SXP_Log.Warn("No animation data, using the fallback reward")
		score = ScoreTags(new string[1])
	endif

	SXP_Reward.Grant(score, thread.ActorCount, thread.HasCreature, thread.IsVictim(thread.PlayerRef), sceneOrgasm)
EndEvent

; ---------------------------------------------------------------------------
;  OStim Standalone
; ---------------------------------------------------------------------------

bool Function RegisterOStim()
	if !Game.IsPluginInstalled("OStim.esp")
		SXP_Log.Info("OStim not installed")
		return false
	endif
	SXP_Log.Info("OStim detected")
	RegisterForModEvent("OStim_Start", "OStim_Start")
	RegisterForModEvent("OStim_SceneChanged", "OStim_SceneChanged")
	RegisterForModEvent("OStim_End", "OStim_End")
	RegisterForModEvent("OStim_Orgasm", "OStim_Orgasm")
	UnregisterOStimPlayer()
	return true
EndFunction

; OStim reports every action of a scene separately, so they are collected and
; the best paying one wins.
Event OStim_Start(string eventName, string strArg, float numArg, Form sender)
	string[] actions = OMetadata.GetActionTypes(strArg)
	StringListClear(Key(), "SXP_actions")
	SetIntValue(Key(), "SXP_actorCount", OThread.GetActors(0).Length)
	if SXP_Config.GetBool("bLogTagMatches", false)
		SXP_Log.Info("OStim scene started: [" + SXP_Config.JoinTags(actions) + "]")
	endif
	sceneOrgasm = false
EndEvent

Event OStim_SceneChanged(string eventName, string strArg, float numArg, Form sender)
	string[] actions = OMetadata.GetActionTypes(strArg)
	StringListClear(Key(), "SXP_actions")
	int i = 0
	while i < actions.Length
		StringListAdd(Key(), "SXP_actions", actions[i])
		i += 1
	endwhile
EndEvent

Event OStim_Orgasm(string eventName, string strArg, float numArg, Form sender)
	sceneOrgasm = true
EndEvent

Event OStim_End(string eventName, string strArg, float numArg, Form sender)
	string[] actions = StringListToArray(Key(), "SXP_actions")
	StringListClear(Key(), "SXP_actions")
	int score = ScoreTags(actions)
	SXP_Reward.Grant(score, GetIntValue(Key(), "SXP_actorCount", 1), false, OUtils.GetOStim().IsVictim(GetReference() as Actor), sceneOrgasm)
EndEvent

; ---------------------------------------------------------------------------
;  Shared
; ---------------------------------------------------------------------------

bool sceneOrgasm = false

int Function ScoreTags(string[] tags)
	return SXP_Config.Score(tags, SXP_Config.GetInt("iNoMatchExp", 5))
EndFunction

Function UnregisterOStimPlayer()
	; reserved for future per-thread bookkeeping
EndFunction

; Storage keys are held on the player reference: ObjectReference extends Form, so this
; always resolves, independent of what the alias script itself is derived from.
Form Function Key()
	return GetReference() as Form
EndFunction
