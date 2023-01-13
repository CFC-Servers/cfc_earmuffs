AddCSLuaFile()

local settings = CFCEarmuffs.Settings

hook.Add( "PopulateToolMenu", "CFC_Earmuffs_PopulateToolMenu", function()
    spawnmenu.AddToolMenuOption( "Options", "CFC", "Sound Control", "Sound Control", "", "", function( panel )
        panel:ClearControls()

        do
            local settingName = "CombatVolumeMult"
            local CombatSoundSlider = panel:NumSlider( "Combat Sound Volume", nil, 0, 100, 0 )

            CombatSoundSlider:SetValue( settings[settingName] * 100 )
            CombatSoundSlider.OnValueChanged = function( _, newValue )
                settings:ReceivePreferenceUpdate( settingName, newValue )
            end
        end

        panel:Help( "" )

        do
            panel:Help( "The Sound Level determines how far away a sound can be heard" )
            local settingName = "CombatLevelMult"
            local CombatLevelSlider = panel:NumSlider( "Combat Sound Level", nil, 0, 100, 0 )

            CombatLevelSlider:SetValue( settings[settingName] * 100 )
            CombatLevelSlider.OnValueChanged = function( _, newValue )
                settings:ReceivePreferenceUpdate( settingName, newValue )
            end
        end

        panel:Help( "Sometimes you need to reset all sounds for these settings to take effect" )
        panel:Button( "Reset Sounds", "stopsound" )
    end )
end )
