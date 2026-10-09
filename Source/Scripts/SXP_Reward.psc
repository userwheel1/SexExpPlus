Scriptname SXP_Reward Hidden
{Reward calculation and delivery for Sex Grants Experience Plus.

Global functions only - no quest, no properties. The reward is handed to the
Experience mod, which drives the level curve; Static Skill Leveling Rewritten
turns the resulting level-ups into skill points.}

; ---------------------------------------------------------------------------
;  Logging
; ---------------------------------------------------------------------------
; (SXP_Log is a separate global script so every part of the mod can log)

; ---------------------------------------------------------------------------
;  Entry point
; ---------------------------------------------------------------------------

; amount      - base EXP from the tag table
; actorCount  - actors in the scene
; hasCreature - scene contained at least one creature
; expLoss     - the framework considers the player a victim
; orgasm       - at least one actor in the scene reached orgasm
Function Grant(int amount, int actorCount, bool hasCreature, bool expLoss, bool orgasm) global
	float bonus = 0.0
	float exp = amount
	Actor player = Game.GetPlayer()
	if !player
		return
	endif

	if !SXP_Config.GetBool("bSoloScenes", true) && actorCount < 2
		SXP_Log.Info("No EXP: solo scenes are disabled")
		return
	endif

	if SXP_Config.GetBool("bCooldownEnabled", false)
		float last = StorageUtil.GetFloatValue(player as Form, "SXP_LastGrant", 0.0)
		float hoursSince = (Utility.GetCurrentGameTime() - last) * 24
		float cooldownHours = SXP_Config.GetFloat("fCooldownHours", 24.0)
		if hoursSince < cooldownHours
			SXP_Log.Info("No EXP: cooldown, " + (cooldownHours - hoursSince) + " h left")
			return
		endif
	endif

	if SXP_Config.GetBool("bRequireOrgasm", false) && !orgasm
		SXP_Log.Info("No EXP: no orgasm occurred")
		return
	endif

	SXP_Log.Info("Base EXP: " + amount + " (" + actorCount + " actor(s))")

	if hasCreature
		bonus += SXP_Config.GetFloat("fCreatureBonus", 0.25)
		SXP_Log.Info("Creature involved")
	endif

	int threshold = SXP_Config.GetInt("iActorThreshold", 3)
	if actorCount >= threshold
		float perActor = SXP_Config.GetFloat("fActorBonus", 0.1)
		int behaviour = SXP_Config.GetInt("iActorBehaviour", 1)
		if behaviour == 2
			; count only actors at or above the threshold
			bonus += (actorCount - threshold + 1) * perActor
		else
			; behaviour 0 counts every actor, 1 counts every actor except the player
			bonus += (actorCount - behaviour) * perActor
		endif
		SXP_Log.Info("Per-actor bonus applied")
	endif

	if bonus > 0.0
		exp = exp * (bonus + 1.0)
		SXP_Log.Info("Bonus: " + (bonus * 100) + "%")
	endif

	if expLoss && SXP_Config.GetBool("bExpLoss", false)
		exp = exp * SXP_Config.GetFloat("fExpLossMultiplier", 0.0) * -1.0
		if !SXP_Config.GetBool("bExpLossNegative", false)
			int budget = CurrentXpBudget(player)
			if (exp * -1.0) > budget
				exp = budget * -1.0
			endif
		endif
		SXP_Log.Info("Losing EXP: " + exp)
	endif

	int toGrant = Math.Floor(exp)
	SXP_Log.Info("Total EXP: " + toGrant)
	Experience.AddExperience(toGrant, true)

	UpdateXpBudget(player, toGrant)
	if SXP_Config.GetBool("bCooldownEnabled", false)
		StorageUtil.SetFloatValue(player as Form, "SXP_LastGrant", Utility.GetCurrentGameTime())
	endif
EndFunction

; ---------------------------------------------------------------------------
;  EXP budget
;
;  "Allow Negative EXP" is meant to stop EXP from dropping below the start of
;  the current level. Game.GetPlayerExperience() cannot be used for that while
;  the Experience mod owns the level curve, so the mod tracks how much EXP it
;  granted during the current level and clamps the loss against that.
; ---------------------------------------------------------------------------

int Function CurrentXpBudget(Actor player) global
	SyncLevel(player)
	return StorageUtil.GetIntValue(player as Form, "SXP_XpBank", 0)
EndFunction

Function UpdateXpBudget(Actor player, int delta) global
	SyncLevel(player)
	int bank = StorageUtil.GetIntValue(player as Form, "SXP_XpBank", 0) + delta
	if bank < 0
		bank = 0
	endif
	StorageUtil.SetIntValue(player as Form, "SXP_XpBank", bank)
EndFunction

Function SyncLevel(Actor player) global
	int level = player.GetLevel()
	if StorageUtil.GetIntValue(player as Form, "SXP_XpLevel", -1) != level
		StorageUtil.SetIntValue(player as Form, "SXP_XpLevel", level)
		StorageUtil.SetIntValue(player as Form, "SXP_XpBank", 0)
	endif
EndFunction
