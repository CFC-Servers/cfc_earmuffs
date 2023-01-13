util.AddNetworkString( "CFC_Earmuffs_OnWeaponSound" )
util.AddNetworkString( "CFC_Earmuffs_OnDefaultWeaponSound" )

local utils = CFCEarmuffs.Utils
local weaponMeta = FindMetaTable( "Weapon" )
local broadcastEntityEmitSound = utils.broadcastEntityEmitSound
local CHAN_WEAPON = CHAN_WEAPON

local soundData

function weaponMeta:EmitSound( soundName, soundLevel, soundPitch, soundVolume, soundChannel )
    soundData = {
        SoundName = soundName,
        Entity = self,
        SoundLevel = soundLevel or 75,
        Pitch = soundPitch or 100,
        Volume = soundVolume or 1,
        Channel = soundChannel or CHAN_WEAPON
    }

    broadcastEntityEmitSound( soundData )
end
