AddCSLuaFile()

local logger = CFCEarmuffs.logger
local settings = CFCEarmuffs.Settings
local utils = CFCEarmuffs.Utils

local function receiveNetworkedSound()
    logger:debug( "Received networked sound!" )

    if settings.CombatVolumeMult == 0 then return end

    utils:ReceiveEmitSound()
end

net.Receive( "CFC_Earmuffs_OnEntityEmitSound", receiveNetworkedSound )

logger:debug( "Networked Sounds module loaded" )
