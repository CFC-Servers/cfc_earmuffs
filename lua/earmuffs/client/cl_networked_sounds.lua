AddCSLuaFile()

local rawget = rawget
local logger = CFCEarmuffs.logger
local SettingsGet = CFCEarmuffs.Settings.Get
local utils = CFCEarmuffs.Utils
local ReceiveEmitSound = utils.ReceiveEmitSound

local function receiveNetworkedSound()
    logger:debug( "Received networked sound!" )

    if SettingsGet( "CombatVolumeMult" ) == 0 then return end

    ReceiveEmitSound()
end

net.Receive( "CFC_Earmuffs_OnEntityEmitSound", receiveNetworkedSound )
logger:debug( "Networked Sounds module loaded" )
