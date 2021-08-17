AddCSLuaFile()

CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.Utils = CFCEarmuffs.Utils or {}

local RecipientFilter = RecipientFilter
local stringReplace = string.Replace
local stringRight = string.Right
local stringLen = string.len
local stringLower = string.lower
local EmitSound = EmitSound
local rawget = rawget
local rawset = rawset

local IsValid = IsValid

local Settings = CFCEarmuffs.Settings
local Logger = CFCEarmuffs.logger

if SERVER then
    util.AddNetworkString( "CFC_Earmuffs_OnEntityEmitSound" )
end

local cleanCache = {}

CFCEarmuffs.Utils.CleanSoundName = function( soundName, maintainCase )
    local cached = rawget( cleanCache, soundName )

    if not cached then
        local cleanSound = soundName
        cleanSound = stringReplace( cleanSound, ")", "" )
        cleanSound = stringReplace( cleanSound, "^", "" )
        cleanSound = stringReplace( cleanSound, "<", "" )

        -- Leading slash for some reason
        if cleanSound[1] == "/" then
            -- Get everything after the leading slash
            cleanSound = stringRight( cleanSound, stringLen( cleanSound ) - 1 )
        end

        rawset( cleanCache, soundName, cleanSound )
        cached = cleanSound
    end

    if maintainCase then return cached end

    return stringLower( cached )
end

CFCEarmuffs.Utils.modifyCombatVolume = function( soundVolume )
    local mult = rawget( Settings, "CombatVolumeMult" ) or 1
    local newVolume = soundVolume * mult

    Logger:debug(
        "Received volume: '" .. soundVolume .. "' augmenting it with multiplier ('" .. mult .. "') to receive '" .. newVolume .. "'"
    )

    return newVolume
end
local modifyCombatVolume = CFCEarmuffs.Utils.modifyCombatVolume

CFCEarmuffs.Utils.modifyCombatSoundLevel = function( soundLevel )
    local newSoundLevel = soundLevel * rawget( Settings, "CombatVolumeMult" )

    return newSoundLevel
end
local modifyCombatSoundLevel = CFCEarmuffs.Utils.modifyCombatSoundLevel

function CFCEarmuffs.Utils.PlaySoundFor( originEnt, soundName, soundLevel, soundPitch, volume, soundChannel, soundFlags )
    if not IsValid( originEnt ) then return end

    local newVolume = modifyCombatVolume( volume )
    local newSoundLevel = modifyCombatSoundLevel( soundLevel )

    EmitSound( soundName, originEnt:GetPos(), originEnt:EntIndex(), soundChannel, newVolume, newSoundLevel, soundFlags, soundPitch )
end
local playSoundFor = CFCEarmuffs.Utils.PlaySoundFor

if CLIENT then
    local LocalPlayer = LocalPlayer

    local ReadUInt = net.ReadUInt
    local ReadString = net.ReadString
    local ReadEntity = net.ReadEntity
    local ReadFloat = net.ReadFloat

    function CFCEarmuffs.Utils.ReceiveEmitSound()
        local soundName = ReadString()
        local originEnt = ReadEntity()

        if originEnt:IsWeapon() and originEnt:GetOwner() == LocalPlayer() then return end

        local soundChannel = ReadUInt( 9 )
        local soundPitch = ReadUInt( 8 )
        local soundLevel = ReadUInt( 9 )
        local soundFlags = ReadUInt( 11 )
        local soundVolume = ReadFloat()

        playSoundFor( originEnt, soundName, soundLevel, soundPitch, soundVolume, soundChannel, soundFlags )
    end
end

if SERVER then

    local WriteString = net.WriteString
    local WriteEntity = net.WriteEntity
    local WriteUInt = net.WriteUInt
    local WriteFloat = net.WriteFloat
    local unreliable = true

    local function findSoundTriggerer( originEnt )
        if originEnt:IsPlayer() then return originEnt end

        local owner = originEnt:GetOwner()
        local hasValidOwner = IsValid( owner ) and owner:IsPlayer()
        if hasValidOwner then return owner end

        return originEnt:CPPIGetOwner()
        -- local cppiOwner = originEnt:CPPIGetOwner()
        -- local hasValidCPPIOwner = IsValid( cppiOwner ) and cppiOwner:IsPlayer()
        -- if hasValidCPPIOwner then return cppiOwner end

        -- TODO: What now?
   end

   local shouldThrottleSoundForEnt = CFCEarmuffs.SoundThrottler.shouldThrottleSoundForEnt
   local throttleSoundForEnt = CFCEarmuffs.SoundThrottler.throttleSoundForEnt

   CFCEarmuffs.Utils.broadcastEntityEmitSound = function( soundData )
       local soundName = rawget( soundData, "SoundName" )
       local originEnt = rawget( soundData, "Entity" )
       local soundPos = rawget( soundData, "Pos" ) or originEnt:GetPos()
       local soundChannel = rawget( soundData, "Channel" ) or CHAN_AUTO
       local soundPitch = rawget( soundData, "Pitch" ) or 100
       local soundLevel = rawget( soundData, "SoundLevel" ) or 75
       local soundVolume = rawget( soundData, "Volume" ) or 1
       local soundFlags = rawget( soundData, "Flags" ) or 0

       if not IsValid( originEnt ) then return end

       if shouldThrottleSoundForEnt( soundName, originEnt ) then
           Logger:debug("Discarding throttled sound: '" .. soundName .. "'")
           return false
       end

       local soundTriggerer = findSoundTriggerer( originEnt )
       local recipientFilter = RecipientFilter()
       recipientFilter:AddPAS( soundPos )

       if soundTriggerer then
           recipientFilter:RemovePlayer( soundTriggerer )
       end

       net.Start( "CFC_Earmuffs_OnEntityEmitSound", unreliable )
           WriteString( soundName )
           WriteEntity( originEnt )

           -- Min: -1, Max: 136. 9 bits
           WriteUInt( soundChannel, 9 )

           -- Min: 0, Max: 255, 8 bits
           WriteUInt( soundPitch, 8 )

           -- Min: 0, Max: 511, 9 bits
           WriteUInt( soundLevel, 9 )

           WriteUInt( soundFlags, 11 )

           WriteFloat( soundVolume )
       net.Send( recipientFilter:GetPlayers() )

       throttleSoundForEnt( soundName, originEnt )

       return false
   end
end
