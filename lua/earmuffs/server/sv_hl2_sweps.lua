local rawget = rawget
local stringSplit = string.Split

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

local CleanSoundName = CFCEarmuffs.Utils.CleanSoundName
local broadcastEntityEmitSound = CFCEarmuffs.Utils.broadcastEntityEmitSound

local function isHL2Swep( soundData )
    local nameSpl = CleanSoundName( rawget( soundData, "SoundName" ) )
    nameSpl = stringSplit( nameSpl, "/" )

    if nameSpl[1] ~= "weapons" then return false end

    local weaponName = nameSpl[2]
    if rawget( hl2Sweps, weaponName ) then return true end
    if rawget( genericWeaponSounds, weaponName ) then return true end

    return false
end

local function handleHL2SwepSound( soundData )
    if not isHL2Swep( soundData ) then return end

    return broadcastEntityEmitSound( soundData )
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnHL2SwepSound", handleHL2SwepSound )
