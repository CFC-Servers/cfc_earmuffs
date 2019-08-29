local isCombatSound = {

}

local hookName = "CFC_CombatEarmuffs"

-- TODO: Store this result in a var and use pvp change hooks
local function isInPvp()
    return LocalPlayer():GetNWBool( "CFC_PvP_Mode", false )
end

local function shouldPlayCombatSound( soundData )
    local soundName = soundData.SoundName
    if not isCombatSound[soundName] then return end

    if isInPvp() then return false end
end

hook.Remove( "EntityEmitSound", hookName )
hook.Add( "EntityEmitSound", hookName, shouldPlayCombatSound )
