require "msvc_xp"
require "android"

if _ACTION == nil then
	return
end

workspace "webrtc"
	platforms {"x86", "x86_64", "android"}
	configurations {"Release", "Release-static"}

	location (".build/projects/" .. _ACTION .. "/")
	objdir (".build/obj/" .. _ACTION .. "/%{cfg.configuration}/")
	targetdir ("lib/" .. _ACTION .. "/%{cfg.architecture}")

	debugformat "c7"
	editandcontinue "Off"
	nativewchar "On"
	optimize "Speed"
	exceptionhandling "Off"

	flags {
		"NoMinimalRebuild",
		"NoIncrementalLink",
		"NoPCH",
		"Symbols",
		"Unicode",
		"FatalWarnings",
		"C++11",
	}

	filter "architecture:x86"
		vectorextensions "SSE2"

	filter "Release-static"
		targetsuffix "-static"
		flags "StaticRuntime"

	filter {"action:vs*"}
		defines {
			"COMPILER_MSVC",
			"_SCL_SECURE_NO_WARNINGS",
			"_CRT_SECURE_NO_WARNINGS",
			"_HAS_EXCEPTIONS=0",
		}
		buildoptions {
			"/wd4100", -- warning C4100: 'T' : unreferenced formal parameter
			"/wd4127", -- warning C4127: conditional expression is constant
			"/wd4244", -- warning C4244: 'EXPR' : conversion from 'T' to 'U', possible loss of data
			"/wd4267", -- warning C4267: 'EXPR' : conversion from 'T' to 'U', possible loss of data
			"/wd4351", -- warning C4351: new behavior: elements of array 'webrtc::TransientDetector::last_first_moment_' will be default initialized
			"/wd4701", -- warning C4701: potentially uninitialized local variable 'T' used
			"/wd4703", -- warning C4703: potentially uninitialized local pointer variable 'pcm_transition' used
			"/wd4706", -- warning C4706: assignment within conditional expression
 			"/wd4310", -- warning C4310: cast truncates constant value
			"/wd4334", -- warning C4334: 'EXPR' : result of 32-bit shift implicitly converted to 64 bits (was 64-bit shift intended)
		}
		
	filter "platforms:android"
		androidndkroot (os.getenv("ANDROID_NDKROOT"))
		androidapilevel (19)
		toolset "clang"
		vectorextensions "Default"
		system "android"
		architecture "armeabi_v7a"
		objdir (".build/obj/" .. _ACTION .. "/%{cfg.configuration}/")
		targetdir ("lib/" .. _ACTION .. "/%{cfg.architecture}")
		buildoptions {
			"-mfpu=neon",
		}

	filter {}

project "webrtc"
	language "C++"
	kind "StaticLib"

	includedirs {
		"upstream_webrtc/",
		"upstream_webrtc/webrtc/common_audio/signal_processing/include/",
		"upstream_webrtc/webrtc/modules/audio_coding/codecs/isac/main/include/"
	}
	files {
		"upstream_webrtc/webrtc/common_types.*",
		"upstream_webrtc/webrtc/base/checks.*",
		"upstream_webrtc/webrtc/base/event.*",
		"upstream_webrtc/webrtc/base/platform_file*",
		"upstream_webrtc/webrtc/base/platform_thread*",
		"upstream_webrtc/webrtc/base/thread_checker**",
		"upstream_webrtc/webrtc/base/criticalsection.cc",
		"upstream_webrtc/webrtc/system_wrappers/source/**",
		"upstream_webrtc/webrtc/system_wrappers/include/**",
		"upstream_webrtc/webrtc/modules/audio_processing/aec/**",
		"upstream_webrtc/webrtc/modules/audio_processing/aecm/**",
		"upstream_webrtc/webrtc/modules/audio_processing/ns/**",
		"upstream_webrtc/webrtc/modules/audio_processing/utility/**",
		"upstream_webrtc/webrtc/modules/audio_processing/agc/**",
		"upstream_webrtc/webrtc/modules/audio_processing/beamformer/**",
		"upstream_webrtc/webrtc/modules/audio_processing/include/**",
		"upstream_webrtc/webrtc/modules/audio_processing/intelligibility/**",
		"upstream_webrtc/webrtc/modules/audio_processing/transient/**",
		"upstream_webrtc/webrtc/modules/audio_processing/vad/**",
		"upstream_webrtc/webrtc/modules/audio_processing/*.cc",
		"upstream_webrtc/webrtc/modules/audio_processing/*.h",
		"upstream_webrtc/webrtc/common_audio/include/**",
		"upstream_webrtc/webrtc/common_audio/resampler/**",
		"upstream_webrtc/webrtc/common_audio/vad/**",
		"upstream_webrtc/webrtc/common_audio/signal_processing/**",
		"upstream_webrtc/webrtc/common_audio/*.c",
		"upstream_webrtc/webrtc/common_audio/*.cc",
		"upstream_webrtc/webrtc/common_audio/*.h",
		"upstream_webrtc/webrtc/modules/audio_coding/codecs/isac/main/include/**",
		"upstream_webrtc/webrtc/modules/audio_coding/codecs/isac/main/source/**",
	}

	excludes {
		"upstream_webrtc/webrtc/base/**_unittest.cc",
		"upstream_webrtc/webrtc/system_wrappers/**_unittest.cc",
		"upstream_webrtc/webrtc/system_wrappers/**_unittest_disabled.cc",
		"upstream_webrtc/webrtc/system_wrappers/source/logcat_trace_context.cc",
		"upstream_webrtc/webrtc/system_wrappers/source/data_log.cc",
		"upstream_webrtc/webrtc/common_audio/**_unittest.cc",
		"upstream_webrtc/webrtc/common_audio/wav_file.cc",
		"upstream_webrtc/webrtc/modules/audio_coding/**.cc",
	}

	filter "system:windows"
		defines {
			"WEBRTC_WIN",
			"WEBRTC_NS_FLOAT",
			"WIN32_LEAN_AND_MEAN",
			"NOMINMAX",
		}

		excludes {
			"upstream_webrtc/webrtc/system_wrappers/**_posix.cc",
			"upstream_webrtc/webrtc/system_wrappers/**_mac.cc",
			"upstream_webrtc/webrtc/system_wrappers/**_android.c",
			"upstream_webrtc/webrtc/modules/audio_processing/**_mips.c",
			"upstream_webrtc/webrtc/modules/audio_processing/**_neon.c",
			"upstream_webrtc/webrtc/modules/audio_processing/**_unittest.cc",
			"upstream_webrtc/webrtc/modules/audio_processing/**_test.cc",
			"upstream_webrtc/webrtc/modules/audio_processing/intelligibility/test/**",
			"upstream_webrtc/webrtc/modules/audio_processing/transient/test/**",
			"upstream_webrtc/webrtc/common_audio/**_neon.c",
			"upstream_webrtc/webrtc/common_audio/**_neon.cc",
			"upstream_webrtc/webrtc/common_audio/**_openmax.cc",
			"upstream_webrtc/webrtc/common_audio/**_arm.S",
			"upstream_webrtc/webrtc/common_audio/**_armv7.S",
			"upstream_webrtc/webrtc/common_audio/**_mips.c",
		}
		
	filter "system:android"
		defines {
			"WEBRTC_ANDROID",
			"WEBRTC_POSIX",
			"WEBRTC_LINUX",
			"WEBRTC_NS_FLOAT",
			"WEBRTC_HAS_NEON",
			"WEBRTC_CLOCK_TYPE_REALTIME",
		}
		
		includedirs {
			(os.getenv("ANDROID_NDKROOT").."/sources/android/cpufeatures"),
		}

		excludes {
			--"upstream_webrtc/webrtc/system_wrappers/**_posix.cc",
			"upstream_webrtc/webrtc/system_wrappers/**_mac.cc",
			"upstream_webrtc/webrtc/system_wrappers/**_win.cc",
			--"upstream_webrtc/webrtc/system_wrappers/**_android.c",
			"upstream_webrtc/webrtc/modules/audio_processing/**_mips.c",
			--"upstream_webrtc/webrtc/modules/audio_processing/**_neon.c",
			"upstream_webrtc/webrtc/modules/audio_processing/**_unittest.cc",
			"upstream_webrtc/webrtc/modules/audio_processing/**_test.cc",
			"upstream_webrtc/webrtc/modules/audio_processing/**_sse2.c",
			"upstream_webrtc/webrtc/modules/audio_processing/intelligibility/test/**",
			"upstream_webrtc/webrtc/modules/audio_processing/transient/test/**",
			--"upstream_webrtc/webrtc/common_audio/**_neon.c",
			--"upstream_webrtc/webrtc/common_audio/**_neon.cc",
			"upstream_webrtc/webrtc/common_audio/**_openmax.cc",
			"upstream_webrtc/webrtc/common_audio/**_sse.cc",
			"upstream_webrtc/webrtc/common_audio/**_arm.S",
			--"upstream_webrtc/webrtc/common_audio/**_armv7.S",
			"upstream_webrtc/webrtc/common_audio/**_mips.c",
		}

	filter {}

project "opus"
	language "C"
	kind "StaticLib"

	includedirs {
		"upstream_opus/include/",
		"upstream_opus/celt/",
		"upstream_opus/silk/",
		"upstream_opus/silk/float/",
		"upstream_opus/src/",
		"opus_contrib/",
	}
	files {
		"upstream_opus/celt/*",
		"upstream_opus/silk/*",
		"upstream_opus/silk/float/**",
		"upstream_opus/src/**",
	}
	excludes {
		"upstream_opus/celt/*_demo.c",
		"upstream_opus/src/*_demo.c",
		"upstream_opus/src/mlp_train.c",
		"upstream_opus/src/opus_compare.c",
	}

	filter "system:windows"
		defines {
			-- opus
			"USE_ALLOCA",
			"HAVE_CONFIG_H",
		}
		
	filter "system:android"
		defines {
			"USE_ALLOCA",
			"HAVE_CONFIG_H",
			"HAVE_LRINT=1",
			"HAVE_LRINTF=1",
			--"OPUS_HAVE_RTCD",
			--"OPUS_ARM_ASM",
		}
		files {
			--"upstream_opus/celt/arm/*"
		}

	filter {}
