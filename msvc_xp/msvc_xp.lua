--
-- msvc_xp.lua
-- Ability to target Windows XP with vs2012
-- Copyright (c) 2015 Matthew Endsley
--

	local module = {}

	local vstudio = premake.vstudio

	printf("[Premake MSVC Windows XP support Extension loaded]")

	premake.api.addAllowed("flags", {
		"TargetWindowsXP"
	})

	local vc2010 = vstudio.vc2010

	premake.override(vc2010, "platformToolset", function(base, cfg)
		local action = premake.action.current().vstudio
		if cfg.flags.TargetWindowsXP and tonumber(action.solutionVersion) >= 12 then
			vc2010.element("PlatformToolset", nil, action.platformToolset .. "_xp")
		else
			return base(cfg)
		end
	end)

	return module

