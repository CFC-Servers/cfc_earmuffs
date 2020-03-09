local utils = CFCEarmuffs.Utils

-- Sweps with extra sounds we need to network
local miscSweps = {
    ins2rpg7 = true
}

local function isMiscSwepSound( soundData )
    local nameSpl = utils.CleanSoundName( soundData.SoundName )
    nameSpl = string.Split( nameSpl, "/" )

    if nameSpl[1] ~= "weapons" then return false end

    local weaponName = nameSpl[2]
    if miscSweps[weaponName] then return true end

    return false
end

local function handleMiscSwepSound( soundData )
    if not isMiscSwepSound( soundData ) then return end

    return utils.broadcastEntityEmitSound( soundData )
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnMiscSwepSound", handleMiscSwepSound )
