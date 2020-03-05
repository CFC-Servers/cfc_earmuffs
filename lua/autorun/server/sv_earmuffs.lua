util.AddNetworkString( "CFC_Earmuffs_OnWeaponSound" )
util.AddNetworkString( "CFC_Earmuffs_OnDefaultWeaponSound" )

-- local entityMeta = FindMetaTable( "Entity" )
local weaponMeta = FindMetaTable( "Weapon" )

-- local weaponEmitSound = entityMeta.EmitSound

local emitSoundDefaults = {}
emitSoundDefaults.soundLevel = 75
emitSoundDefaults.pitchPercent = 100
emitSoundDefaults.volume = 1
emitSoundDefaults.channel = CHAN_AUTO

-- Every 10 ticks
local EMIT_INTERVAL = engine.TickInterval() * 10

function weaponMeta:EmitSound( soundName, soundLevel, pitchPercent, volume, channel )
    -- Only allow emitting every EMIT_INTERVAL
    if self.NextSoundEmitTime and SysTime() > self.NextSoundEmitTime then return end

    local usesDefaults = true

    if usesDefaults and soundLevel and soundLevel ~= emitSoundDefaults.soundLevel then
        usesDefaults = false
    end

    if usesDefaults and pitchPercent and pitchPercent ~= emitSoundDefaults.pitchPercent then
        usesDefaults = false
    end

    if usesDefaults and volume and volume ~= emitSoundDefaults.volume then
        usesDefaults = false
    end

    if usesDefaults and channel and channel ~= emitSoundDefaults.channel then
        usesDefaults = false
    end

    local weaponPos = self:GetPos()

    local unreliable = true

    self.NextSoundEmitTime = SysTime() + EMIT_INTERVAL

    -- If no additional values are given, we won't send anything more than is necessary
    if usesDefaults then
        net.Start( "CFC_Earmuffs_OnDefaultWeaponSound", unreliable )
            net.WriteEntity( self )
            net.WriteString( soundName )
        net.SendPAS( weaponPos )

        return
    end

    -- Ensure that everything has a value, set defaults if they do not
    soundLevel = soundLevel or emitSoundDefaults.soundLevel
    pitchPercent = pitchPercent or emitSoundDefaults.pitchPercent
    volume = volume or emitSoundDefaults.volume
    channel = channel or emitSoundDefaults.channel

    net.Start( "CFC_Earmuffs_OnWeaponSound", unreliable )
        net.WriteEntity( self )

        net.WriteString( soundName )

        -- Max value of 511, 9 bits
        net.WriteUInt( soundLevel, 9 )

        -- Max value of 255, 8 bits
        net.WriteUInt( pitchPercent, 8 )

        -- Turns a volume like 0.12345 into 12, or 1 -> 100
        -- This allows us to use WriteUInt with a specific bit size which should(?) be faster/smaller
        local smallVolume = math.Round( volume, 2 ) * 100
        -- Max value of 100, 7 bits
        net.WriteUInt( volume, 7 )

        -- Min value of -1, max value of 136, 9 bits
        net.WriteInt( channel, 9 )

    net.SendPAS( weaponPos )
end
