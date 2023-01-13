AddCSLuaFile()

CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.Utils = CFCEarmuffs.Utils or {}

local rawget = rawget
local rawset = rawset
local isstring = isstring
local EmitSound = EmitSound

local string_len = string.len
local string_lower = string.lower
local string_right = string.Right
local string_replace = string.Replace

local IsValid = IsValid
local logger = CFCEarmuffs.logger
local utils = CFCEarmuffs.Utils

if SERVER then
    util.AddNetworkString( "CFC_Earmuffs_OnEntityEmitSound" )
end

local SettingsGet
if CLIENT then
    SettingsGet = CFCEarmuffs.Settings.Get
end


local cleanCache = {}
utils.CleanSoundName = function( soundName, maintainCase )
    local cached = rawget( cleanCache, soundName )

    if not cached then
        local cleanSound = soundName
        cleanSound = string_replace( cleanSound, ")", "" )
        cleanSound = string_replace( cleanSound, "^", "" )
        cleanSound = string_replace( cleanSound, "<", "" )

        -- Leading slash for some reason
        if cleanSound[1] == "/" then
            -- Get everything after the leading slash
            cleanSound = string_right( cleanSound, string_len( cleanSound ) - 1 )
        end

        rawset( cleanCache, soundName, cleanSound )
        cached = cleanSound
    end

    if maintainCase then return cached end

    return string_lower( cached )
end

utils.modifySoundVolume = function( soundVolume, mult )
    if isstring( mult ) then
        mult = SettingsGet( mult )
    end

    local newVolume = soundVolume * mult

    logger:debug(
        "Received volume: '" .. soundVolume .. "' augmenting it with multiplier ('" .. mult .. "') to receive '" .. newVolume .. "'"
    )

    return newVolume
end
local modifySoundVolume = utils.modifySoundVolume

utils.modifySoundLevel = function( soundLevel, mult )
    if isstring( mult ) then
        mult = SettingsGet( mult )
    end

    return soundLevel * mult
end
local modifySoundLevel = utils.modifySoundLevel

-- FIXME: This assumes all played sounds will be Combat sounds
function utils.PlaySoundFor( originEnt, soundName, soundLevel, soundPitch, volume, soundChannel, soundFlags )
    if not IsValid( originEnt ) then return end

    local newVolume = modifySoundVolume( volume, "CombatVolumeMult" )
    local newSoundLevel = modifySoundLevel( soundLevel, "CombatLevelMult" )

    logger:debug( "Playing:", soundName, soundChannel, newVolume, newSoundLevel )
    EmitSound( soundName, originEnt:GetPos(), originEnt:EntIndex(), soundChannel, newVolume, newSoundLevel, soundFlags, soundPitch )
end
local playSoundFor = utils.PlaySoundFor

if CLIENT then
    local LocalPlayer = LocalPlayer()

    local ReadUInt = net.ReadUInt
    local ReadString = net.ReadString
    local ReadEntity = net.ReadEntity
    local ReadFloat = net.ReadFloat

    function utils.ReceiveEmitSound()
        local soundName = ReadString()
        local originEnt = ReadEntity()

        if originEnt:IsWeapon() and originEnt:GetOwner() == LocalPlayer then
            return
        end

        local soundChannel = ReadUInt( 9 )
        local soundPitch = ReadUInt( 8 )
        local soundLevel = ReadUInt( 9 )
        local soundFlags = ReadUInt( 11 )
        local soundVolume = ReadFloat()

        playSoundFor( originEnt, soundName, soundLevel, soundPitch, soundVolume, soundChannel, soundFlags )
    end
end

if SERVER then
    -- TODO: Per-tick cache of sounds to send?

    local WriteString = net.WriteString
    local WriteEntity = net.WriteEntity
    local WriteUInt = net.WriteUInt
    local WriteFloat = net.WriteFloat
    local unreliable = true

    local function _findSoundTriggerer( originEnt )
        if originEnt:IsPlayer() then return originEnt end

        local owner = originEnt:GetOwner()

        if IsValid( owner ) and owner:IsPlayer() then
            return owner
        end

        return originEnt:CPPIGetOwner()
        -- local cppiOwner = originEnt:CPPIGetOwner()
        -- local hasValidCPPIOwner = IsValid( cppiOwner ) and cppiOwner:IsPlayer()
        -- if hasValidCPPIOwner then return cppiOwner end

        -- TODO: What now?
   end

   local cachedTriggerer
   local triggererCache = {}
   local function findSoundTriggerer( originEnt )
       cachedTriggerer = rawget( triggererCache, originEnt )
       if cachedTriggerer then return cached end

       cachedTriggerer = _findSoundTriggerer( originEnt )
       rawset( triggererCache, originEnt, cachedTriggerer )

       return cachedTriggerer
   end

   local shouldThrottleSoundForEnt = CFCEarmuffs.SoundThrottler.shouldThrottleSoundForEnt
   local throttleSoundForEnt = CFCEarmuffs.SoundThrottler.throttleSoundForEnt

   local recipientFilter = RecipientFilter()
   utils.broadcastEntityEmitSound = function( soundData )
       local originEnt = rawget( soundData, "Entity" )
       if not IsValid( originEnt ) then return end

       local soundName = rawget( soundData, "SoundName" )

       if shouldThrottleSoundForEnt( soundName, originEnt ) then
           logger:debug( "Discarding throttled sound: '" .. soundName .. "'" )
           return false
       end

       local soundPos = rawget( soundData, "Pos" ) or originEnt:GetPos()
       local soundChannel = rawget( soundData, "Channel" ) or CHAN_AUTO
       local soundPitch = rawget( soundData, "Pitch" ) or 100
       local soundLevel = rawget( soundData, "SoundLevel" ) or 75
       local soundVolume = rawget( soundData, "Volume" ) or 1
       local soundFlags = rawget( soundData, "Flags" ) or 0

       local soundTriggerer = findSoundTriggerer( originEnt )
       recipientFilter:RemoveAllPlayers()
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

           -- Min: 0, Max: 2047, 11 bits
           WriteUInt( soundFlags, 11 )

           WriteFloat( soundVolume )
       net.Send( recipientFilter )

       throttleSoundForEnt( soundName, originEnt )

       return false
   end
end
