util.AddNetworkString( "CFC_Earmuffs_OnHL2NPCSound" )

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

local function isHL2NPCSound( soundName )
    local spl = string.Split( soundName, "/" )

    if spl[1] ~= "npc" then return end

    local npcType = spl[2]

    if hl2NPCs[npcType] then return true end
end

local utils = CFCEarmuffs.Utils

hook.Add( "OnEntityEmitSound", "CFC_Earmuffs_OnHL2NPC", function( soundData )
    if not isHL2NPCSound( soundData.SoundName ) then return end

    return utils.broadcastEntityEmitSound( soundData )
end )