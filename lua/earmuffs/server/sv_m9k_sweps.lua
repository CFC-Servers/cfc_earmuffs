local utils = CFCEarmuffs.Utils

-- m9k Sweps with extra sounds we need to network
local m9kSweps = {
    ins2rpg7 = true
}

local function isM9kSwep( soundData )
    local nameSpl = utils.CleanSoundName( soundData.SoundName )
    nameSpl = string.Split( nameSpl, "/" )

    if nameSpl[1] ~= "weapons" then return false end

    local weaponName = nameSpl[2]
    if M9kSweps[weaponName] then return true end

    return false
end

local function handleM9kSwep( soundData )
    if not isM9kSwep( soundData ) then return end

    return utils.broadcastEntityEmitSound( soundData )
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnM9kSwepSound", handleM9kSwep )
