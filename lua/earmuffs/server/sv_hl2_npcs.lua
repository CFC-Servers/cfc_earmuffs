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

local stringSplit = string.Split
local CleanSoundName = CFCEarmuffs.Utils.CleanSoundName
local broadcastEntityEmitSound = CFCEarmuffs.Utils.broadcastEntityEmitSound

local function isHL2NPCSound( soundName )
    local spl = stringSplit( soundName, "/" )

    if spl[1] ~= "npc" then return end

    local npcType = spl[2]

    if rawget( hl2NPCs, npcType ) then return true end
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnHL2NPC", function( soundData )
    local cleanName = CleanSoundName( soundData.SoundName )
    if not isHL2NPCSound( cleanName ) then return end

    return broadcastEntityEmitSound( soundData )
end )
