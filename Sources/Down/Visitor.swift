//
//  File.swift
//  
//
//  Created by Youjin Phea on 15/05/21.
//

import Foundation
import cmark


// MARK: - Visitor

/**
 * Visitor describes a type that is able to traverse the abstract syntax tree. It visits
 * each node of the tree and produces some result for that node.
 */
public protocol Visitor {

    associatedtype Result

    func visit(document node: Document) -> Result
    func visit(blockQuote node: BlockQuote) -> Result
    func visit(list node: List) -> Result
    func visit(item node: Item) -> Result
    func visit(codeBlock node: CodeBlock) -> Result
    func visit(htmlBlock node: HtmlBlock) -> Result
    func visit(customBlock node: CustomBlock) -> Result
    func visit(paragraph node: Paragraph) -> Result
    func visit(heading node: Heading) -> Result
    func visit(thematicBreak node: ThematicBreak) -> Result
    func visit(text node: Text) -> Result
    func visit(softBreak node: SoftBreak) -> Result
    func visit(lineBreak node: LineBreak) -> Result
    func visit(code node: Code) -> Result
    func visit(htmlInline node: HtmlInline) -> Result
    func visit(customInline node: CustomInline) -> Result
    func visit(emphasis node: Emphasis) -> Result
    func visit(strong node: Strong) -> Result
    func visit(link node: Link) -> Result
    func visit(image node: Image) -> Result
    func visitChildren(of node: Node) -> [Result]

}

extension Visitor {

    public func visitChildren(of node: Node) -> [Result] {
        return node.childSequence.compactMap { child in
            switch child {
            case let child as Document:       return visit(document: child)
            case let child as BlockQuote:     return visit(blockQuote: child)
            case let child as List:           return visit(list: child)
            case let child as Item:           return visit(item: child)
            case let child as CodeBlock:      return visit(codeBlock: child)
            case let child as HtmlBlock:      return visit(htmlBlock: child)
            case let child as CustomBlock:    return visit(customBlock: child)
            case let child as Paragraph:      return visit(paragraph: child)
            case let child as Heading:        return visit(heading: child)
            case let child as ThematicBreak:  return visit(thematicBreak: child)
            case let child as Text:           return visit(text: child)
            case let child as SoftBreak:      return visit(softBreak: child)
            case let child as LineBreak:      return visit(lineBreak: child)
            case let child as Code:           return visit(code: child)
            case let child as HtmlInline:     return visit(htmlInline: child)
            case let child as CustomInline:   return visit(customInline: child)
            case let child as Emphasis:       return visit(emphasis: child)
            case let child as Strong:         return visit(strong: child)
            case let child as Link:           return visit(link: child)
            case let child as Image:          return visit(image: child)
            default:
                assertionFailure("Unexpected child")
                return nil
            }
        }
    }

}
































// MARK: - Debug Visitor
/**
 * This visitor will generate the debug description of an entire abstract syntax tree,
 * indicating relationships between nodes with indentation.
 */
public class DebugVisitor: Visitor {

    // MARK: Properties
    private var depth = 0

    private var indent: String {
        return String(repeating: "    ", count: depth)
    }

    
    
    
    
    
    // MARK: Life cycle
    public init() {}

    
    
    
    
    
    // MARK: API
    public typealias Result = String

    public func visit(document node: Document) -> String {
        return reportWithChildren(node)
    }

    public func visit(blockQuote node: BlockQuote) -> String {
        return reportWithChildren(node)
    }

    public func visit(list node: List) -> String {
        return reportWithChildren(node)
    }

    public func visit(item node: Item) -> String {
        return reportWithChildren(node)
    }

    public func visit(codeBlock node: CodeBlock) -> String {
        return reportWithChildren(node)
    }

    public func visit(htmlBlock node: HtmlBlock) -> String {
        return reportWithChildren(node)
    }

    public func visit(customBlock node: CustomBlock) -> String {
        return reportWithChildren(node)
    }

    public func visit(paragraph node: Paragraph) -> String {
        return reportWithChildren(node)
    }

    public func visit(heading node: Heading) -> String {
        return reportWithChildren(node)
    }

    public func visit(thematicBreak node: ThematicBreak) -> String {
        return report(node)
    }

    public func visit(text node: Text) -> String {
        return report(node)
    }

    public func visit(softBreak node: SoftBreak) -> String {
        return report(node)
    }

    public func visit(lineBreak node: LineBreak) -> String {
        return report(node)
    }

    public func visit(code node: Code) -> String {
        return report(node)
    }

    public func visit(htmlInline node: HtmlInline) -> String {
        return report(node)
    }

    public func visit(customInline node: CustomInline) -> String {
        return report(node)
    }

    public func visit(emphasis node: Emphasis) -> String {
        return reportWithChildren(node)
    }

    public func visit(strong node: Strong) -> String {
        return reportWithChildren(node)
    }

    public func visit(link node: Link) -> String {
        return reportWithChildren(node)
    }

    public func visit(image node: Image) -> String {
        return reportWithChildren(node)
    }

    
    
    
    
    // MARK: Helpers
    private func report(_ node: Node) -> String {
        return "\(indent)\(node is Document ? "" : "↳ ")\(String(reflecting: node))\n"
    }

    private func reportWithChildren(_ node: Node) -> String {
        let thisNode = report(node)
        depth += 1
        let children = visitChildren(of: node).joined()
        depth -= 1
        return "\(thisNode)\(children)"
    }
}
