local hl2NPCs = {
    antlion = true,
    antlion_guard = true,
    attack_helicopter = true,
    barnacle = true,
    combine_gunship = true,
    dog = true,
    fast_zombie = true,
    headcrab_poison = true,
    hunter = true,
    manhack = true,
    roller = true,
    scanner = true,
    turret_floor = true,
    vort = true,
    zombie = true,
    zombie_poison = true
}

local rawget = rawget
local rawset = rawset
local stringSplit = string.Split
local CleanSoundName = CFCEarmuffs.Utils.CleanSoundName
local broadcastEntityEmitSound = CFCEarmuffs.Utils.broadcastEntityEmitSound

local cache = {}

local function _isHL2NPCSound( soundName )
    local spl = stringSplit( soundName, "/" )

    if spl[1] ~= "npc" then return end

    local npcType = spl[2]

    return rawget( hl2NPCs, npcType ) or false
end

local function isHL2NPCSound( soundName )
    local cached = rawget( cache, soundName )
    if cached ~= nil then return cached end

    local result = _isHL2NPCSound( soundName )
    rawset( cache, soundName, result )

    return result
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnHL2NPC", function( soundData )
    local cleanName = CleanSoundName( rawget( soundData, "SoundName" ) )
    if not isHL2NPCSound( cleanName ) then return end

    return broadcastEntityEmitSound( soundData )
end )
