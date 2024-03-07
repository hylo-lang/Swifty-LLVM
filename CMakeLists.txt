# Testing with:
#
# Mac:
#   cmake -DENABLE_TESTING=YES -DLLVM_DIR=$(brew --prefix --installed llvm)/lib/cmake/llvm/ -GNinja -S . -B .cmake-build && cmake --build .cmake-build && ctest -V --test-dir .cmake-build
#
# Linux:
#   cmake -DENABLE_TESTING=YES -DLLVM_DIR=-DLLVM_DIR=$(llvm-config --libdir)/cmake/llvm/ -GNinja -S . -B .cmake-build && cmake --build .cmake-build && ctest -V --test-dir .cmake-build
#
# Windows:
#  vcvarsarm64.bat  && cmake -DENABLE_TESTING=YES -DLLVM_DIR=s:/build/llvm/BuildRoot/llvm-17.0.6-arm64-msvc17-release/lib/cmake/llvm -GNinja -S s:\src\Swifty-LLVM -B s:\build\Swifty-LLVM && cmake --build s:\build\Swifty-LLVM && ctest --test-dir s:\build\Swifty-LLVM -V

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

set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
set(CMAKE_POSITION_INDEPENDENT_CODE ${BUILD_SHARED_LIBS})

#
# Dependencies
#

if (PROJECT_IS_TOP_LEVEL)
  include(FetchContent)

  # LLVM (mostly boilplate from https://llvm.org/docs/CMake.html#embedding-llvm-in-your-project)
  find_package(LLVM 17.0 REQUIRED CONFIG)
  include_directories(${LLVM_INCLUDE_DIRS})
  separate_arguments(LLVM_DEFINITIONS_LIST NATIVE_COMMAND ${LLVM_DEFINITIONS})
  add_definitions(${LLVM_DEFINITIONS_LIST})

  # Work around LLVM link options incompatible with the swift linker.
  # See https://github.com/llvm/llvm-project/pull/65634
  if(TARGET LLVMSupport)
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
  endif()


  if(ENABLE_TESTING)

    set(fetch_projects SwiftCMakeXCTesting)

    set(FETCHCONTENT_TRY_FIND_PACKAGE_MODE NEVER)
    FetchContent_Declare(SwiftCMakeXCTesting
      GIT_REPOSITORY https://github.com/hylo-lang/SwiftCMakeXCTesting.git
      GIT_TAG        main
    )

    if(NOT APPLE)
      # SwiftCMakeXCTesting dependency
      list(APPEND fetch_projects SwiftSyntax)
      FetchContent_Declare(SwiftSyntax
        GIT_REPOSITORY https://github.com/apple/swift-syntax.git
        GIT_TAG        main
        OVERRIDE_FIND_PACKAGE
      )
      # See https://github.com/apple/swift-syntax/pull/2454, which will hopefully make this clause
      # unnecessary.  Without it CMake will fatal error when loading SwiftSyntax on some platforms.
      if("${SWIFT_HOST_MODULE_TRIPLE}" STREQUAL "")
        execute_process(COMMAND ${CMAKE_Swift_COMPILER}
          -print-target-info OUTPUT_VARIABLE target-info)
        string(JSON SWIFT_HOST_MODULE_TRIPLE GET ${target-info} target moduleTriple)
      endif()

      # SwiftCMakeXCTesting dependency
      list(APPEND fetch_projects ArgumentParser)
      FetchContent_Declare(ArgumentParser
        GIT_REPOSITORY https://github.com/apple/swift-argument-parser.git
        GIT_TAG        1.3.0
        OVERRIDE_FIND_PACKAGE
      )
    endif()


    set(ENABLE_TESTING NO)
    FetchContent_MakeAvailable(${fetch_projects})
    set(ENABLE_TESTING YES)

    list(PREPEND CMAKE_MODULE_PATH ${swiftcmakexctesting_SOURCE_DIR}/cmake/modules)
    include(FindSwiftXCTest)
  endif()

endif()
#
# Local targets
#

#---------------------------------------------------------------------------------------------------
# The target that exposes the LLVM C API.
add_library(llvmc INTERFACE)
target_include_directories(llvmc INTERFACE
  Sources/llvmc
)

# Our LLVM builds currently only vend support for one target architecture.
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" target_processor)
if(target_processor STREQUAL "arm64" OR target_processor STREQUAL "aarch64")
  set(target_component AArch64)
else()
  set(target_component X86)
endif()
llvm_map_components_to_libnames(llvm_libs bitwriter linker passes ${target_component})
target_link_libraries(llvmc INTERFACE ${llvm_libs})

#---------------------------------------------------------------------------------------------------
# A small library that exposes a few parts of the LLVM C++ API as C.
add_library(llvmshims STATIC Sources/llvmshims/src/shim.cc)
target_include_directories(llvmshims PUBLIC Sources/llvmshims/include)
target_link_libraries(llvmshims PRIVATE llvmc)
# Ubuntu github runner demands this option: /usr/bin/ld.gold: error: lib/libllvmshims.a(shim.cc.o):
# requires dynamic R_X86_64_PC32 reloc against '_ZN4llvm17OptimizationLevel2O0E' which may overflow
# at runtime; recompile with -fPIC
target_compile_options(llvmshims PRIVATE -fPIC)

#---------------------------------------------------------------------------------------------------
# The Swift module our clients depend on.
file(GLOB_RECURSE files FOLLOW_SYMLINKS LIST_DIRECTORIES false CONFIGURE_DEPENDS Sources/SwiftyLLVM/*.swift)
add_library(SwiftyLLVM ${files})

# This is required in order to be a testee.
set_target_properties(SwiftyLLVM
  PROPERTIES FRAMEWORK TRUE
)

target_link_libraries(SwiftyLLVM
  # TODO: does this really need to be public? Otherwise, I'm getting
  # DataLayoutTests.swift:1:8: error: missing required modules: 'llvmc', 'llvmshims'
  PUBLIC llvmshims llvmc)

target_compile_options(SwiftyLLVM
  PRIVATE $<$<BOOL:${ENABLE_TESTING}>:-enable-testing> -enable-experimental-feature AccessLevelOnImport)

if(ENABLE_TESTING)

  file(GLOB_RECURSE test_files FOLLOW_SYMLINKS LIST_DIRECTORIES false CONFIGURE_DEPENDS Tests/LLVMTests/*.swift)
  add_swift_xctest(SwiftyLLVMTests SwiftyLLVM ${test_files})

endif()
