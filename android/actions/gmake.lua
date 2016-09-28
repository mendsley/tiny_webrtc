--
-- gmake.lua
-- Android integration for gmake.
-- Copyright (c) 2014 Matthew Endsley
--
	local android = premake.extensions.android
	local gcc = premake.tools.gcc
	local clang = premake.tools.clang

	android.arch = {
		armeabi = {
			name = "arm-linux-androideabi",
			platform = "arch-arm",
			target = "armv5te-none-linux-androideabi",
			libarch = "armeabi",
		},
		armeabi_v7a = {
			name = "arm-linux-androideabi",
			platform = "arch-arm",
			target = "armv7-none-linux-androideabi",
			libarch = "armeabi-v7a",
		},
		arm64_v8a = {
			name = "aarch64-linux-android",
			platform = "arch-arm64",
			target = "aarch64-none-linux-android",
			libarch = "arm64-v8a",
		},
		x86 = {
			name = "x86",
			platform = "arch-x86",
			target = "i686-none-linux-android",
			libarch = "x86",
		},
		x86_64 = {
			name = "x86_64",
			platform = "arch-x86_64",
			target = "x86_64-none-linux-android",
			libarch = "x86_64",
		},
		mips = {
			name = "mipsel-linux-android",
			platform = "arch-mips",
			target = "mipsel-none-linux-android",
			libarch = "mips",
		},
		mips64 = {
			name = "mips64el-linux-android",
			platform = "arch-mips64",
			target = "mips64el-none-linux-android",
			libarch = "mips64",
		},
	}

	android.prebuiltpath = function(cfg, base)
		local toolchainpath = ""
		if cfg.androidndkroot ~= nil then
			local platform = "linux-x86_64"
			if os.is("windows") then
				platform = "windows-x86_64"
			end

			toolchainpath = path.join(cfg.androidndkroot, string.format("toolchains/%s/prebuilt/%s", base, platform))
		end
		return toolchainpath
	end

	premake.override(clang, "gettoolname", function(base, cfg, tool)
		if cfg.system == premake.ANDROID then
			local archname = android.arch[cfg.architecture].name
			local toolchainpath = path.join(android.prebuiltpath(cfg, "llvm"), "bin")
			local artoolchainpath = path.join(android.prebuiltpath(cfg, archname.."-4.9"), "bin")
			local tools = {
				cc =  path.join(toolchainpath, "clang"),
				cxx = path.join(toolchainpath, "clang++"),
				ar =  path.join(artoolchainpath, archname .. "-ar"),
			}

			local name = tools[tool]
			if name ~= nil then
				return name
			end
		end

		return base(cfg, tool)
	end)

	premake.override(clang, "getcflags", function(base, cfg)
		local flags = base(cfg)

		if cfg.system == premake.ANDROID and cfg.androidndkroot then
			local arch = android.arch[cfg.architecture]
			local gccpath = android.prebuiltpath(cfg, arch.name.."-4.9")

			local extras = {
				"-gcc-toolchain " .. gccpath,
				"-target " .. arch.target,
				string.format("--sysroot=%s", path.join(cfg.androidndkroot, string.format("platforms/android-%d/%s", cfg.androidapilevel, arch.platform))),
				string.format("-isystem \"%s\"", path.join(cfg.androidndkroot, "sources/android/support/include")),
			}

			table.insertflat(flags, extras)
		end

		return flags
	end)

	premake.override(clang, "getcxxflags", function(base, cfg)
		local flags = base(cfg)

		if cfg.system == premake.ANDROID then
			local extras = {
				string.format("-isystem \"%s\"", path.join(cfg.androidndkroot, "sources/cxx-stl/llvm-libc++/libcxx/include")),
				"-stdlib=libc++",
			}

			table.insertflat(flags, extras)
		end

		return flags
	end)

	premake.override(clang, "getldflags", function(base, cfg)
		local flags = base(cfg)

		if cfg.system == premake.ANDROID then
			local arch = android.arch[cfg.architecture]
			local gccpath = android.prebuiltpath(cfg, arch.name.."-4.9")

			local extras = {
				"-gcc-toolchain " .. gccpath,
				"-target " .. arch.target,
				string.format("--sysroot=%s", path.join(cfg.androidndkroot, string.format("platforms/android-%d/%s", cfg.androidapilevel, arch.platform))),
				string.format("-L \"%s\"", path.join(cfg.androidndkroot, string.format("sources/cxx-stl/llvm-libc++/libs/%s", arch.libarch))),
				"-stdlib=libc++",
				"-v",
			}

			table.insertflat(flags, extras)
		end
	--		if cfg.architecture ~= nil then
	--			local ldflags = {
	--				armv7 = {
	--					string.format("--sysroot \"%s/platforms/android-%d/arch-arm\"", cfg.androidndkroot, cfg.androidapilevel),
	--					string.format("-L \"%s/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a\"", cfg.androidndkroot),
	--				},
	--			}
	----			local sdkroot = ""
	----			if cfg.naclsdkroot ~= nil then
	----				sdkroot = cfg.naclsdkroot
	----			end

	----			local cflags = {
	----				x86 = {
	----					"-melf32_nacl",
	----					"-m32",
	----					string.format("-L \"%s/lib/newlib_x86_32/Release/\"", sdkroot),
	----				},
	----				x86_64 = {
	----					"-melf64_nacl",
	----					"-m64",
	----					string.format("-L \"%s/lib/newlib_x86_64/Release/\"", sdkroot),
	----				},
	----			}
	----

	--			local extras = ldflags[cfg.architecture]
	--			if extras ~= nil then
	--				table.insertflat(flags, extras)
	--			end

	--			local all = {
	--				"-lc++_static",
	--			}
	--			table.insertflat(flags, all)
	--		end
	--	end

		return flags
	end)
