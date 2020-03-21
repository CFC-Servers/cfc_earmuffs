AddCSLuaFile()

CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.Utils = CFCEarmuffs.Utils or {}

if SERVER then
    util.AddNetworkString( "CFC_Earmuffs_OnEntityEmitSound" )
end

CFCEarmuffs.Utils.CleanSoundName = function( soundName, maintainCase )
    soundName = string.Replace( soundName, ")", "" )
    soundName = string.Replace( soundName, "^", "" )
    soundName = string.Replace( soundName, "<", "" )

    -- Leading slash for some reason
    if soundName[1] == "/" then
        -- Get everything after the leading slash
        soundName = string.Right( soundName, string.len( soundName ) - 1 )
    end

    if not maintainCase then
        soundName = string.lower( soundName )
    end

    return soundName
end

CFCEarmuffs.Utils.modifyCombatVolume = function( soundVolume )
    local newVolume = soundVolume * CFCEarmuffs.Settings.CombatVolumeMult
    CFCEarmuffs.logger:debug("Received volume: '" .. soundVolume .. "' augmenting it with multiplier ('" .. CFCEarmuffs.Settings.CombatVolumeMult .. "') to receive '" .. newVolume .. "'")

    return newVolume
end

CFCEarmuffs.Utils.modifyCombatSoundLevel = function( soundLevel )
    local newSoundLevel = soundLevel * CFCEarmuffs.Settings.CombatVolumeMult

    return newSoundLevel
end

function CFCEarmuffs.Utils:PlaySoundFor(originEnt, soundName, soundLevel, soundPitch, volume, soundChannel, soundFlags)
    if not IsValid( originEnt ) then return end

    local newVolume = self.modifyCombatVolume( volume )
    local newSoundLevel = self.modifyCombatSoundLevel( soundLevel )

    EmitSound( soundName, originEnt:GetPos(), originEnt:EntIndex(), soundChannel, newVolume, newSoundLevel, soundFlags, soundPitch )
end

if CLIENT then
    function CFCEarmuffs.Utils:ReceiveEmitSound()
        local soundName = net.ReadString()
        local originEnt = net.ReadEntity()

        if originEnt:IsWeapon() and originEnt:GetOwner() == LocalPlayer() then return end

        local soundChannel = net.ReadUInt( 9 )
        local soundPitch = net.ReadUInt( 8 )
        local soundLevel = net.ReadUInt( 9 )
        local soundFlags = net.ReadUInt( 11 )
        local soundVolume = net.ReadFloat()

        self:PlaySoundFor( originEnt, soundName, soundLevel, soundPitch, soundVolume, soundChannel, soundFlags )
    end
end

if SERVER then

    local function findSoundTriggerer( soundData )
        local originEnt = soundData.Entity

        if originEnt:IsPlayer() then return originEnt end

        local owner = originEnt:GetOwner()
        local hasValidOwner = IsValid( owner ) and owner:IsPlayer()
        if hasValidOwner then return owner end

        local cppiOwner = originEnt:CPPIGetOwner()
        local hasValidCPPIOwner = IsValid( cppiOwner ) and cppiOwner:IsPlayer()
        if hasValidCPPIOwner then return cppiOwner end

        -- TODO: What now?
   end

    CFCEarmuffs.Utils.broadcastEntityEmitSound = function( soundData )
        local soundName = soundData.SoundName
        local originEnt = soundData.Entity
        local soundPos = soundData.Pos or originEnt:GetPos()
        local soundChannel = soundData.Channel or CHAN_AUTO
        local soundPitch = soundData.Pitch or 100
        local soundLevel = soundData.SoundLevel or 75
        local soundVolume = soundData.Volume or 1
        local soundFlags = soundData.Flags or 0

        if not IsValid( originEnt ) then return end

        if CFCEarmuffs.SoundThrottler.shouldThrottleSoundForEnt( soundName, originEnt ) then
            CFCEarmuffs.logger:debug("Discarding throttled sound: '" .. soundName .. "'")
            return false
        end

        local unreliable = true

        local soundTriggerer = findSoundTriggerer( soundData )
        local recipientFilter = RecipientFilter()
        recipientFilter:AddPas( soundPos )

        if soundTrigger then
            recipientFilter:RemovePlayer( soundTriggerer )
        end

        net.Start( "CFC_Earmuffs_OnEntityEmitSound", unreliable )
            net.WriteString( soundName )
            net.WriteEntity( originEnt )

            -- Min: -1, Max: 136. 9 bits
            net.WriteUInt( soundChannel, 9 )

            -- Min: 0, Max: 255, 8 bits
            net.WriteUInt( soundPitch, 8 )

            -- Min: 0, Max: 511, 9 bits
            net.WriteUInt( soundLevel, 9 )

            net.WriteUInt( soundFlags, 11 )

            net.WriteFloat( soundVolume )
        net.SendPAS( recipientFilter:GetPlayers() )

        CFCEarmuffs.SoundThrottler.throttleSoundForEnt( soundName, originEnt )

        return false
    end
end
