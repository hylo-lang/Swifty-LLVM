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

if(BUILD_TESTING)

  set(saved_FETCHCONTENT_TRY_FIND_PACKAGE_MODE ${FETCHCONTENT_TRY_FIND_PACKAGE_MODE})
  set(FETCHCONTENT_TRY_FIND_PACKAGE_MODE OPT_IN)

  FetchContent_Declare(Hylo-CMakeModules
    GIT_REPOSITORY https://github.com/hylo-lang/CMakeModules.git
    GIT_TAG        main
  )

  if(NOT APPLE)
    FetchContent_Declare(GenerateSwiftXCTestMain
      GIT_REPOSITORY https://github.com/hylo-lang/GenerateSwiftXCTestMain.git
      GIT_TAG        main
    )

    FetchContent_Populate(GenerateSwiftXCTestMain)
    list(PREPEND CMAKE_MODULE_PATH ${generateswiftxctestmain_SOURCE_DIR}/cmake/modules)
    include(GenerateSwiftXCTestMain_FetchDependencies)
  else()
    FetchContent_Populate(Hylo-CMakeModules)
  endif()

  set(FETCHCONTENT_TRY_FIND_PACKAGE_MODE ${saved_FETCHCONTENT_TRY_FIND_PACKAGE_MODE})

  list(PREPEND CMAKE_MODULE_PATH ${hylo-cmakemodules_SOURCE_DIR})
  find_package(SwiftXCTest)

  # Not using block() here because FetchContent_MakeAvailable typically causes dependency-specific
  # global variables to be set, and I'm not sure to what extent they may be needed
  if(NOT APPLE)
    set(saved_BUILD_EXAMPLES ${BUILD_EXAMPLES})
    set(saved_BUILD_TESTING ${BUILD_TESTING})

    set(BUILD_EXAMPLES NO)
    set(BUILD_TESTING NO)

    FetchContent_MakeAvailable(GenerateSwiftXCTestMain)
    add_subdirectory(${generateswiftxctestmain_SOURCE_DIR})

    set(BUILD_EXAMPLES ${saved_BUILD_EXAMPLES})
    set(BUILD_TESTING ${saved_BUILD_TESTING})
  endif()

endif()
