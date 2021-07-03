CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.SoundThrottler = CFCEarmuffs.SoundThrottler or {}

-- Stores Entities to tables of Sound Names to time values (next time that sound can be transmitted)
CFCEarmuffs.SoundThrottler.Throttle = {}
local Throttle = CFCEarmuffs.SoundThrottler.Throttle

local SysTime = SysTime
local rawset = rawset
local rawget = rawget

local entEmitInterval = CFCEarmuffs.Config.ENT_EMIT_INTERVAL

CFCEarmuffs.SoundThrottler.throttleSoundForEnt = function( soundName, originEnt )
    local nextSoundPlay = SysTime() + entEmitInterval
    local throttleData = rawget( Throttle, originEnt )

    if throttleData then
        rawset( throttleData, soundName, nextSoundPlay )
    else
        rawset( Throttle, originEnt, {[soundName] = nextSoundPlay} )
    end
end

CFCEarmuffs.SoundThrottler.shouldThrottleSoundForEnt = function( soundName, originEnt )
    local throttledEnt = rawget( Throttle, originEnt )

    if not throttledEnt then return end

    local nextSoundPlay = rawget( throttledEnt, soundName )
    if nextSoundPlay and nextSoundPlay > SysTime() then return true end
end

local function groomThrottler()
    for originEnt, throttleData in pairs( Throttle ) do
        if IsValid( originEnt ) then
            for soundName, nextPlay in pairs( throttleData ) do
                if nextPlay <= SysTime() then
                    rawset( throttleData, soundName, nil )
                end
            end
        else
            rawset( Throttle, originEnt, nil )
        end
    end
end

timer.Create("CFC_Earmuffs_GroomThrottle", 5, -1, groomThrottler)
