util.AddNetworkString( "CFC_Earmuffs_OnWeaponSound" )
util.AddNetworkString( "CFC_Earmuffs_OnDefaultWeaponSound" )

local utils = CFCEarmuffs.Utils
local weaponMeta = FindMetaTable( "Weapon" )
local broadcastEntityEmitSound = utils.broadcastEntityEmitSound
local CHAN_WEAPON = CHAN_WEAPON

function weaponMeta:EmitSound( soundName, soundLevel, soundPitch, soundVolume, soundChannel )
    local soundData = {
        SoundName = soundName,
        Entity = self,
        SoundLevel = soundLevel or 50,
        Pitch = soundPitch or 100,
        Volume = soundVolume or 0.5,
        Channel = soundChannel or CHAN_WEAPON
    }

    broadcastEntityEmitSound( soundData )
end
