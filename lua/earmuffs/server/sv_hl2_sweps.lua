local utils = CFCEarmuffs.Utils

local hl2Sweps = {
    ar1 = true,
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

local rawget = rawget
local Split = string.Split
local CleanSoundName = utils.CleanSoundName
local broadcastEntityEmitSound = utils.broadcastEntityEmitSound

local function isHL2Swep( soundData )
    local nameSpl = CleanSoundName( soundData.SoundName )
    nameSpl = Split( nameSpl, "/" )

    if rawget( nameSpl, 1 ) ~= "weapons" then return false end

    local weaponName = rawget( nameSpl, 2 )

    if rawget( hl2Sweps, weaponName ) then return true end
    if rawget( genericWeaponSounds, weaponName ) then return true end

    return false
end

local function handleHL2SwepSound( soundData )
    if not isHL2Swep( soundData ) then return end

    return broadcastEntityEmitSound( soundData )
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnHL2SwepSound", handleHL2SwepSound )
