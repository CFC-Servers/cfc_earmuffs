AddCSLuaFile()

local settings = CFCEarmuffs.Settings
local black = Color( 0, 0, 0, 255 )

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

        do
            local settingName = "AmbianceVolumeMult"
            local AmbianceSoundSlider = panel:NumSlider( "Ambient Sound Volume", nil, 0, 100, 0 )

            AmbianceSoundSlider:SetValue( settings[settingName] * 100 )
            AmbianceSoundSlider.OnValueChanged = function( _, newValue )
                settings:ReceivePreferenceUpdate( settingName, newValue )
            end
        end

        panel:Help( "" )

        panel:Help( "Sometimes you need to reset all sounds for these settings to take effect" )
        panel:Button( "Reset Sounds", "stopsound" )
    end )
end )
