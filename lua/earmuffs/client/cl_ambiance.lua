local rawget = rawget
local rawset = rawset

local logger = CFCEarmuffs.logger
local utils = CFCEarmuffs.Utils
local SettingsGet = CFCEarmuffs.Settings.Get

local mapAmbiance = {}

mapAmbiance["gm_bigcity_improved_lite"] = {
    ["ambient/misc/car2.wav"] = true,
    ["ambient/misc/truck_drive1.wav"] = true,
    ["ambient/misc/truck_drive2.wav"] = true,
    ["ambient/machines/truck_pass_distant2.wav"] = true,
    ["ambient/atmosphere/city_truckpass1.wav"] = true,
    ["ambient/levels/streetwar/apc_distant1.wav"] = true,
    ["ambient/levels/streetwar/apc_distant2.wav"] = true,
    ["ambient/machines/aircraft_distant_flyby3.wav"] = true,
    ["ambient/machines/aircraft_distant_flyby1.wav"] = true,
    ["ambient/alarms/apc_alarm_pass1.wav"] = true,
    ["ambient/misc/car1.wav"] = true,
    ["ambient/misc/ambulance1.wav"] = true,
    ["ambient/creatures/pigeon_idle4.wav"] = true,
    ["ambient/overhead/hel1.wav"] = true,
    ["ambient/overhead/hel2.wav"] = true,
    ["ambient/levels/streetwar/heli_distant1.wav"] = true,
    ["ambient/animal/dog1.wav"] = true,
    ["ambient/animal/dog2.wav"] = true,
    ["ambient/animal/dog3.wav"] = true,
    ["ambient/animal/dog4.wav"] = true,
    ["ambient/animal/dog5.wav"] = true,
    ["ambient/animal/dog6.wav"] = true,
    ["ambient/animal/dog7.wav"] = true,
    ["ambient/alarms/scanner_alert_pass1.wav"] = true,
    ["ambient/misc/police1.wav"] = true,
    ["ambient/machines/train_horn_1.wav"] = true,
    ["ambient/machines/train_horn_2.wav"] = true,
    ["ambient/misc/carhonk1.wav"] = true
}

mapAmbiance["gm_construct"] = {
    ["ambient/forest_day.wav"] = true,
    ["ambient/levels/forest/treewind1.wav"] = true,
    ["ambient/levels/forest/treewind2.wav"] = true,
    ["ambient/levels/forest/treewind3.wav"] = true,
    ["ambient/levels/forest/treewind4.wav"] = true,
    ["ambient/levels/forest/dist_birds1.wav"] = true,
    ["ambient/levels/forest/dist_birds2.wav"] = true,
    ["ambient/levels/forest/dist_birds3.wav"] = true,
    ["ambient/levels/forest/dist_birds4.wav"] = true,
    ["ambient/levels/forest/dist_birds5.wav"] = true,
    ["ambient/levels/forest/dist_birds6.wav"] = true,

}

local currentMapSounds = {}
hook.Add( "Initialize", "CFC_Earmuffs_MapSoundSetup", function()
    currentMapSounds = mapAmbiance[game.GetMap()] or {}
end )

local function isAmbientSound( soundData )
    local soundName = rawget( soundData, "SoundName" )
    return currentMapSounds[soundName]
end

local modifySoundVolume = utils.modifySoundVolume

local function shouldPlayAmbientSound( soundData )
    if not isAmbientSound( soundData ) then return end

    logger:debug( "Received Ambient Sound!" )

    local volumeMult = SettingsGet( "AmbianceVolumeMult" )
    if volumeMult == 0 then return false end

    local soundVolume = rawget( soundData, "Volume" )
    local newVolume = modifySoundVolume( soundVolume, volumeMult )

    rawset( soundData, "Volume", newVolume )

    return true
end

hook.Add( "EntityEmitSound", "CFC_Earmuffs_OnAmbientSound", shouldPlayAmbientSound )

logger:debug( "Ambient Sound module loaded" )
