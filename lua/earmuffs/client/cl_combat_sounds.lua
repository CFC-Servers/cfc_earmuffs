AddCSLuaFile()

local rawget = rawget
local rawset = rawset

local logger = CFCEarmuffs.logger
local utils = CFCEarmuffs.Utils
local SettingsGet = CFCEarmuffs.Settings.Get
local StartWith = string.StartWith
local CleanSoundName = utils.CleanSoundName

local isImpactSound = {
    ["default.bulletimpact"] = true,
    ["dirt.bulletimpact"] = true,
    ["concrete.bulletimpact"] = true,
    ["tile.bulletimpact"] = true,
    ["solidmetal.bulletimpact"] = true,
    ["drywall.impacthard"] = true,
    ["flesh.bulletimpact"] = true,
    ["wood.bulletimpact"] = true
}

local isShellSound = {
    ["player/pl_shell1.wav"] = true,
    ["player/pl_shell2.wav"] = true,
    ["player/pl_shell3.wav"] = true
}

local cache = {}

local function _isCombatSoundBasic( soundName )
    if StartWith( soundName, "weapon" ) then return true end
    if StartWith( soundName, "npc" ) then return true end
    if StartWith( soundName, "ambient/explosions" ) then return true end
    if StartWith( soundName, "cw" ) then return true end
    if StartWith( soundName, "acf" ) then return true end
    if StartWith( soundName, "gdc/rockets" ) then return true end
    if rawget( isShellSound, soundName ) then return true end

    return false
end

local function _isCombatSoundOriginal( soundName )
    if StartWith( originalName, "weapon" ) then return true end
    if StartWith( originalName, "flesh" ) then return true end
    if StartWith( originalName, "metal" ) then return true end
    if StartWith( originalName, "cw_" ) then return true end
    if rawget( isImpactSound, soundName ) then return true end

    return false
end

local function _isCombatSound( soundName, checker )
    local cached = rawget( cache, soundName )
    if cached ~= nil then return cached end

    local result = checker( soundName )
    rawset( cache, soundName, result )

    return result
end

local function isCombatSound( soundData )
    local soundName = rawget( soundData, "SoundName" )
    local basicResult = _isCombatSound( soundName, _isCombatSoundBasic )
    if basicResult then return basicResult end

    local soundNameOriginal = rawget( soundData, "OriginalSoundName" )
    local originalResult = _isCombatSound( soundName, _isCombatSoundOriginal )
    if originalResult then return originalResult end

    return false
end

local modifyCombatVolume = utils.modifyCombatVolume
local modifyCombatSoundLevel = utils.modifyCombatSoundLevel

local function shouldPlayCombatSound( soundData )
    if not isCombatSound( soundData ) then return end

    logger:debug( "Received Combat Sound!" )

    if SettingsGet( "CombatVolumeMult" ) == 0 then return false end

    local soundVolume = soundData.Volume
    local soundLevel = soundData.SoundLevel

    local newVolume = modifyCombatVolume( soundVolume )
    local newSoundLevel = modifyCombatSoundLevel( soundLevel )

    rawset( soundData, "Volume", newVolume )
    rawset( soundData, "SoundLevel", newSoundLevel )

    return true
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnCombatSound", shouldPlayCombatSound )

logger:debug( "Combat Sound module loaded" )
