import LLVM
import XCTest

final class MemoryBufferTests: XCTestCase {

  func testInitCopyingData() {
    let s = "Hello, World!"
    s.withCString({ (d) in
      let b = MemoryBuffer(copying: .init(start: d, count: s.utf8.count))
      XCTAssertEqual(s, String(decoding: b))
    })
  }

  func testInitBorrowingData() {
    let s = "Hello, World!"
    s.withCString({ (d) in
      MemoryBuffer.withInstanceBorrowing(.init(start: d, count: s.utf8.count), { (b) in
        XCTAssertEqual(s, String(decoding: b))
      })
    })
  }

  func testInitWithContentsOfFile() throws {
    let s = "Hello, World!"
    let f = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID())")
    try s.write(to: f, atomically: true, encoding: .utf8)

    let b = try MemoryBuffer(contentsOf: f.path)
    XCTAssertEqual(s, String(decoding: b))
  }

}

extension String {

  /// Creates an instance with the contents of `b`.
  fileprivate init(decoding b: MemoryBuffer) {
    self = b.withUnsafeBytes({ (contents) in
      contents.withMemoryRebound(to: UInt8.self, { (b) in String(bytes: b, encoding: .utf8)! })
    })
  }

}
