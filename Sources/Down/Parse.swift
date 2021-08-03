
import Foundation
import libcmark


// MARK: - Parse
public func parse(_ string: String, options: DownOptions = .default) throws -> Node? {
    var tree: CMarkNode?

    string.withCString {
        let stringLength = Int(strlen($0))
        tree = cmark_parse_document($0, stringLength, options.rawValue)
    }

    guard let ast = tree else {
        throw DownErrors.markdownToASTError
    }

    return ast.wrap()
}

