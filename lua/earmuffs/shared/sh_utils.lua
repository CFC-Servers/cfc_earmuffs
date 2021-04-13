AddCSLuaFile()

CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.Utils = CFCEarmuffs.Utils or {}

local Logger = CFCEarmuffs.logger

if SERVER then
    util.AddNetworkString( "CFC_Earmuffs_OnEntityEmitSound" )
end

local IsValid = IsValid
local rawget = rawget
local stringReplace = string.Replace
local stringRight = string.Right
local stringLen = string.len
local stringLower = string.lower

CFCEarmuffs.Utils.CleanSoundName = function( soundName, maintainCase )
    soundName = stringReplace( soundName, ")", "" )
    soundName = stringReplace( soundName, "^", "" )
    soundName = stringReplace( soundName, "<", "" )

    -- Leading slash for some reason
    if soundName[1] == "/" then
        -- Get everything after the leading slash
        soundName = stringRight( soundName, stringLen( soundName ) - 1 )
    end

    if not maintainCase then
        soundName = stringLower( soundName )
    end

    return soundName
end

CFCEarmuffs.Utils.modifyCombatVolume = function( soundVolume )
    local newVolume = soundVolume * rawget(rawget(CFCEarmuffs, "Settings"), "CombatVolumeMult")
    Logger:debug("Received volume: '" .. soundVolume .. "' augmenting it with multiplier ('" .. CFCEarmuffs.Settings.CombatVolumeMult .. "') to receive '" .. newVolume .. "'")

    return newVolume
end

CFCEarmuffs.Utils.modifyCombatSoundLevel = function( soundLevel )
    return soundLevel * rawget(rawget(CFCEarmuffs, "Settings"), "CombatVolumeMult")
end

function CFCEarmuffs.Utils:PlaySoundFor(originEnt, soundName, soundLevel, soundPitch, volume, soundChannel, soundFlags)
    if not IsValid( originEnt ) then return end

    local newVolume = self.modifyCombatVolume( volume )
    local newSoundLevel = self.modifyCombatSoundLevel( soundLevel )

    EmitSound( soundName, originEnt:GetPos(), originEnt:EntIndex(), soundChannel, newVolume, newSoundLevel, soundFlags, soundPitch )
end

if CLIENT then
    local netReadString = net.ReadString
    local netReadEntity = net.ReadEntity
    local netReadUInt = net.ReadUInt
    local netReadFloat = net.ReadFloat

    function CFCEarmuffs.Utils:ReceiveEmitSound()
        local soundName = netReadString()
        local originEnt = netReadEntity()

        if originEnt:IsWeapon() and originEnt:GetOwner() == LocalPlayer() then return end

        local soundChannel = netReadUInt( 9 )
        local soundPitch = netReadUInt( 8 )
        local soundLevel = netReadUInt( 9 )
        local soundFlags = netReadUInt( 11 )
        local soundVolume = netReadFloat()

        self:PlaySoundFor( originEnt, soundName, soundLevel, soundPitch, soundVolume, soundChannel, soundFlags )
    end
end

if SERVER then
    local RecipientFilter = RecipientFilter
    local netStart = net.Start
    local netWriteString = net.WriteString
    local netWriteEntity = net.WriteEntity
    local netWriteUInt = net.WriteUInt
    local netWriteFloat = net.WriteFloat
    local netSend = net.Send

    local throttleSoundForEnt = CFCEarmuffs.SoundThrottler.throttleSoundForEnt

    local function findSoundTriggerer( soundData )
        local originEnt = rawget(soundData, "Entity")

        if originEnt:IsPlayer() then return originEnt end

        local owner = originEnt:GetOwner()
        local hasValidOwner = IsValid( owner ) and owner:IsPlayer()
        if hasValidOwner then return owner end

        local cppiOwner = originEnt:CPPIGetOwner()
        local hasValidCPPIOwner = IsValid( cppiOwner ) and cppiOwner:IsPlayer()
        if hasValidCPPIOwner then return cppiOwner end

        -- TODO: What now?
   end

   local shouldThrottleSoundForEnt = CFCEarmuffs.SoundThrottler.shouldThrottleSoundForEnt
   CFCEarmuffs.Utils.broadcastEntityEmitSound = function( soundData )
        local soundName = rawget(soundData, "SoundName")
        local originEnt = rawget(soundData, "Entity")
        local soundPos = rawget(soundData, "Pos") or originEnt:GetPos()
        local soundChannel = rawget(soundData, "Channel") or CHAN_AUTO
        local soundPitch = rawget(soundData, "Pitch") or 100
        local soundLevel = rawget(soundData, "SoundLevel") or 75
        local soundVolume = rawget(soundData, "Volume") or 1
        local soundFlags = rawget(soundData, "Flags") or 0

        if not IsValid( originEnt ) then return end

        if shouldThrottleSoundForEnt( soundName, originEnt ) then
            Logger:debug("Discarding throttled sound: '" .. soundName .. "'")
            return false
        end

        local unreliable = true

        local soundTriggerer = findSoundTriggerer( soundData )
        local recipientFilter = RecipientFilter()
        recipientFilter:AddPAS( soundPos )

        if soundTriggerer then
            recipientFilter:RemovePlayer( soundTriggerer )
        end

        netStart( "CFC_Earmuffs_OnEntityEmitSound", unreliable )
            netWriteString( soundName )
            netWriteEntity( originEnt )

            -- Min: -1, Max: 136. 9 bits
            netWriteUInt( soundChannel, 9 )

            -- Min: 0, Max: 255, 8 bits
            netWriteUInt( soundPitch, 8 )

            -- Min: 0, Max: 511, 9 bits
            netWriteUInt( soundLevel, 9 )

            netWriteUInt( soundFlags, 11 )

            netWriteFloat( soundVolume )
        netSend( recipientFilter:GetPlayers() )

        throttleSoundForEnt( soundName, originEnt )

        return false
    end
end
