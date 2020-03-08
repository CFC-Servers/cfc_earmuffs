util.AddNetworkString( "CFC_Earmuffs_OnWeaponSound" )
util.AddNetworkString( "CFC_Earmuffs_OnDefaultWeaponSound" )

local config = CFCEarmuffs.Config
local utils = CFCEarmuffs.Utils

local weaponMeta = FindMetaTable( "Weapon" )

function weaponMeta:EmitSound( soundName, soundLevel, soundPitch, soundVolume, soundChannel )
    local soundData = {
        SoundName = soundName,
        Entity = self,
        SoundLevel = soundLevel,
        Pitch = soundPitch,
        Volume = soundVolume,
        Channel = soundChannel
    }

    utils.broadcastEntityEmitSound( soundData )
end
