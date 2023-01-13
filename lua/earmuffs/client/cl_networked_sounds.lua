AddCSLuaFile()

local logger = CFCEarmuffs.logger
local utils = CFCEarmuffs.Utils
local ReceiveEmitSound = utils.ReceiveEmitSound

net.Receive( "CFC_Earmuffs_OnEntityEmitSound", ReceiveEmitSound )
logger:debug( "Networked Sounds module loaded" )
