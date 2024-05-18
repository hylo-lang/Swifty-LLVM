# Commands used to create an easy development environment when
# building this project directly (not as a dependency).

# Without this, generated Xcode projects aren't debuggable.
set(CMAKE_XCODE_GENERATE_SCHEME YES)

#
# Hylo-standard dependency resolution.
#
include(FetchContent)

block()

  set(FETCHCONTENT_TRY_FIND_PACKAGE_MODE NEVER)
  FetchContent_Declare(Hylo-CMakeModules
    GIT_REPOSITORY https://github.com/hylo-lang/CMakeModules.git
    GIT_TAG        43ee6f5
    OVERRIDE_FIND_PACKAGE
  )

endblock()
FetchContent_MakeAvailable(Hylo-CMakeModules)

list(PREPEND CMAKE_MODULE_PATH ${hylo-cmakemodules_SOURCE_DIR})
