AddCSLuaFile()

local settings = CFCEarmuffs.Settings

hook.Add( "PopulateToolMenu", "CFC_Earmuffs_PopulateToolMenu", function()
    spawnmenu.AddToolMenuOption( "Options", "CFC", "Sound Control", "Sound Control", "", "", function( panel )
        panel:ClearControls()

        local settingName

        local CombatSoundSlider = vgui.Create( "DNumSlider", panel )
        settingName = "CombatVolumeMult"

        CombatSoundSlider:SetText( "Combat Sound Volume" )
        CombatSoundSlider:Dock( TOP )
        CombatSoundSlider:SetMinMax( 0, 100 )
        CombatSoundSlider:SetDecimals( 0 )
        CombatSoundSlider:SetValue( settings[settingName] * 100 )
        CombatSoundSlider.OnValueChanged = function( _, newValue )
            settings:ReceivePreferenceUpdate( settingName, newValue )
        end

        local AmbianceSoundSlider = vgui.Create( "DNumSlider", panel )
        settingName = "AmbianceVolumeMult"

        CombatSoundSlider:SetText( "Ambient Sound Volume" )
        CombatSoundSlider:Dock( TOP )
        CombatSoundSlider:SetMinMax( 0, 100 )
        CombatSoundSlider:SetDecimals( 0 )
        CombatSoundSlider:SetValue( settings[settingName] * 100 )
        CombatSoundSlider.OnValueChanged = function( _, newValue )
            settings:ReceivePreferenceUpdate( settingName, newValue )
        end
    end )
end )
