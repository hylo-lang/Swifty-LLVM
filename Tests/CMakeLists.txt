if(NOT APPLE)
  find_package(GenerateSwiftXCTestMain)
endif()

find_package(SwiftXCTest)

file(GLOB_RECURSE test_files
  FOLLOW_SYMLINKS
  LIST_DIRECTORIES false
  CONFIGURE_DEPENDS LLVMTests/*.swift)

add_swift_xctest(SwiftyLLVMTests SwiftyLLVM ${test_files})
