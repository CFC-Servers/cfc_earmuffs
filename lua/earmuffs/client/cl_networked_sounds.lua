AddCSLuaFile()

local logger = CFCEarmuffs.logger

local function receiveNetworkedSound()
    logger:debug( "Received networked sound!" )

    if CFCEarmuffs.Settings.CombatVolumeMult == 0 then return end

    CFCEarmuffs.Utils:ReceiveEmitSound()
end

net.Receive( "CFC_Earmuffs_OnEntityEmitSound", receiveNetworkedSound )

logger:debug( "Networked Sounds module loaded" )
