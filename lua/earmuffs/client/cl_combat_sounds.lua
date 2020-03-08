AddCSLuaFile()

local utils = CFCEarmuffs.Utils

local isImpactSound = {
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
    local soundName = utils.CleanSoundName( soundData.SoundName )

    if string.StartWith( soundName, "weapon" ) then return true end
    if string.StartWith( soundName, "npc" ) then return true end
    if string.StartWith( soundName, "ambient/explosions" ) then return true end
    if string.StartWith( soundName, "cw" ) then return true end

    local originalName = utils.CleanSoundName( soundData.OriginalSoundName )

    if string.StartWith( originalName, "weapon" ) then return true end
    if string.StartWith( originalName, "flesh" ) then return true end
    if string.StartWith( originalName, "metal" ) then return true end
    if string.StartWith( originalName, "cw_" ) then return true end

    if isImpactSound[originalName] then return true end
    if isShellSound[soundName] then return true end
end

local function shouldPlayCombatSound( soundData )
    if not isCombatSound( soundData ) then return end

    local soundVolume = soundData.Volume
    local soundLevel = soundData.SoundLevel

    local newVolume = utils.modifyCombatVolume( soundVolume )
    local newSoundLevel = utils.modifyCombatSoundLevel( soundLevel )

    soundData.Volume = newVolume
    soundData.SoundLevel = newSoundLevel

    return true
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnCombatSound", shouldPlayCombatSound )
