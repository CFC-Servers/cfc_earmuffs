local hl2CombatSounds = {
    -- Misc
    ["Flesh.BulletImpact"] = true,
    ["Player.Death"] = true,
    ["Player.FallDamage"] = true,
    ["BaseCombatCharacter.AmmoPickup"] = true,
    ["BaseCombatCharacter.StopWeaponSounds"] = true,
}

local utils = CFCEarmuffs.Utils

local function isHL2Misc( soundData )
    local soundName = utils.CleanSoundName( soundData.OriginalSoundName )

    if hl2CombatSounds[soundName] then return true end
end

local function handleHL2MiscSound( soundData )
    if not isHL2Misc( soundData ) then return end

    return utils.broadcastEntityEmitSound( soundData )
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnHL2MiscSound", handleHL2MiscSount )
