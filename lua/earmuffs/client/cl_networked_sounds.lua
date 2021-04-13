AddCSLuaFile()

local logger = CFCEarmuffs.logger
local netReceive = net.Receive
local rawget = rawget

local function receiveNetworkedSound()
    logger:debug( "Received networked sound!" )

    if rawget(rawget(CFCEarmuffs, "Settings"), "CombatVolumeMult") == 0 then return end

    rawget(CFCEarmuffs, "Utils"):ReceiveEmitSound()
end

netReceive( "CFC_Earmuffs_OnEntityEmitSound", receiveNetworkedSound )

logger:debug( "Networked Sounds module loaded" )
