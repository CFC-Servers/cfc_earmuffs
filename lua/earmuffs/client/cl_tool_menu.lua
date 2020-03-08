local settings = CFCEarmuffs.Settings

local menuOptionHook = "CFC_Earmuffs_VolumeMenu"

hook.Add( "PopulateToolMenu", menuOptionHook, function()
    spawnmenu.AddToolMenuOption( "Options", "CFC", "Sound Control", "Sound Control", "", "", function( panel )
        panel:ClearControls()

        local CombatSoundSlider = vgui.Create( "DNumSlider", panel )
        local settingName = "CombatVolumeMult"

        CombatSoundSlider:SetText( "Combat Sound Volume" )
        CombatSoundSlider:Dock( TOP )
        CombatSoundSlider:SetMinMax( 0, 100 )
        CombatSoundSlider:SetDecimals( 0 )
        CombatSoundSlider:SetValue( settings[settingName] * 100 )
        CombatSoundSlider.OnValueChanged = function( _, newValue )
            settings.pendingSettingsUpdate[settingName] = newValue

            -- Start, or restart if already running
            timer.Start( settings.updateSettingsTimer )
        end
    end )
end )
