util.AddNetworkString( "CFC_Earmuffs_OnHL2SwepSound" )

local utils = CFCEarmuffs.Utils

local hl2Sweps = {
    ar2 = true,
    bugbait = true,
    cguard = true, -- Combine balls?
    crossbow = true,
    grenade = true,
    iceaxe = true, -- Used by Crowbar
    irifle = true, -- Combine balls?
    physcannon = true, -- Combine balls?
    pistol = true,
    rpg = true,
    shotgun = true,
    slam = true,
    smg1 = true,
    sniper = true, -- Used for RPG zoom-in
    stunstick = true,
    ["357"] = true
}

local genericWeaponSounds = {
    ["debris2.wav"] = true
}

local function isHL2Swep( soundData )
    local nameSpl = utils.CleanSoundName( soundData.SoundName )
    if nameSpl[1] ~= "weapon" then return false end

    local weaponName = nameSpl[2]
    if hl2Sweps[weaponName] then return true end
    if genericWeaponSounds[weaponName] then return true end

    return false
end

local function handleHL2SwepSound( soundData )
    if not isHL2Swep( soundData ) then return end

    return utils.broadcastEntityEmitSound( soundData )
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnHL2SwepSound", handleHL2SwepSound )
