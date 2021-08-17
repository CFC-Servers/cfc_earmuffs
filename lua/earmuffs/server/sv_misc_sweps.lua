local utils = CFCEarmuffs.Utils

-- Sweps with extra sounds we need to network
local miscSweps = {
    ins2rpg7 = true
}

local rawget = rawget
local rawset = rawset
local Split = string.Split
local CleanSoundName = utils.CleanSoundName
local broadcastEntityEmitSound = utils.broadcastEntityEmitSound

local cache = {}

local function _isMiscSwepSound( soundName )
    local nameSpl = Split( soundName, "/" )

    if rawget( nameSpl, 1 ) ~= "weapons" then return false end

    local weaponName = rawget( nameSpl, 2 )
    if rawget( miscSweps, weaponName ) then return true end

    return false
end

local function isMiscSwepSound( soundName )
    local cached = rawget( cache, soundName )
    if cached ~= nil then return cached end

    local result = _isMiscSwepSound( soundName )
    rawset( cache, soundName, result )

    return result
end

local function handleMiscSwepSound( soundData )
    local soundName = CleanSoundName( rawget( soundData, "SoundName" ) )
    if not isMiscSwepSound( soundName ) then return end

    return broadcastEntityEmitSound( soundData )
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnMiscSwepSound", handleMiscSwepSound )
