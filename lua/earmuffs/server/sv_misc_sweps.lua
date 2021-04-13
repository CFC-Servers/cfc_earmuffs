local utils = CFCEarmuffs.Utils

local rawget = rawget
local CleanSoundName = utils.CleanSoundName
local broadcastEntityEmitSound = utils.broadcastEntityEmitSound
local stringSplit = string.Split

-- Sweps with extra sounds we need to network
local miscSweps = {
    ins2rpg7 = true
}

local function isMiscSwepSound( soundData )
    local nameSpl = CleanSoundName( soundData.SoundName )
    nameSpl = stringSplit( nameSpl, "/" )

    if nameSpl[1] ~= "weapons" then return false end

    local weaponName = nameSpl[2]
    if rawget(miscSweps, weaponName) then return true end

    return false
end

local function handleMiscSwepSound( soundData )
    if not isMiscSwepSound( soundData ) then return end

    return broadcastEntityEmitSound( soundData )
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnMiscSwepSound", handleMiscSwepSound )
