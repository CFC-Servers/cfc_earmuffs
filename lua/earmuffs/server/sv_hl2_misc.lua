local hl2CombatSounds = {
    -- Misc
    ["Flesh.BulletImpact"] = true,
    ["Player.Death"] = true,
    ["Player.FallDamage"] = true,
    ["BaseCombatCharacter.AmmoPickup"] = true,
    ["BaseCombatCharacter.StopWeaponSounds"] = true,
}

local rawget = rawget
local utils = CFCEarmuffs.Utils
local CleanSoundName = CFCEarmuffs.Utils.CleanSoundName
local broadcastEntityEmitSound = CFCEarmuffs.Utils.broadcastEntityEmitSound

local function isHL2Misc( soundData )
    local maintainCase = true
    local soundName = CleanSoundName(
        soundData.OriginalSoundName,
        maintainCase
    )

    if rawget( hl2CombatSounds, soundName ) then return true end
end

local function handleHL2MiscSound( soundData )
    if not isHL2Misc( soundData ) then return end

    return broadcastEntityEmitSound( soundData )
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnHL2MiscSound", handleHL2MiscSound )
