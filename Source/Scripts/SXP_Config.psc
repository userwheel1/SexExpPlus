Scriptname SXP_Config Hidden
{Configuration and tag scoring for Sex Grants Experience Plus.

Everything is exposed as global functions so that the plugin only has to host a
single quest script (SXP_MainQuest) - there are no forms to wire up and no VMAD
properties to fill in.

Files (all optional except the main tag table):
  Data/SKSE/Plugins/SexExpPlus/config.json         tag -> EXP table (shipped)
  Data/SKSE/Plugins/SexExpPlus/config_custom.json  user overrides, wins over the above
  Data/SKSE/Plugins/SexExpPlus/settings.json       options (all of them have defaults)

MCM Helper integration (a real in-game menu) is deliberately not part of this
build: the menu is described by JSON, and every option already has a default and
a documented key, so the mod is fully usable and testable without it.}

import JMap

; ---------------------------------------------------------------------------
;  Locations
; ---------------------------------------------------------------------------

string Function Folder() global
	return "Data/SKSE/Plugins/SexExpPlus/"
EndFunction

string Function TagsFile() global
	return Folder() + "config.json"
EndFunction

string Function TagsFileCustom() global
	return Folder() + "config_custom.json"
EndFunction

string Function SettingsFile() global
	return Folder() + "settings.json"
EndFunction

; Display name used for MCM Helper (must match MCM/Config/<name>/config.json)
string Function ModName() global
	return "SexExpPlus"
EndFunction

; ---------------------------------------------------------------------------
;  Small helpers
; ---------------------------------------------------------------------------

; Skyrim's StringUtil has GetNthChar/AsOrd/AsChar but no ToLower, so tags are
; normalised by hand: P+ reports "Vaginal"/"HandJob", SLAL and OStim use their
; own casing, and the tag table is written in lower case.
string Function Lower(string text) global
	if text == ""
		return ""
	endif
	int i = 0
	int n = StringUtil.GetLength(text)
	string result = ""
	while i < n
		int c = StringUtil.AsOrd(StringUtil.GetNthChar(text, i))
		if c >= 65 && c <= 90
			c += 32
		endif
		result += StringUtil.AsChar(c)
		i += 1
	endwhile
	return result
EndFunction

string Function JoinTags(string[] tags) global
	string result = ""
	int i = 0
	while i < tags.Length
		if result == ""
			result = tags[i]
		else
			result += ", " + tags[i]
		endif
		i += 1
	endwhile
	return result
EndFunction

; ---------------------------------------------------------------------------
;  Tag table
; ---------------------------------------------------------------------------

; Returns a map with all keys lower-cased, config.json first and
; config_custom.json layered on top (custom wins).
int Function LoadTagTable() global
	int merged = JMap.object()
	int base = JValue.readFromFile(TagsFile())
	if base
		MergeKeys(merged, base)
	endif
	int customFile = JValue.readFromFile(TagsFileCustom())
	if customFile
		MergeKeys(merged, customFile)
	endif
	return merged
EndFunction

Function MergeKeys(int dest, int source) global
	int i = 0
	int n = JMap.count(source)
	while i < n
		string rawKey = JMap.getNthKey(source, i)
		JMap.setInt(dest, Lower(rawKey), JMap.getInt(source, rawKey, 0))
		i += 1
	endwhile
EndFunction

; Highest configured value among the given tags; noMatch is the floor.
int Function Score(string[] tags, int noMatch) global
	int table = LoadTagTable()
	int best = noMatch
	string bestTag = ""
	int i = 0
	while i < tags.Length
		string tagKey = Lower(tags[i])
		if tagKey != "" && JMap.hasKey(table, tagKey)
			int value = JMap.getInt(table, tagKey, 0)
			if value > best
				best = value
				bestTag = tagKey
			endif
		endif
		i += 1
	endwhile
	if GetBool("bLogTagMatches", false)
		if bestTag != ""
			SXP_Log.Info("Tags [" + JoinTags(tags) + "] -> " + bestTag + " = " + best)
		else
			SXP_Log.Info("Tags [" + JoinTags(tags) + "] -> no match, using No Match EXP = " + best)
		endif
	endif
	return best
EndFunction

; ---------------------------------------------------------------------------
;  Options
;  With MCM Helper installed the menu (MCM\Config\SexExpPlus\config.json) is the
;  source of truth; otherwise options come from settings.json. The guard checks
;  the plugin, so no MCM script call can ever happen when the dependency is
;  missing.
; ---------------------------------------------------------------------------

bool Function HasMcm() global
	return Game.GetModByName("MCMHelper.esp") != 255
EndFunction

; Menu ids use the "<settingName>:<Group>" form, where <Group> is the INI section.
string Function SettingKey(string keyName) global
	return keyName + ":Main"
EndFunction

int Function GetInt(string keyName, int fallback) global
	if HasMcm()
		return MCM.GetModSettingInt(ModName(), SettingKey(keyName))
	endif
	return JsonGetInt(keyName, fallback)
EndFunction

float Function GetFloat(string keyName, float fallback) global
	if HasMcm()
		return MCM.GetModSettingFloat(ModName(), SettingKey(keyName))
	endif
	return JsonGetFloat(keyName, fallback)
EndFunction

bool Function GetBool(string keyName, bool fallback) global
	if HasMcm()
		return MCM.GetModSettingBool(ModName(), SettingKey(keyName))
	endif
	return JsonGetBool(keyName, fallback)
EndFunction

int Function JsonGetInt(string keyName, int fallback) global
	int settings = JValue.readFromFile(SettingsFile())
	if !settings
		return fallback
	endif
	return JMap.getInt(settings, keyName, fallback)
EndFunction

float Function JsonGetFloat(string keyName, float fallback) global
	int settings = JValue.readFromFile(SettingsFile())
	if !settings
		return fallback
	endif
	return JMap.getFlt(settings, keyName, fallback)
EndFunction

bool Function JsonGetBool(string keyName, bool fallback) global
	int settings = JValue.readFromFile(SettingsFile())
	if !settings
		return fallback
	endif
	return JMap.getInt(settings, keyName, fallback as int) != 0
EndFunction
