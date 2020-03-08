AddCSLuaFile()

local logger = CFCEarmuffs.logger

hook.Add( "PlayerSwitchWeapon", "CFC_Earmuffs_OnPlayerSwitchWeapon", function( ply, oldWep, newWep )
    if not ( IsValid( newWep ) ) then return end

    local multiplier = CFCEarmuffs.Settings.CombatVolumeMult

    if ( newWep.Primary ) then
        newWep.Primary.SoundLevel = multiplier * 100
    end

    if ( newWep.Secondary ) then
        newWep.Secondary.SoundLevel = multiplier * 100
    end
end )

logger:debug( "SWEPS module loaded" )
