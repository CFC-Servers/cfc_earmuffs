CFCEarmuffs = CFCEarmuffs or {}

if SERVER then
    AddCSLuaFile( "earmuffs/shared/sh_logger.lua" )
    AddCSLuaFile( "earmuffs/shared/sh_utils.lua" )
    AddCSLuaFile( "earmuffs/shared/sh_config.lua" )

    AddCSLuaFile( "earmuffs/client/cl_settings.lua" )
    AddCSLuaFile( "earmuffs/client/cl_networked_sounds.lua" )
    AddCSLuaFile( "earmuffs/client/cl_combat_sounds.lua" )
    AddCSLuaFile( "earmuffs/client/cl_sweps.lua" )
    AddCSLuaFile( "earmuffs/client/cl_tool_menu.lua" )
end

include( "earmuffs/shared/sh_logger.lua" )
include( "earmuffs/shared/sh_utils.lua" )
include( "earmuffs/shared/sh_config.lua" )

if SERVER then
    include( "earmuffs/server/sv_sound_throttler.lua" )
    include( "earmuffs/server/sv_weapon_ext.lua" )
    include( "earmuffs/server/sv_hl2_sweps.lua" )
    include( "earmuffs/server/sv_hl2_npcs.lua" )
    include( "earmuffs/server/sv_hl2_misc.lua" )
end

if CLIENT then
    include( "earmuffs/client/cl_settings.lua" )
    include( "earmuffs/client/cl_networked_sounds.lua" )
    include( "earmuffs/client/cl_combat_sounds.lua" )
    include( "earmuffs/client/cl_sweps.lua" )
    include( "earmuffs/client/cl_tool_menu.lua" )
end

CFCEarmuffs.logger:info( "Loaded!" )
