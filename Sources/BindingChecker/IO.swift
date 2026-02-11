import Foundation

func printPaths(_ paths: [URL]) {
  print(
    paths.map { p in
      "\n - \(p)"
    }.joined())
}

func filesRecursivelyIn(root: URL) throws -> [URL] {
  guard
    let enumerator = FileManager.default.enumerator(
      at: root, includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsHiddenFiles, .skipsPackageDescendants])
  else {
    throw Err(message: "No enumerator for \(root)")
  }

  var allFiles: [URL] = []
  for case let url as URL in enumerator {
    allFiles.append(url)
  }
  return allFiles
}

struct Err: Error {
  let message: String

  public init(message: String) {
    self.message = message
  }
}