AddCSLuaFile()

local rawget = rawget
local logger = CFCEarmuffs.logger
local settings = CFCEarmuffs.Settings
local utils = CFCEarmuffs.Utils
local ReceiveEmitSound = utils.ReceiveEmitSound

local function receiveNetworkedSound()
    logger:debug( "Received networked sound!" )

    if rawget( settings, "CombatVolumeMult" ) == 0 then return end

    ReceiveEmitSound()
end

net.Receive( "CFC_Earmuffs_OnEntityEmitSound", receiveNetworkedSound )
logger:debug( "Networked Sounds module loaded" )
