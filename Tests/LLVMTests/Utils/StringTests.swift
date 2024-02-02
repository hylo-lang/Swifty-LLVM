import XCTest

@testable import SwiftyLLVM

final class StringTests: XCTestCase {

  func testInitFromLLVM() {
    let text = UnsafeMutableBufferPointer<CChar>.allocate(capacity: 2)
    defer { text.deallocate() }
    text.initialize(repeating: 65)

    func getter(source: Int, count: UnsafeMutablePointer<Int>?) -> UnsafePointer<CChar>? {
      count?.pointee = source
      return UnsafePointer(text.baseAddress)
    }

    XCTAssertEqual(String(from: 0, readingWith: getter(source:count:)), "")
    XCTAssertEqual(String(from: 1, readingWith: getter(source:count:)), "A")
    XCTAssertEqual(String(from: 2, readingWith: getter(source:count:)), "AA")
  }

}
