import Clang
import Foundation

let llvmIncludesPath = URL(
  fileURLWithPath: "~/llvm-20.1.6-x86_64-unknown-linux-gnu-MinSizeRel/include")
let bindingsFolder = URL(fileURLWithPath: "/home/ambrus/swifty-llvm/Sources/SwiftyLLVM2")

func main() {
  do {

    let llvmHeaders = try filesRecursivelyIn(root: llvmIncludesPath.appending(path: "llvm-c"))
      .filter { $0.pathExtension == "h" }

    let contentsOfBindings = try filesRecursivelyIn(root: bindingsFolder)
      .filter { $0.pathExtension == "swift" }
      .map { try String(contentsOf: $0, encoding: .utf8) }

    let headerInfos = try llvmHeaders.map { header in
      try analyzeFile(at: header, bindings: contentsOfBindings)
    }

    for h in headerInfos {
      print("[\(link(h.url.description))]")
      let presentFunctions = h.functions.count { $0.presentInBindings }
      let presentEnums = h.enums.count { $0.presentInBindings }
      let presentEnumCases = h.enumCases.count { $0.presentInBindings }
      let presentStructs = h.structs.count { $0.presentInBindings }
      print(
        "   \(presentFunctions)/\(h.functions.count) functions, \t\(presentEnums)/\(h.enums.count) enums,\t\(presentEnumCases)/\(h.enumCases.count) enum cases,\t\(presentStructs)/\(h.structs.count) structs"
      )

      if !h.missingFunctions.isEmpty {
        print(purple("  > Missing functions:"))
        print("  " + h.missingFunctions.joined(separator: ", \t"))
      }

      if !h.missingStructs.isEmpty {
        print(purple("  > Missing Structs:"))
        for s in h.missingStructs {
          print("  - \(s)")
        }
      }

      if !h.missingEnums.isEmpty {
        print(purple("  > Missing Enums:"))
        print("  " + h.missingEnums.joined(separator: ", \t"))
      }

      if !h.missingEnumCases.isEmpty {
        print(purple("  > Missing Enum Cases:"))
        print("  " + h.missingEnumCases.joined(separator: ", \t"))
      }
    }

    let totalMissing = headerInfos.reduce(
      0,
      { r, e in
        r + e.missingEnums.count + e.missingEnumCases.count + e.missingFunctions.count
          + e.missingStructs.count
      })
    let total = headerInfos.reduce(
      0, { r, e in r + e.enums.count + e.enumCases.count + e.functions.count + e.structs.count })

    print("\nTOTAL: \(total-totalMissing)/\(total)")
  } catch (let e) {
    print(e.localizedDescription)
  }
}

main()

struct HeaderInfo {
  let url: URL
  var enums: [SymbolPresence] = []
  var enumCases: [SymbolPresence] = []
  var structs: [SymbolPresence] = []
  var functions: [SymbolPresence] = []
}

extension HeaderInfo {
  var missingFunctions: [String] {
    functions.filter { !$0.presentInBindings }.map { $0.name }
  }
  var missingStructs: [String] {
    structs.filter { !$0.presentInBindings }.map { $0.name }
  }
  var missingEnums: [String] {
    enums.filter { !$0.presentInBindings }.map { $0.name }
  }
  var missingEnumCases: [String] {
    enumCases.filter { !$0.presentInBindings }.map { $0.name }
  }
}

struct SymbolPresence {
  let name: String
  let presentInBindings: Bool
}

func isPresentInBindings(symbol: String, allWrapperContents: [String]) -> Bool {
  return allWrapperContents.contains { s in s.contains(symbol) }
}

func analyzeFile(at header: URL, bindings: [String]) throws -> HeaderInfo {
  let tu = try TranslationUnit(
    path: header.path, index: .init(), commandLineArgs: ["-I", llvmIncludesPath.path])

  var header = HeaderInfo(url: header)
  tu.visitChildren { node in
    guard node.range.start.isFromMainFile else { return .recurse }

    if let function = node as? FunctionDecl {
      let present = isPresentInBindings(symbol: function.spelling, allWrapperContents: bindings)
      header.functions.append(.init(name: function.spelling, presentInBindings: present))
    }

    if let `enum` = node as? EnumDecl {
      if !`enum`.isAnonymous {
        let present = isPresentInBindings(symbol: `enum`.spelling, allWrapperContents: bindings)
        header.enums.append(.init(name: `enum`.spelling, presentInBindings: present))
      }

      for enumCase in `enum`.constants() {
        let present = isPresentInBindings(symbol: enumCase.spelling, allWrapperContents: bindings)
        header.enumCases.append(.init(name: enumCase.spelling, presentInBindings: present))
      }
    }

    if let `struct` = node as? StructDecl {
      let present = isPresentInBindings(symbol: `struct`.spelling, allWrapperContents: bindings)
      header.structs.append(.init(name: `struct`.spelling, presentInBindings: present))
    }
    return .recurse
  }

  return header
}
