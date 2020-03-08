local function receiveNetworkedSound()
    if CFCEarmuffs.Settings.CombatVolumeMult == 0 then return end

    CFCEarmuffs.Utils:ReceiveEmitSound()
end

net.Receive( "CFC_Earmuffs_OnEntityEmitSound", receiveNetworkedSound )
