CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.SoundThrottler = CFCEarmuffs.SoundThrottler or {}

-- Stores Entities to tables of Sound Names to time values (next time that sound can be transmitted)
CFCEarmuffs.SoundThrottler.Throttle = {}

CFCEarmuffs.SoundThrottler.throttleSoundForEnt = function( soundName, originEnt )
    local nextSoundPlay = SysTime() + EMIT_INTERVAL

    CFCEarmuffs.SoundThrottler.Throttle[originEnt] = CFCEarmuffs.SoundThrottler.Throttle[originEnt] or {}
    CFCEarmuffs.SoundThrottler.Throttle[originEnt][soundName] = nextSoundPlay
end

CFCEarmuffs.SoundThrottler.shouldThrottleSoundForEnt = function( soundName, originEnt )
    local throttledEnt = CFCEarmuffs.SoundThrottler.Throttle[originEnt]

    if throttledEnt then
        local nextSoundPlay = throttledEnt[soundName]

        if nextSoundPlay and nextSoundPlay > SysTime() then return true end
    end
end

local function groomThrottler()
    for originEnt, throttleData in pairs( CFCEarmuffs.SoundThrottler.Throttle ) do
        if IsValid( originEnt ) then
            for soundName, nextPlay in pairs( throttleData ) do
                if nextPlay <= SysTime() then
                    throttleData[soundName] = nil
                end
            end
        else
            CFCEarmuffs.SoundThrottler.Throttle[originEnt] = nil
        end
    end
end

timer.Create("CFC_Earmuffs_GroomThrottle", 5, -1, groomThrottler)
