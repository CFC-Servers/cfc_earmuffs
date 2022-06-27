AddCSLuaFile()

local settings = CFCEarmuffs.Settings

hook.Add( "PopulateToolMenu", "CFC_Earmuffs_PopulateToolMenu", function()
    spawnmenu.AddToolMenuOption( "Options", "CFC", "Sound Control", "Sound Control", "", "", function( panel )
        panel:ClearControls()

        do
            local settingName = "CombatVolumeMult"
            local CombatSoundSlider = vgui.Create( "DNumSlider", panel )

            CombatSoundSlider:SetText( "Combat Sound Volume" )
            CombatSoundSlider:Dock( TOP )
            CombatSoundSlider:SetMinMax( 0, 100 )
            CombatSoundSlider:SetDecimals( 0 )
            CombatSoundSlider:SetValue( settings[settingName] * 100 )
            CombatSoundSlider.OnValueChanged = function( _, newValue )
                settings:ReceivePreferenceUpdate( settingName, newValue )
            end
        end

        do
            local settingName = "AmbianceVolumeMult"
            local AmbianceSoundSlider = vgui.Create( "DNumSlider", panel )

            AmbianceSoundSlider:SetText( "Ambient Sound Volume" )
            AmbianceSoundSlider:Dock( TOP )
            AmbianceSoundSlider:SetMinMax( 0, 100 )
            AmbianceSoundSlider:SetDecimals( 0 )
            AmbianceSoundSlider:SetValue( settings[settingName] * 100 )
            AmbianceSoundSlider.OnValueChanged = function( _, newValue )
                settings:ReceivePreferenceUpdate( settingName, newValue )
            end
        end
    end )
end )
