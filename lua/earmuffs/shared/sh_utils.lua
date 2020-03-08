AddCSLuaFile()

CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.Utils = CFCEarmuffs.Utils or {}

local settings = CFCEarmuffs.Settings

CFCEarmuffs.Utils.CleanSoundName = function( soundName, maintainCase )
    soundName = string.Replace( soundName, ")", "" )
    soundName = string.Replace( soundName, "^", "" )
    soundName = string.Replace( soundName, "<", "" )

    if not maintainCase then
        soundName = string.lower( soundName )
    end

    return soundName
end

CFCEarmuffs.Utils.modifyCombatVolume = function( soundVolume )
    return ( soundVolume or 0.2 ) * settings.CombatVolumeMult
end

CFCEarmuffs.Utils.modifyCombatSoundLevel = function( soundLevel )
    return ( soundLevel or 75 ) * settings.CombatVolumeMult
end

function CFCEarmuffs.Utils:PlaySoundFor(originEnt, soundName, soundLevel, pitchPercent, volume, channel)
    local newVolume = self.modifyCombatVolume( volume )
    local newSoundLevel = self.modifyCombatSoundLevel( soundLevel )

    originEnt:EmitSound( soundName, newSoundLevel, pitchPercent, newVolume, channel )
end

if CLIENT then
    function CFCEarmuffs.Utils:ReceiveEmitSound()
        local soundName = net.ReadString()
        local originEnt = net.ReadEntity()

        if originEnt:IsWeapon() then
            if originEnt:GetOwner() == LocalPlayer() then return end
        end

        local soundChannel = net.ReadUInt()
        local soundPitch = net.ReadUInt()
        local soundLevel = net.ReadUInt()
        local soundVolume = net.ReadFloat()

        self:PlaySoundFor( originEnt, soundName, soundLevel, soundPitch, soundVolume, soundChannel )
    end
end

if SERVER then
    local throttler = CFCEarmuffs.SoundThrottler

    CFCEarmuffs.Utils.broadcastEntityEmitSound = function( soundData )
        local soundName = soundData.SoundName
        local originEnt = soundData.Entity
        local soundPos = soundData.Pos or originEnt:GetPos()
        local soundChannel = soundData.Channel
        local soundPitch = soundData.Pitch
        local soundLevel = soundData.SoundLevel
        local soundVolume = soundData.Volume

        if not IsValid( originEnt ) then return end
        if throttler.shouldThrottleSoundForEnt( soundName, originEnt ) then return false end

        local unreliable = true

        net.Start( "CFC_Earmuffs_OnEntityEmitSound", unreliable )
            net.WriteString( soundName )
            net.WriteEntity( originEnt )

            -- Min: -1, Max: 136. 9 bits
            net.WriteUInt( soundChannel, 9 )

            -- Min: 0, Max: 255, 8 bits
            net.WriteUInt( soundPitch, 8 )

            -- Min: 0, Max: 511, 9 bits
            net.WriteUInt( soundLevel, 9 )

            net.WriteFloat( soundVolume )
        net.SendPAS( soundPos )

        throttler.throttleSoundForEnt( soundName, originEnt )

        return false
    end
end
