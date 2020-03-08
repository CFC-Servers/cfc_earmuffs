CFCEarmuffs = CFCEarmuffs or {}
CFCEarmuffs.Settings = CFCEarmuffs.Settings or {}
local logger = CFCEarmuffs.logger

local SETTINGS_DEFAULTS = {
    CombatVolumeMult = 0.2
}

local SETTINGS_NAMES = {
    CombatVolumeMult = "CFC_Earmuffs_CombatVolumeMult"
}

CFCEarmuffs.Settings.settingNames = settingNames

CFCEarmuffs.Settings.pendingSettingsUpdate = {}

CFCEarmuffs.Settings.updateSettingsTimer = "CFC_Earmuffs_DelayedUpdateSettings"

timer.Create( CFCEarmuffs.Settings.updateSettingsTimer, 0.5, 0, function()
    CFCEarmuffs.Settings.SavePreferences( CFCEarmuffs.Settings.pendingSettingsUpdate )

    CFCEarmuffs.Settings.pendingSettingsUpdate = {}
    timer.Stop( CFCEarmuffs.Settings.updateSettingsTimer )
end )

local function savePreferences( preferences )
    for settingName, settingValue in pairs( preferences ) do
        -- TODO: Check valid setting name

        settingValue = tostring( settingValue )

        logger.debug( "Setting '" .. settingName .. "' to '" .. settingValue .. "'")

        cookie.Set( settingName, settingValue )
    end
end

CFCEarmuffs.Settings.savePreferences = savePreferences


local setupHookName = "CFC_Earmuffs_ClientSetup"

local function initialSetup()
    logger.info( "Initializing Preferences" )

    for settingShortcode, settingName in pairs( SETTINGS_NAMES ) do
        local defaultValue = settingsDefaults[settingShortcode]
        local cookieValue = cookie.GetString( settingName, defaultValue )
        cookieValue = tonumber( cookieValue )

        logger.debug( "Loaded preference '" .. settingShortcode .. "', value read as '" .. cookieValue .. "'" )

        CFCEarmuffs.Settings[settingShortcode] = cookieValue
    end

    local combatVolumeMult = cookie.GetString(settingNames.CombatVolumeMult, tostring( DEFAULT_COMBAT_VOLUME_MULT ) )

    combatVolumeMult = tonumber( combatVolumeMult )

    CFCEarmuffs.Settings.CombatVolumeMult = combatVolumeMult

    hook.Remove( "Think", setupHookName )
end
hook.Add( "Think", setupHookName, initialSetup )
