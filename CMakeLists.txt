#
# Standard project boilerplate
#
cmake_minimum_required(VERSION 3.30)
set(CMAKE_OSX_DEPLOYMENT_TARGET 15.0)
set(CMAKE_Swift_LANGUAGE_VERSION 6)

# Needed, otherwise we get this error: CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS-NOTFOUND
# https://github.com/hylo-lang/Swifty-LLVM/issues/100
set(CMAKE_CXX_SCAN_FOR_MODULES NO) 

project(Swifty-LLVM
  VERSION 0.1.0
  DESCRIPTION "A Swifty interface for the LLVM compiler infrastructure, currently wrapping LLVM's C API."
  HOMEPAGE_URL "https://github.com/hylo-lang/Swifty-LLVM"
  LANGUAGES C CXX Swift
)

# LLVM is built this way, and we must stay compatible with it.
# TODO: Usage requirement?
set(CMAKE_Swift_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)

enable_testing()
list(PREPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)
if (PROJECT_IS_TOP_LEVEL)
  include(cmake/TopLevelDefaults.cmake)
endif()
set(CMAKE_Swift_FLAGS "${CMAKE_Swift_FLAGS} -v")
set(CMAKE_STATIC_LIBRARY_PREFIX_Swift lib)

add_subdirectory(Sources)

if(BUILD_TESTING)
  add_subdirectory(Tests)
endif()
