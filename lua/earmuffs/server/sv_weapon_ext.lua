util.AddNetworkString( "CFC_Earmuffs_OnWeaponSound" )
util.AddNetworkString( "CFC_Earmuffs_OnDefaultWeaponSound" )

local rawset = rawset
local CHAN_WEAPON = CHAN_WEAPON

local broadcastEntityEmitSound = CFCEarmuffs.Utils.broadcastEntityEmitSound
local weaponMeta = FindMetaTable( "Weapon" )
local soundData = {}

function weaponMeta:EmitSound( soundName, soundLevel, soundPitch, soundVolume, soundChannel )
    rawset( soundData, "SoundName", soundName )
    rawset( soundData, "Entity", self )
    rawset( soundData, "SoundLevel", soundLevel or 50 )
    rawset( soundData, "Pitch", soundPitch or 100 )
    rawset( soundData, "Volume", soundVolume or 0.5 )
    rawset( soundData, "Channel", soundChannel or CHAN_WEAPON )

    broadcastEntityEmitSound( soundData )
end
