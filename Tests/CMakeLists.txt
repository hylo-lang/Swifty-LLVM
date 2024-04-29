include(HyloUtilities)

if(NOT APPLE)
  find_package(GenerateSwiftXCTestMain)
endif()

find_package(SwiftXCTest)

set_recursive_file_glob(test_files LLVMTests/*.swift)
add_swift_xctest(SwiftyLLVMTests SwiftyLLVM ${test_files})
