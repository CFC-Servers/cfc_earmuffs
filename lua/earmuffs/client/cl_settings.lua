AddCSLuaFile()

local rawget = rawget
local tostring = tostring

CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.Settings = CFCEarmuffs.Settings or {}

local Settings = CFCEarmuffs.Settings
local logger = CFCEarmuffs.logger

local SETTINGS_DEFAULTS = {
    CombatVolumeMult = 0.2,
    CombatSoundLevelMult = 0.2,
    AmbianceVolumeMult = 0.2
}

local SETTINGS_NAMES = {
    CombatVolumeMult = "CFC_Earmuffs_CombatVolumeMult",
    CombatSoundLevelMult = "CFC_Earmuffs_CombatSoundLevelMult",
    AmbianceVolumeMult = "CFC_Earmuffs_AmbianceVolumeMult"
}

local pendingSettingsUpdate = {}

updateSettingsTimer = "CFC_Earmuffs_DelayedUpdateSettings"

CFCEarmuffs.Settings.Get = function( shortcode )
    local val = rawget( Settings, shortcode )
    if val ~= nil then return val end

    return rawget( SETTINGS_DEFAULTS, shortcode )
end

timer.Create( updateSettingsTimer, 0.5, 0, function()
    CFCEarmuffs.Settings.SavePreferences( pendingSettingsUpdate )

    pendingSettingsUpdate = {}
    timer.Stop( updateSettingsTimer )
end )

CFCEarmuffs.Settings.SavePreferences = function( preferences )
    logger:debug( "Saving preferences to persistant storage" )

    for settingShortcode, settingValue in pairs( preferences ) do
        local settingName = rawget( SETTINGS_NAMES, settingShortcode )

        settingValue = tostring( settingValue )

        logger:debug( "Setting '" .. settingName .. "' to '" .. settingValue .. "'")

        cookie.Set( settingName, settingValue )
    end
end

-- Used in tool menu to update settings
function CFCEarmuffs.Settings:ReceivePreferenceUpdate( settingName, settingValue )
    -- Tool menu sends us 0-100, we want 0-1
    settingValue = settingValue / 100

    logger:debug( "Received a preference update. '" .. settingName .. "' set to '" .. settingValue .. "'" )

    -- Queue it for persistent storage update
    pendingSettingsUpdate[settingName] = settingValue

    -- Start, or restart if already running
    timer.Start( updateSettingsTimer )

    -- Update in-memory value immediately
    self[settingName] = settingValue
end

local function initialSetup()
    hook.Remove( "Think", "CFC_Earmuffs_ClientSetup" )

    logger:info( "Initializing Preferences" )

    for settingShortcode, settingName in pairs( SETTINGS_NAMES ) do
        local defaultValue = SETTINGS_DEFAULTS[settingShortcode]
        local cookieValue = cookie.GetString( settingName, defaultValue )
        cookieValue = tonumber( cookieValue )

        logger:debug( "Loaded preference '" .. settingShortcode .. "', value read as '" .. cookieValue .. "'" )

        Settings[settingShortcode] = cookieValue
    end
end

hook.Add( "Think", "CFC_Earmuffs_ClientSetup", initialSetup )
