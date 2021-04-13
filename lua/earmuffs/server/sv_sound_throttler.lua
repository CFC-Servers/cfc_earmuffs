CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.SoundThrottler = CFCEarmuffs.SoundThrottler or {}

-- Stores Entities to tables of Sound Names to time values (next time that sound can be transmitted)
local throttle = {}

local rawget = rawget
local rawset = rawset
local pairs = pairs
local IsValid = IsValid
local SysTime = SysTime
local entEmitInterval = CFCEarmuffs.Config.ENT_EMIT_INTERVAL

CFCEarmuffs.SoundThrottler.throttleSoundForEnt = function( soundName, originEnt )
    local nextSoundPlay = SysTime() + entEmitInterval

    rawset(throttle, originEnt, rawget(throttle, originEnt) or {})
    rawset(rawget(throttle, originEnt), soundName, nextSoundPlay)
end

CFCEarmuffs.SoundThrottler.shouldThrottleSoundForEnt = function( soundName, originEnt )
    local throttledEnt = rawget(throttle, originEnt)

    if throttledEnt then
        local nextSoundPlay = rawget(throttledEnt, soundName)

        if nextSoundPlay and nextSoundPlay > SysTime() then return true end
    end
end

local function groomThrottler()
    for originEnt, throttleData in pairs( throttle ) do
        local entIsValid = IsValid( originEnt )

        for soundName, nextPlay in pairs( throttleData ) do
            -- If the entity is invalid, responsibly clear the memory
            -- Or if it's no longer being throttled, clear it
            if (not entIsValid) or nextPlay <= SysTime() then
                rawset(throttleData, soundName, nil)
            end
        end

        if not entIsValid then
            rawset(throttle, originEnt, nil)
        end
    end
end

timer.Create("CFC_Earmuffs_GroomThrottle", 5, -1, groomThrottler)
