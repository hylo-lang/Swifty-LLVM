import SwiftyLLVM
import XCTest

final class MemoryBufferTests: XCTestCase {

  func testInitCopyingData() throws {
    let s = "Hello, World!"
    try s.withCString({ (d) in
      let b = MemoryBuffer(copying: .init(start: d, count: s.utf8.count))
      let decoded = try b.withUnsafeBytes({ (contents) in
        try XCTUnwrap(contents.withMemoryRebound(to: UInt8.self, { (b) in String(bytes: b, encoding: .utf8) }))
      })
      XCTAssertEqual(s, decoded)
    })
  }

  func testInitBorrowingData() throws {
    let s = "Hello, World!"
    try s.withCString({ (d) in
      try MemoryBuffer.withInstanceBorrowing(.init(start: d, count: s.utf8.count), { (b) in
        let decoded = try b.withUnsafeBytes({ (contents) in
          try XCTUnwrap(contents.withMemoryRebound(to: UInt8.self, { (b) in String(bytes: b, encoding: .utf8) }))
        })
        XCTAssertEqual(s, decoded)
      })
    })
  }

  func testInitWithContentsOfFile() throws {
    let s = "Hello, World!"
    let f = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID())")
    try s.write(to: f, atomically: true, encoding: .utf8)

    let b = try MemoryBuffer(contentsOf: f.path)
    let decoded = try b.withUnsafeBytes({ (contents) in
      try XCTUnwrap(contents.withMemoryRebound(to: UInt8.self, { (b) in String(bytes: b, encoding: .utf8) }))
    })
    XCTAssertEqual(s, decoded)
  }

}
