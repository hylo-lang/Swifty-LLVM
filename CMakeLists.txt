#
# Standard project boilerplate
#
cmake_minimum_required(VERSION 3.26)
set(CMAKE_OSX_DEPLOYMENT_TARGET 14.0)
project(Swifty-LLVM
  VERSION 0.1.0
  DESCRIPTION "A Swifty interface for the LLVM compiler infrastructure, currently wrapping LLVM's C API."
  HOMEPAGE_URL "https://github.com/hylo-lang/Swifty-LLVM"
  LANGUAGES C CXX Swift
)
enable_testing()
list(PREPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)
if (PROJECT_IS_TOP_LEVEL)
  include(cmake/TopLevelDefaults.cmake)
endif()

add_subdirectory(Sources)

if(BUILD_TESTING)
  add_subdirectory(Tests)
endif()
