CFCEarmuffs = CFCEarmuffs or {}

include( "earmuffs/shared/sh_logger.lua" )
include( "earmuffs/shared/sh_config.lua" )
include( "earmuffs/shared/sh_utils.lua" )
include( "earmuffs/server/sv_sound_throttler.lua" )
include( "earmuffs/server/sv_weapon_ext.lua" )
include( "earmuffs/server/sv_hl2_sweps.lua" )
include( "earmuffs/server/sv_hl2_npcs.lua" )
include( "earmuffs/server/sv_hl2_misc.lua" )


AddCSLuaFile( "earmuffs/client/cl_settings.lua" )
AddCSLuaFile( "earmuffs/client/cl_networked_sounds.lua" )
AddCSLuaFile( "earmuffs/client/cl_combat_sounds.lua" )
AddCSLuaFile( "earmuffs/client/cl_sweps.lua" )
