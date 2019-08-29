local isCombatSound = {

}

local hookName = "CFC_CombatEarmuffs"

local combatSoundVolumeMult = 0.2

-- TODO: Store this result in a var and use pvp change hooks
local function isInPvp()
    return LocalPlayer():GetNWBool( "CFC_PvP_Mode", false )
end

local function shouldPlayCombatSound( soundData )
    local soundName = soundData.SoundName
    if not isCombatSound[soundName] then return end

    if isInPvp() then
        local volume = soundData.Volume
        soundData.Volume = volume * combatSoundVolumeMult

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
