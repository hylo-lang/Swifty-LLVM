# Testing with:
#
# Mac:
#   mkdir -p .cmake-build && cd .cmake-build && cmake -DENABLE_TESTING=YES -DLLVM_DIR=$(brew --prefix --installed llvm)/lib/cmake/llvm/ -GNinja -S .. && cmake --build . && ctest -V
#
# Linux:
#   mkdir -p .cmake-build && cd .cmake-build && cmake -DENABLE_TESTING=YES -DLLVM_DIR=$(llvm-config --libdir)/cmake/llvm/ -GNinja -S .. && cmake --build . && ctest -V
cmake_minimum_required(VERSION 3.28.2)
#
# Windows:
#  call "c:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"  && cmake -DENABLE_TESTING=YES -DLLVM_DIR=s:\llvm-17.0.6-windows-amd64-msvc17-msvcrt\lib\cmake\llvm\ -GNinja -S . -B s:\build\Swifty-LLVM && cmake --build s:\build\Swifty-LLVM && ctest -V s:\build\Swifty-LLVM
if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
endif()

# MSVC runtime library flags are selected by an abstraction.
if(POLICY CMP0091)
  cmake_policy(SET CMP0091 NEW)
endif()

# enable LSP support
if(POLICY CMP0157)
  cmake_policy(SET CMP0157 NEW)
endif()

project(Swifty-LLVM LANGUAGES C CXX Swift)
enable_testing()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_Swift_LANGUAGE_VERSION 5)
set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)
set(CMAKE_Swift_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
set(CMAKE_POSITION_INDEPENDENT_CODE ${BUILD_SHARED_LIBS})

#
# Dependencies
#

# LLVM (mostly boilplate from https://llvm.org/docs/CMake.html#embedding-llvm-in-your-project)
find_package(LLVM 17.0 REQUIRED CONFIG)
include_directories(${LLVM_INCLUDE_DIRS})
separate_arguments(LLVM_DEFINITIONS_LIST NATIVE_COMMAND ${LLVM_DEFINITIONS})
add_definitions(${LLVM_DEFINITIONS_LIST})

# Work around LLVM link options incompatible with the swift linker.
# See https://github.com/llvm/llvm-project/pull/65634
get_target_property(interface_libs LLVMSupport INTERFACE_LINK_LIBRARIES)
if(-delayload:shell32.dll IN_LIST interface_libs)
  # the delayimp argument shows up as -ldelayimp.lib in shared library builds for
  # some reason.
  list(REMOVE_ITEM interface_libs
    delayimp -ldelayimp.lib  -delayload:shell32.dll -delayload:ole32.dll)
  list(APPEND interface_libs
    $<$<NOT:$<LINK_LANGUAGE:Swift>>:delayimp -delayload:shell32.dll -delayload:ole32.dll>)
  set_target_properties(LLVMSupport
    PROPERTIES INTERFACE_LINK_LIBRARIES "${interface_libs}")
endif()

if(ENABLE_TESTING)
  include(FetchContent)
  FetchContent_Declare(XCTestDiscovery
    GIT_REPOSITORY https://github.com/hylo-lang/XCTestDiscovery.git
    GIT_TAG        main
    FIND_PACKAGE_ARGS CONFIG
  )
  FetchContent_MakeAvailable(XCTestDiscovery)
endif()

#
# Local targets
#

add_library(llvmc INTERFACE)
target_include_directories(llvmc INTERFACE
  Sources/llvmc
)
# Not sure if this is exactly the right list, but it's enough.
llvm_map_components_to_libnames(llvm_libs mcjit bitwriter linker passes X86 ARM AArch64)
target_link_libraries(llvmc INTERFACE ${llvm_libs})

add_library(llvmshims Sources/llvmshims/src/shim.cc)
target_include_directories(llvmshims PUBLIC Sources/llvmshims/include)
target_link_libraries(llvmshims PRIVATE llvmc)

file(GLOB_RECURSE files FOLLOW_SYMLINKS LIST_DIRECTORIES false CONFIGURE_DEPENDS Sources/LLVM/*.swift)
add_library(SwiftyLLVM ${files})

# This is required in order to be a testee.
set_target_properties(SwiftyLLVM PROPERTIES FRAMEWORK TRUE)

target_link_libraries(SwiftyLLVM
  # TODO: does this really need to be public? Otherwise, I'm getting
  # DataLayoutTests.swift:1:8: error: missing required modules: 'llvmc', 'llvmshims'
  PUBLIC llvmshims llvmc)
target_compile_options(SwiftyLLVM
  PRIVATE $<$<BOOL:${ENABLE_TESTING}>:-enable-testing>)

if(ENABLE_TESTING)

  include(${xctestdiscovery_SOURCE_DIR}/cmake/SwiftXCTestCTestBridge.cmake)
  file(GLOB_RECURSE test_files FOLLOW_SYMLINKS LIST_DIRECTORIES false CONFIGURE_DEPENDS Tests/LLVMTests/*.swift)
  add_swift_xctest(SwiftyLLVMTests SwiftyLLVM ${test_files})

endif()
