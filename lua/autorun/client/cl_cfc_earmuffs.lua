local isImpactSound = {
    "dirt.bulletimpact",
    "concrete.bulletimpact",
    "tile.bulletimpact",
    "solidmetal.bulletimpact",
    "drywall.impacthard",
    "flesh.bulletimpact",
    "wood.bulletimpact"
}

local isShellSound = {
    "player/pl_shell1.wav",
    "player/pl_shell2.wav",
    "player/pl_shell3.wav"
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


local hookName = "CFC_CombatEarmuffs"

local combatSoundVolumeMult = 0.2

-- TODO: Store this result in a var and use pvp change hooks
local function isInBuild()
    return LocalPlayer():GetNWBool( "CFC_PvP_Mode", false )
end

local function shouldPlayCombatSound( soundData )
    if not isCombatSound( soundData ) then return end

    local plyInBuild = true
    --local plyInBuild = isInBuild()

    if plyInBuild then
        print( "Received combat sound ('" .. soundData.SoundName .."'), adjusting as follows: " )

        local volume = soundData.Volume
        local newVolume = volume * combatSoundVolumeMult

        print("Changing volume from '" .. tostring( volume)  .. "' to '" .. tostring( newVolume)  .. "' (Sound multiplier at: " .. tostring( combatSoundVolumeMult ) .. ")" )
        soundData.Volume = newVolume

        return true
    end
end

hook.Remove( "EntityEmitSound", hookName )
hook.Add( "EntityEmitSound", hookName, shouldPlayCombatSound )

hook.Remove( "PopulateToolMenu", "CFC_CombatVolumeMenu" )
hook.Add( "PopulateToolMenu", "CFC_CombatVolumeMenu", function()
    spawnmenu.AddToolMenuOption( "Utilities", "CFC", "Sound Control", "Sound Control", "", "", function( panel )
        panel:ClearControls()

        local CombatSoundSlider = vgui.Create( "DNumSlider", panel )
        CombatSoundSlider:SetText( "Combat Sound Volume" )
        CombatSoundSlider:Dock( TOP )
        CombatSoundSlider:SetMinMax( 0, 100 )
        CombatSoundSlider:SetDecimals( 0 )
        CombatSoundSlider:SetValue( combatSoundVolumeMult * 100 )
        CombatSoundSlider.OnValueChanged = function( _, newValue )
            combatSoundVolumeMult = newValue == 0 and 0 or newValue / 100
        end
    end )
end )
