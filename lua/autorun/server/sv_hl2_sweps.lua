util.AddNetworkString( "CFC_Earmuffs_OnHL2SwepSound" )

-- Every 10 ticks
local EMIT_INTERVAL = engine.TickInterval() * 10

local hl2CombatSounds = {
    ["Weapon_SMG1.Single"] = true,
    ["Weapon_AR2.Single"] = true,
    ["Weapon_357.Single"] = true,
    ["Weapon_SMG1.Double"] = true,
    ["Weapon_IRifle.Single"] = true,
    ["Weapon_CombineGuard.Special1"] = true,
    ["Weapon_Crossbow.BoltElectrify"] = true,
    ["Weapon_Crossbow.BoltHitWorld"] = true,
    ["Weapon_Crossbow.BoltFly"] = true,
    ["BaseCombatCharacter.AmmoPickup"] = true,
    ["NPC_CombineBall.Launch"] = true,
    ["NPC_CombineBall.Explosion"] = true,
    ["NPC_CombineBall.Impact"] = true,
    ["Grenade.Blip"] = true,
    ["physics/metal/weapon_impact_hard1.wav"] = true,         -- SLAM hitting the ground
    ["physics/metal/weapon_impact_hard2.wav"] = true,         -- SLAM hitting the ground
    ["physics/metal/weapon_impact_hard3.wav"] = true,         -- SLAM hitting the ground
    ["physics/metal/soda_can_scrape_rough_loop1.wav"] = true, -- SLAM hitting the ground
    ["BaseCombatCharacter.StopWeaponSounds"] = true,
    ["Player.Death"] = true,
    ["Weapon_RPG.LaserOn"] = true,
    ["Weapon_RPG.LaserOff"] = true,
    ["Weapon_RPG.Single"] = true,
    ["Missile.Ignite"] = true,
    ["GrenadeBugBait.Splat"] = true
}

-- Stores Entities to tables of Sound Names to time values (next time that sound can be transmitted)
local soundThrottle = {}

local function throttleSoundForEnt( soundName, originEnt )
    local nextSoundPlay = SysTime() + EMIT_INTERVAL

    soundThrottle[originEnt] = soundThrottle[originEnt] or {}
    soundThrottle[originEnt][soundName] = nextSoundPlay
end

local function shouldThrottleSoundForEnt( soundName, originEnt )
    local throttledEnt = soundThrottle[originEnt]
    if throttledEnt then
        local nextSoundPlay = throttledEnt[soundName]

        if nextSoundPlay and nextSoundPlay > SysTime() then return true end
    end
end

local function groomThrottler()
    for originEnt, throttleData in pairs( soundThrottle ) do
        if IsValid( originEnt ) then
            for soundName, nextPlay in pairs( throttleData ) do
                if nextPlay <= SysTime() then
                    throttleData[soundName] = nil
                end
            end
        else
            soundThrottle[originEnt] = nil
        end
    end
end

timer.Create("CFC_Earmuffs_GroomHL2Throttle", 5, -1, groomThrottler)

local function isHL2Sound( soundData )
    local originalSoundName = soundData.OriginalSoundName

    if hl2CombatSounds[originalSoundName] then return true end

    return false
end

local function handleHL2SwepSound( soundData )
    if not isHL2Sound( soundData ) then return end

    local soundName = soundData.SoundName
    local originEnt = soundData.Entity

    if not IsValid( originEnt ) then return end

    local soundPos = soundData.Pos or originEnt:GetPos()

    if shouldThrottleSoundForEnt( soundName, originEnt ) then return end

    local unreliable = true

    net.Start( "CFC_Earmuffs_OnHL2SwepSound", unreliable )
        net.WriteString( soundName )
        net.WriteEntity( originEnt )
    net.SendPAS( soundPos )

    throttleSoundForEnt( soundName, originEnt )

    return false
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnHL2SwepSound", handleHL2SwepSound )
