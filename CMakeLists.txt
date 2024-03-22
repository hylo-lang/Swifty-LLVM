#
# Standard project boilerplate
#
cmake_minimum_required(VERSION 3.26)
project(Swifty-LLVM
  VERSION 0.1.0
  DESCRIPTION "A tool that finds XCTestCases and their testXXX methods and generates a main.swift to run them."
  HOMEPAGE_URL "https://github.com/hylo-lang/GenerateSwiftXCTestMain"
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
