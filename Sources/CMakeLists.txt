find_package(HyloLLVM)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_Swift_LANGUAGE_VERSION 5) # Needed? Useful?

# LLVM is built this way, and we must stay compatible with it.
# TODO: Usage requirement?
set(CMAKE_Swift_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)

set(CMAKE_POSITION_INDEPENDENT_CODE ${BUILD_SHARED_LIBS}) # Needed?

# The target that exposes the LLVM C API.
add_library(llvmc INTERFACE)
target_include_directories(llvmc INTERFACE
  llvmc
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

#
# A small library that exposes a few parts of the LLVM C++ API as C.
#
add_library(llvmshims STATIC llvmshims/src/shim.cc)
target_include_directories(llvmshims PUBLIC llvmshims/include)
target_link_libraries(llvmshims PRIVATE llvmc)
# The Ubuntu GitHub runner demands this option: /usr/bin/ld.gold: error:
# lib/libllvmshims.a(shim.cc.o): requires dynamic R_X86_64_PC32 reloc against
# '_ZN4llvm17OptimizationLevel2O0E' which may overflow at runtime; recompile with -fPIC.  We don't
# use -fPIC directly because it clang on Windows rejects it.
set_target_properties(llvmshims
  PROPERTIES
  POSITION_INDEPENDENT_CODE True)

#
# The Swift module our clients depend on.
#
file(GLOB_RECURSE files FOLLOW_SYMLINKS LIST_DIRECTORIES false CONFIGURE_DEPENDS SwiftyLLVM/*.swift)
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
  PRIVATE $<$<BOOL:${BUILD_TESTING}>:-enable-testing> -enable-experimental-feature AccessLevelOnImport)
