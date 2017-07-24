# - Try to find Glog
#
# The following variables are optionally searched for defaults
#  LIBUV_ROOT_DIR:            Base directory where all GLOG components are found
#
# The following are set after configuration is done: 
#  LIBUV_FOUND
#  LIBUV_INCLUDE_DIRS
#  LIBUV_LIBRARIES

include(FindPackageHandleStandardArgs)

if(WIN32)
  set(LIBUV_ROOT_DIR ${CMAKE_SOURCE_DIR}/../libuv-v1.9.1)
else()
  set(LIBUV_ROOT_DIR /usr/local)
endif()

if(WIN32)
  find_path(LIBUV_INCLUDE_DIR uv.h
    PATHS ${LIBUV_ROOT_DIR}/include)
else()
  find_path(LIBUV_INCLUDE_DIR uv.h
    PATHS ${LIBUV_ROOT_DIR}/include)
endif()

if(MSVC)
  find_library(LIBUV_LIBRARY_RELEASE libuv PATHS ${LIBUV_ROOT_DIR}/lib/windows/vs2013/x86/md/Release)
  find_library(LIBUV_LIBRARY_DEBUG libuv PATHS ${LIBUV_ROOT_DIR}/lib/windows/vs2013/x86/md/Debug)
  set(LIBUV_LIBRARY optimized ${LIBUV_LIBRARY_RELEASE} debug ${LIBUV_LIBRARY_DEBUG})
else()
  find_library(LIBUV_LIBRARY uv PATHS ${LIBUV_ROOT_DIR}/lib)
endif()

find_package_handle_standard_args(LIBUV DEFAULT_MSG
  LIBUV_INCLUDE_DIR LIBUV_LIBRARY)

if(LIBUV_FOUND)
  set(LIBUV_INCLUDE_DIRS ${LIBUV_INCLUDE_DIR})
  set(LIBUV_LIBRARIES ${LIBUV_LIBRARY})
endif()

#为何在win32中要加入iphlpapi psapi ...(属于windows的模块）
if(WIN32)
  list(APPEND LIBUV_LIBRARIES iphlpapi)
  list(APPEND LIBUV_LIBRARIES psapi)
  list(APPEND LIBUV_LIBRARIES userenv)
  list(APPEND LIBUV_LIBRARIES ws2_32)
  list(APPEND LIBUV_LIBRARIES shlwapi)
endif()

message("LIBUV_FOUND= ${LIBUV_FOUND}")
message("LIBUV_INCLUDE_DIRS = ${LIBUV_INCLUDE_DIRS}")
message("LIBUV_LIBRARIES = ${LIBUV_LIBRARIES}")
