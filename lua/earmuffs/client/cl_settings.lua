AddCSLuaFile()

CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.Settings = CFCEarmuffs.Settings or {}
local logger = CFCEarmuffs.Logger

local SETTINGS_DEFAULTS = {
    CombatVolumeMult = 0.2,
    CombatSoundLevelMult = 0.2
}

local SETTINGS_NAMES = {
    CombatVolumeMult = "CFC_Earmuffs_CombatVolumeMult",
    CombatSoundLevelMult = "CFC_Earmuffs_CombatSoundLevelMult"
}

CFCEarmuffs.Settings.settingNames = SETTINGS_NAMES

CFCEarmuffs.Settings.pendingSettingsUpdate = {}

CFCEarmuffs.Settings.updateSettingsTimer = "CFC_Earmuffs_DelayedUpdateSettings"

timer.Create( CFCEarmuffs.Settings.updateSettingsTimer, 0.5, 0, function()
    CFCEarmuffs.Settings.SavePreferences( CFCEarmuffs.Settings.pendingSettingsUpdate )

    CFCEarmuffs.Settings.pendingSettingsUpdate = {}
    timer.Stop( CFCEarmuffs.Settings.updateSettingsTimer )
end )

CFCEarmuffs.Settings.SavePreferences = function( preferences )
    logger:debug( "Saving preferences to persistant storage" )

    for settingShortcode, settingValue in pairs( preferences ) do
        local settingName = CFCEarmuffs.Settings.settingNames[settingShortcode]

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
    self.pendingSettingsUpdate[settingName] = settingValue

    -- Start, or restart if already running
    timer.Start( self.updateSettingsTimer )

    -- Update in-memory value immediately
    self[settingName] = settingValue
end

local function initialSetup()
    logger:info( "Initializing Preferences" )

    for settingShortcode, settingName in pairs( SETTINGS_NAMES ) do
        local defaultValue = SETTINGS_DEFAULTS[settingShortcode]
        local cookieValue = cookie.GetString( settingName, defaultValue )
        cookieValue = tonumber( cookieValue )

        logger:debug( "Loaded preference '" .. settingShortcode .. "', value read as '" .. cookieValue .. "'" )

        CFCEarmuffs.Settings[settingShortcode] = cookieValue
    end

    hook.Remove( "Think", "CFC_Earmuffs_ClientSetup" )
end

hook.Add( "Think", "CFC_Earmuffs_ClientSetup", initialSetup )
