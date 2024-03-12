# Testing with:
#
# Mac:
#   cmake -DBUILD_TESTING=YES -DLLVM_DIR=$(brew --prefix --installed llvm)/lib/cmake/llvm/ -GNinja -S . -B .cmake-build && cmake --build .cmake-build && ctest -V --test-dir .cmake-build
#
# Linux:
#   cmake -DBUILD_TESTING=YES -DLLVM_DIR=-DLLVM_DIR=$(llvm-config --libdir)/cmake/llvm/ -GNinja -S . -B .cmake-build && cmake --build .cmake-build && ctest -V --test-dir .cmake-build
#
# Windows:
#  vcvarsarm64.bat  && cmake -DBUILD_TESTING=YES -DLLVM_DIR=s:/build/llvm/BuildRoot/llvm-17.0.6-arm64-msvc17-release/lib/cmake/llvm -GNinja -S s:\src\Swifty-LLVM -B s:\build\Swifty-LLVM && cmake --build s:\build\Swifty-LLVM && ctest --test-dir s:\build\Swifty-LLVM -V

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
