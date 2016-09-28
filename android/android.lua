
--
-- Create an android namespace to isolate the additions
--
	premake.extensions.android = {}

	local android = premake.extensions.android
	local vstudio = premake.vstudio
	local project = premake.project
	local api = premake.api

	android.printf = function( msg, ... )
		printf( "[android] " .. msg, ...)
	end

	android.printf("Premake Android Extension")

	-- Extend the package path to include the directory containing this
	-- script so we can easily 'require' additional resources from
	-- subdirectories as necessary
	local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]];
	package.path = this_dir .. "actions/?.lua;".. package.path


--
-- Register the Android extension
--

	premake.ANDROID = "android"

	api.addAllowed("system", { premake.ANDROID })
	api.addAllowed("architecture", { "armeabi", "armeabi_v7a", "arm64_v8a", "x86", "x86_64", "mips" })

--
-- Register Android properties
--

	api.register {
		name = "androidndkroot",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "androidapilevel",
		scope = "config",
		kind = "integer",
	}

--
-- Set global environment for some common android platforms.
--

	filter {"system:android", "SharedLib"}
		targetextension ".so"

	filter {}

	for k,v in pairs({"actions/gmake.lua"}) do
		include(v)
	end
