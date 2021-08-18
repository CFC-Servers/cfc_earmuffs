AddCSLuaFile()

local rawget = rawget
local logger = CFCEarmuffs.logger
local SettingsGet = CFCEarmuffs.Settings.Get
local IsValid = IsValid

hook.Add( "PlayerSwitchWeapon", "CFC_Earmuffs_OnPlayerSwitchWeapon", function( ply, oldWep, newWep )
    if not( IsValid( newWep ) ) then return end

    local multiplier = SettingsGet( "CombatVolumeMult" ) * 100

    if ( newWep.Primary ) then
        newWep.Primary.SoundLevel = multiplier
    end

    if ( newWep.Secondary ) then
        newWep.Secondary.SoundLevel = multiplier
    end
end )

logger:debug( "SWEPS module loaded" )
