AddCSLuaFile()

local logger = CFCEarmuffs.logger
local settings = CFCEarmuffs.Settings
local IsValid = IsValid

hook.Add( "PlayerSwitchWeapon", "CFC_Earmuffs_OnPlayerSwitchWeapon", function( _, _, newWep )
    if not ( IsValid( newWep ) ) then return end

    local multiplier = settings.CombatVolumeMult

    if ( newWep.Primary ) then
        newWep.Primary.SoundLevel = multiplier * 100
    end

    if ( newWep.Secondary ) then
        newWep.Secondary.SoundLevel = multiplier * 100
    end
end )

logger:debug( "SWEPS module loaded" )
