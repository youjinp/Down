//
//  File.swift
//  
//
//  Created by Youjin Phea on 15/05/21.
//

import Foundation
import libcmark


// MARK: - Renderer
public protocol Renderer {
    associatedtype Result
    
    func render(_ node: CMarkNode, options: DownOptions, width: Int32) throws -> Result
}






















// MARK: - CommonMarkRenderer
public struct CommonMarkRenderer: Renderer {

    public typealias Result = String
    
    /**
     * Generates a CommonMark Markdown string from the given abstract syntax tree.
     *
     * **Note:** caller is responsible for calling `cmark_node_free(ast)` after this returns.
     *
     * - Parameters:
     *     - ast: The `cmark_node` representing the abstract syntax tree.
     *     - options: `DownOptions` to modify parsing or rendering, defaulting to `.default`.
     *     - width: The width to break on, defaulting to 0.
     *
     * - Returns:
     *     A CommonMark Markdown string.
     *
     * - Throws:
     *     `ASTRenderingError` if the AST could not be converted.
     */
    public func render(_ node: CMarkNode, options: DownOptions = .default, width: Int32 = 0) throws -> String {

        guard let cCommonMarkString = cmark_render_commonmark(node, options.rawValue, width) else {
            throw DownErrors.astRenderingError
        }

        defer {
            free(cCommonMarkString)
        }

        guard let commonMarkString = String(cString: cCommonMarkString, encoding: String.Encoding.utf8) else {
            throw DownErrors.astRenderingError
        }

        return commonMarkString
    }
    
    public init() {}

}


