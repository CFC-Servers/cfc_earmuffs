local isImpactSound = {
    ["dirt.bulletimpact"] = true,
    ["concrete.bulletimpact"] = true,
    ["tile.bulletimpact"] = true,
    ["solidmetal.bulletimpact"] = true,
    ["drywall.impacthard"] = true,
    ["flesh.bulletimpact"] = true,
    ["wood.bulletimpact"] = true
}

local isShellSound = {
    ["player/pl_shell1.wav"] = true,
    ["player/pl_shell2.wav"] = true,
    ["player/pl_shell3.wav"] = true
}

local function isCombatSound( soundData )
    -- Remove weird extra characters that get added in here
    local soundName = string.Replace( soundData.SoundName, ")", "" )
    soundName = string.Replace( soundName, "^", "" )
    soundName = string.Replace( soundName, "<", "" )
    soundName = string.lower( soundName )

    local originalName = soundData.OriginalSoundName
    originalName = string.lower( originalName )

    if string.StartWith( soundName, "weapon" ) then return true end
    if string.StartWith( soundName, "npc" ) then return true end
    if string.StartWith( soundName, "ambient/explosions" ) then return true end
    if string.StartWith( soundName, "cw" ) then return true end

    if string.StartWith( originalName, "weapon" ) then return true end
    if string.StartWith( originalName, "flesh" ) then return true end
    if string.StartWith( originalName, "metal" ) then return true end
    if string.StartWith( originalName, "cw_" ) then return true end

    if isImpactSound[originalName] then return true end
    if isShellSound[soundName] then return true end
end
--    -- Bigcity ambiance
--    "ambient/misc/car2.wav",
--    "ambient/misc/truck_drive1.wav",
--    "ambient/misc/truck_drive2.wav",
--    "ambient/machines/truck_pass_distant2.wav",
--    "ambient/atmosphere/city_truckpass1.wav",
--    "ambient/levels/streetwar/apc_distant1.wav",
--    "ambient/levels/streetwar/apc_distant2.wav",
--    "ambient/machines/aircraft_distant_flyby3.wav",
--    "ambient/machines/aircraft_distant_flyby1.wav",
--    "ambient/alarms/apc_alarm_pass1.wav",
--    "ambient/misc/car1.wav",
--    "ambient/misc/ambulance1.wav",
--    "ambient/creatures/pigeon_idle4.wav",
--    "ambient/overhead/hel1.wav",
--    "ambient/overhead/hel2.wav",
--    "ambient/levels/streetwar/heli_distant1.wav",
--    "ambient/animal/dog1.wav",
--    "ambient/animal/dog2.wav",
--    "ambient/animal/dog3.wav",
--    "ambient/animal/dog4.wav",
--    "ambient/animal/dog5.wav",
--    "ambient/animal/dog6.wav",
--    "ambient/animal/dog7.wav",
--    "ambient/alarms/scanner_alert_pass1.wav",
--    "ambient/misc/police1.wav",
--    "ambient/machines/train_horn_1.wav",
--    "ambient/machines/train_horn_2.wav",
--    "ambient/misc/carhonk1.wav",

local hookNameBase = "CFC_Earmuffs"
local emitSoundHook = hookNameBase .. "_OnEmitSound"
local menuOptionHook = hookNameBase .. "_CombatVolumeMenu"
local weaponSwitchHook = hookNameBase .. "_OnWeaponSwitch"

local combatSoundVolumeMult = 0.2

-- TODO: Store this result in a var and use pvp change hooks
local function isInBuild()
    return not LocalPlayer():GetNWBool( "CFC_PvP_Mode", false )
end

local function modifyCombatSound( volume )
    -- If no sound is provided, just assume 0.2 (default is 1 so we're being quieter by default)
    return (volume or 0.2) * combatSoundVolumeMult
end

local function shouldPlayCombatSound( soundData )
    if not isCombatSound( soundData ) then return end

    --local plyInBuild = isInBuild()
    -- TODO: Set this back to funtion call
    local plyInBuild = true

    if plyInBuild then
        local soundVolume = soundData.Volume

        print( "Received combat sound ('" .. soundData.SoundName .. "'), adjusting as follows: " )

        local newVolume = modifyCombatSound( soundVolume )

        print( "Changing volume from '" .. tostring( soundVolume )  .. "' to '" .. tostring( newVolume )  .. "' (Sound multiplier at: " .. tostring( combatSoundVolumeMult ) .. ")" )
        soundData.Volume = newVolume

        return true
    end
end

hook.Add( "EntityEmitSound", emitSoundHook, shouldPlayCombatSound )

hook.Add( "PopulateToolMenu", menuOptionHook, function()
    spawnmenu.AddToolMenuOption( "Options", "CFC", "Sound Control", "Sound Control", "", "", function( panel )
        panel:ClearControls()

        local CombatSoundSlider = vgui.Create( "DNumSlider", panel )
        CombatSoundSlider:SetText( "Combat Sound Volume" )
        CombatSoundSlider:Dock( TOP )
        CombatSoundSlider:SetMinMax( 0, 100 )
        CombatSoundSlider:SetDecimals( 0 )
        CombatSoundSlider:SetValue( combatSoundVolumeMult * 100 )
        CombatSoundSlider.OnValueChanged = function( _, newValue )
            combatSoundVolumeMult = newValue / 100
        end
    end )
end )

hook.Add( "PlayerSwitchWeapon", weaponSwitchHook, function( ply, oldWep, newWep )
    if not ( IsValid( newWep ) ) then return end

    if ( newWep.Primary ) then
        newWep.Primary.SoundLevel = combatSoundVolumeMult * 80
    end

    if ( newWep.Secondary ) then
        newWep.Secondary.SoundLevel = combatSoundVolumeMult * 80
    end
end )

local function playSoundFor(originEnt, soundName, soundLevel, pitchPercent, volume, channel)
    volume = volume or 1

    print("Received Entity sound from Server ('" .. soundName .. "'), adjusting as follows: ")

    local newVolume = modifyCombatSound(volume)

    print( "Changing volume from '" .. tostring( volume )  .. "' to '" .. tostring( newVolume )  .. "' (Sound multiplier at: " .. tostring( combatSoundVolumeMult ) .. ")" )

    originEnt:EmitSound(soundName, soundLevel, pitchPercent, newVolume, channel)
end

local function receiveWeaponSound()
    if combatSoundVolumeMult == 0 then return end

    local originWeapon = net.ReadEntity()
    if not originWeapon or not IsValid( originWeapon ) then return end
    if originWeapon:GetOwner() == LocalPlayer() then return end

    local soundName = net.ReadString()

    -- Max value of 511, 9 bits
    local soundLevel = net.ReadUInt( 9 )

        -- Max value of 255, 8 bits
    local pitchPercent = net.ReadUInt( 8 )

    -- Max value of 100, 7 bits
    local volume = net.ReadUInt( 7 )
    if volume == 0 then return end
    -- Sent as a UInt to save space(maybe?), but is actually a float between 0-1
    volume = volume / 100

        -- Min value of -1, max value of 136, 9 bits
    local channel = net.ReadInt( 9 )

    playSoundFor( originWeapon, soundName, soundLevel, pitchPercent, volume, channel )
end
net.Receive( hookNameBase .. "_OnWeaponSound", receiveWeaponSound )

local function receiveDefaultWeaponSound()
    if combatSoundVolumeMult == 0 then return end

    local originWeapon = net.ReadEntity()
    if not originWeapon or not IsValid( originWeapon ) then return end
    if originWeapon:GetOwner() == LocalPlayer() then return end

    local soundName = net.ReadString()

    playSoundFor( originWeapon, soundName )
end
net.Receive( hookNameBase .. "_OnDefaultWeaponSound", receiveDefaultWeaponSound )

local function receiveHL2SwepSound()
    if combatSoundVolumeMult == 0 then return end

    local soundName = net.ReadString()
    local originEnt = net.ReadEntity()
    local soundLevel = 75 -- Force all HL2 SWEPs to be sound level of 75

    playSoundFor( originEnt, soundName, soundLevel )
end
net.Receive( hookNameBase .. "_OnHL2SwepSound", receiveHL2SwepSound )
