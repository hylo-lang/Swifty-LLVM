# Testing with:
# mkdir -p ~/src/Swifty-LLVM/.cmake-build && cd ~/src/Swifty-LLVM/.cmake-build && cmake -DLLVM_DIR=$(brew --prefix --installed llvm)/lib/cmake -GNinja -S .. && cmake --build .

cmake_minimum_required(VERSION 3.28.2)

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

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)

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
target_link_libraries(SwiftyLLVM
  # TODO: does this really need to be public? Otherwise, I'm getting
  # DataLayoutTests.swift:1:8: error: missing required modules: 'llvmc', 'llvmshims'
  PUBLIC llvmshims llvmc)
target_compile_options(SwiftyLLVM
  PRIVATE $<$<BOOL:${ENABLE_TESTING}>:-enable-testing>)

if(ENABLE_TESTING)

  include(FindXCTest)
  if(APPLE)
    add_library(XCTest SHARED IMPORTED)

    # Determine the .../<Platform>.platform/Developer directory prefix where XCTest can be found.
    # TODO: the directories derived from this should probably have a CMakeCache entry.
    set(platform_developer "")
    foreach(d ${CMAKE_Swift_IMPLICIT_INCLUDE_DIRECTORIES})
      if(${d} MATCHES "^(.*[.]platform/Developer)/SDKs/.*")
	string(REGEX REPLACE "^(.*[.]platform/Developer)/SDKs/.*" "\\1" platform_developer ${d})
	break()
      endif()
    endforeach()
    if(${platform_developer} STREQUAL "")
      message(FATAL_ERROR "failed to find platform developer directory in ${CMAKE_Swift_IMPLICIT_INCLUDE_DIRECTORIES}")
    endif()

    target_include_directories(XCTest INTERFACE ${platform_developer}/usr/lib/)
    set_target_properties(XCTest PROPERTIES
      IMPORTED_LOCATION ${platform_developer}/usr/lib/libXCTestSwiftSupport.dylib)
  endif()

  file(GLOB_RECURSE files FOLLOW_SYMLINKS LIST_DIRECTORIES false CONFIGURE_DEPENDS Tests/LLVMTests/*.swift)
  xctest_add_bundle(SwiftyLLVMTests SwiftyLLVM ${files})
  target_link_libraries(SwiftyLLVMTests PRIVATE XCTest)
  xctest_add_test(XCTest.SwiftyLLVMTests SwiftyLLVMTests)

endif()
