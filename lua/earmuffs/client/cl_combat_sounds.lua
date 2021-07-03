AddCSLuaFile()

local rawget = rawget

local logger = CFCEarmuffs.logger
local utils = CFCEarmuffs.Utils
local settings = CFCEarmuffs.Settings
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


local function isCombatSound( soundData )
    local soundName = CleanSoundName( soundData.SoundName )

    if StartWith( soundName, "weapon" ) then return true end
    if StartWith( soundName, "npc" ) then return true end
    if StartWith( soundName, "ambient/explosions" ) then return true end
    if StartWith( soundName, "cw" ) then return true end
    if StartWith( soundName, "acf" ) then return true end
    if StartWith( soundName, "gdc/rockets" ) then return true end

    local originalName = CleanSoundName( soundData.OriginalSoundName )

    if StartWith( originalName, "weapon" ) then return true end
    if StartWith( originalName, "flesh" ) then return true end
    if StartWith( originalName, "metal" ) then return true end
    if StartWith( originalName, "cw_" ) then return true end

    if rawget( isImpactSound, originalName ) then return true end
    if rawget( isShellSound, soundName ) then return true end
end

local modifyCombatVolume = utils.modifyCombatVolume
local modifyCombatSoundLevel = utils.modifyCombatSoundLevel

local function shouldPlayCombatSound( soundData )
    if not isCombatSound( soundData ) then return end

    logger:debug( "Received Combat Sound!" )

    if settings.CombatVolumeMult == 0 then return false end

    local soundVolume = soundData.Volume
    local soundLevel = soundData.SoundLevel

    local newVolume = modifyCombatVolume( soundVolume )
    local newSoundLevel = modifyCombatSoundLevel( soundLevel )

    soundData.Volume = newVolume
    soundData.SoundLevel = newSoundLevel

    return true
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnCombatSound", shouldPlayCombatSound )

logger:debug( "Combat Sound module loaded" )
