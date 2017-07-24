#设置最小支持的cmake版本号
cmake_minimum_required(VERSION 2.8)
#项目名称
project(idle-base)

#定义模块路径
set(CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/CMake
  ${CMAKE_MODULE_PATH}
)

# Force out-of-source build（强制要求外部构建）
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR
    "This project requires an out of source build. Remove the file 'CMakeCache.txt' found in this directory before continuing, create a separate build directory and run 'cmake [options] <srcs>' from there."
  )
endif()

#打印源码路径和运行路径
message("CMAKE_SOURCE_DIR= ${CMAKE_SOURCE_DIR}")
message("CMAKE_BINARY_DIR= ${CMAKE_BINARY_DIR}")

# TODO: allow other compilers under windows in the future（提示windows下不支持非MSVC）
if(WIN32 AND NOT MSVC)
  message(FATAL_ERROR
    "Under Windows other compiler than Microsoft Visual Studio are not supported."
  )
endif()

#configuration 配置  cache 缓存  force 武力，强迫
# Override configuration-types - we don't use anything else than debug and release
message("test for the cmake_configuration_types....")
message("CMAKE_CONFIGURATION_TYPES = ${CMAKE_CONFIGURATION_TYPES}")

if(CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_CONFIGURATION_TYPES Release Debug)
  set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES}" CACHE STRING
    "Reset the configurations to what we need"
    FORCE)
endif()

#设置bin目录和conf目录
set(BIN_DIR ${CMAKE_INSTALL_PREFIX}/bin)
set(CONF_DIR ${CMAKE_INSTALL_PREFIX}/etc)

# If win32 put it in the bin dir not lib
if(WIN32)
  set(LIBS_DIR ${CMAKE_INSTALL_PREFIX}/bin)
else()
  set(LIBS_DIR ${CMAKE_INSTALL_PREFIX}/lib)
endif()

message("the cmake_install_rpath is : CMAKE_INSTALL_RPATH = ${CMAKE_INSTALL_RPATH}")

# For Unix systems set the rpath so that libraries are found
set(CMAKE_INSTALL_RPATH ${LIBS_DIR})
set(CMAKE_INSTALL_NAME_DIR ${LIBS_DIR})
# Run out of build tree
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)
message("CMAKE_INSTALL_RPATH= ${CMAKE_INSTALL_RPATH}")
message("CMAKE_INCLUDE_PATH = ${CMAKE_INCLUDE_PATH}")
#依赖的第三方库
find_package(LibUV REQUIRED)

#设置cmake build 类型
if(DEBUG)
  message(STATUS "Build in debug-mode   : Yes")
  set(CMAKE_BUILD_TYPE Debug)
else()
  set(CMAKE_BUILD_TYPE Release)
  message(STATUS "Build in debug-mode   : No  (default)")
endif()

# Set warning levels for different builds(设置编译选项）
if(WIN32)
  # Disable warnings in Visual Studio 8 and above and add /MP
  set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /Zi /wd4996 /wd4355 /wd4244 /wd4985 /wd4267 /wd4251 /MP")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi /wd4996 /wd4355 /wd4244 /wd4267 /wd4251 /MP")
  set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /wd4996 /wd4355 /wd4244 /wd4985 /wd4267 /wd4251 /MP")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /wd4996 /wd4355 /wd4244 /wd4985 /wd4267 /wd4251 /MP")
  set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /debug")
endif()

set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
set(CMAKE_INSTALL_RPATH ${LIBS_DIR})
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# Add definitions for all build types（作用不是很清楚？？）
# Don't place this above 'dep' subdirectory! Because of defines build will crash.
set(DEFINITIONS
  GLOG_NO_ABBREVIATED_SEVERITIES
  GOOGLE_GLOG_DLL_DECL=
  CPPCONN_LIB_BUILD
)
set(DEFINITIONS_RELEASE NDEBUG)
set(DEFINITIONS_DEBUG _DEBUG)
if(WIN32)
  set(DEFINITIONS ${DEFINITIONS} WIN32 _WIN32 WIN32_LEAN_AND_MEAN)
  set(DEFINITIONS_RELEASE ${DEFINITIONS_RELEASE} _CRT_SECURE_NO_WARNINGS)
endif()

macro(SET_COMMON_TARGET_PROPERTIES target)
  target_compile_definitions(${target} PUBLIC ${DEFINITIONS})
  target_compile_definitions(${target} PUBLIC $<$<CONFIG:Debug>:${DEFINITIONS_DEBUG}>)
  target_compile_definitions(${target} PUBLIC $<$<CONFIG:Release>:${DEFINITIONS_RELEASE}>)
endmacro()


set(my_target "libuvidle-base")

include_directories(
  ${LIBUV_INCLUDE_DIRS}
)

add_executable(${my_target} main.cpp)

#链接到第三方库
target_link_libraries(${my_target}
  ${LIBUV_LIBRARIES}
)


