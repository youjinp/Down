//
//  File.swift
//  
//
//  Created by Youjin Phea on 15/05/21.
//

import Foundation
import cmark


// MARK: CMarkNode
// MARK: - CMarkNode
public typealias CMarkNode = UnsafeMutablePointer<cmark_node>

public extension CMarkNode {
    func wrap() -> Node {
        switch cmark_node_get_type(self) {
        case CMARK_NODE_DOCUMENT:       return Document(self)
        case CMARK_NODE_BLOCK_QUOTE:    return BlockQuote(self)
        case CMARK_NODE_LIST:
            switch cmark_node_get_list_type(self) {
            case CMARK_ORDERED_LIST:
                return OrderedList(self)
            case CMARK_BULLET_LIST:
                return BulletList(self)
            default:
                fatalError("list doesn't have a type")
            }
        case CMARK_NODE_ITEM:           return Item(self)
        case CMARK_NODE_CODE_BLOCK:     return CodeBlock(self)
        case CMARK_NODE_HTML_BLOCK:     return HtmlBlock(self)
        case CMARK_NODE_PARAGRAPH:      return Paragraph(self)
        case CMARK_NODE_HEADING:        return Heading(self)
        case CMARK_NODE_THEMATIC_BREAK: return ThematicBreak(self)
        case CMARK_NODE_TEXT:           return Text(self)
        case CMARK_NODE_SOFTBREAK:      return SoftBreak(self)
        case CMARK_NODE_LINEBREAK:      return LineBreak(self)
        case CMARK_NODE_CODE:           return Code(self)
        case CMARK_NODE_HTML_INLINE:    return HtmlInline(self)
        case CMARK_NODE_CUSTOM_INLINE:  return CustomInline(self)
        case CMARK_NODE_EMPH:           return Emphasis(self)
        case CMARK_NODE_STRONG:         return Strong(self)
        case CMARK_NODE_LINK:           return Link(self)
        case CMARK_NODE_IMAGE:          return Image(self)
        default:                        fatalError("unsupported node")
        }
    }
}


















































/**
 * A node is a wrapper of a raw `CMarkNode` belonging to the abstract syntax tree
 * generated by cmark.
 */
public class Node {
    public let cMarkNode: CMarkNode
    
    
    
    
    
    
    
   // MARK: Init
    init(_ cMarkNode: CMarkNode) {
        self.cMarkNode = cMarkNode
    }
    
    deinit {
        
        // Only free a document, not any other types of nodes,
        // otherwise nodes will be freed during creation of a document
        //
        // Implication: If Document is not used (nodes used by themselves, cmark_node will not be freed)
        //
        guard type == CMARK_NODE_DOCUMENT else { return }
        cmark_node_free(cMarkNode)
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: Wrap Properties
    // type
    public var type: cmark_node_type {
        return cmark_node_get_type(cMarkNode)
    }
    
    public var typeString: String {
        String(cString: cmark_node_get_type_string(cMarkNode))
    }
    
    // hierarchy
    public var parent: Node? {
        return Node(cmark_node_parent(cMarkNode))
    }
    
    public var children: [Node] {
        var result: [Node] = []

        var child = cmark_node_first_child(cMarkNode)
        while let c = child {
            result.append(c.wrap())
            child = cmark_node_next(child)
        }
        return result
    }

    // content
    public var literal: String? {
        if let cString = cmark_node_get_literal(cMarkNode) {
            return String(cString: cString)
        }
        
        return nil
        
    }

    // code
    /**
     * The fence info is an optional string that trails the opening sequence of backticks.
     * It can be used to provide some contextual information about the block, such as
     * the name of a programming language.
     *
     * For example:
     * ```
     * '''<fence info>
     * <literal>
     * '''
     * ```
     *
     */
    public var fenceInfo: String? {
        return String(cString: cmark_node_get_fence_info(cMarkNode))
    }

    // header
    /**
     * The level of the heading, a value between 1 and 6.
     */
    public var headingLevel: Int {
        return Int(cmark_node_get_heading_level(cMarkNode))
    }

    // list
    /**
     * The type of the list, either bullet or ordered.
     */
    public var listType: cmark_list_type {
        return cmark_node_get_list_type(cMarkNode)
    }

    public var listStart: Int {
        return Int(cmark_node_get_list_start(cMarkNode))
    }
    
    /**
     * Whether the list is "tight".
     *
     * If any of the list items are separated by a blank line, then this property is `false`. This value is
     * a hint to render the list with more (loose) or less (tight) spacing between items.
     */
    public var listTight: Bool {
        return cmark_node_get_list_tight(cMarkNode) != 0
    }

    // links
    /**
     * The url of the image / link, if present.
     *
     * For example:
     *
     * ```
     * ![<text>](<url>)
     * ```
     */
    public var url: String? {
        return String(cString: cmark_node_get_url(cMarkNode))
    }

    /**
     * The title of the image / link, if present.
     *
     * In the example below, the first line is a reference link, with the reference at the
     * bottom. `<text>` is literal text belonging to children nodes. The title occurs
     * after the url and is optional.
     *
     * ```
     * ![<text>][<id>]
     * ...
     * [<id>]: <url> "<title>"
     * ```
     */
    public var title: String? {
        return String(cString: cmark_node_get_title(cMarkNode))
    }
    
    
    
    
    
    
    // MARK: API
    public func render<T: Renderer>(with renderer: T, options: DownOptions, width: Int32) throws -> T.Result {
        return try renderer.render(self, options: options, width: width)
    }
    
    public func visit<T: Visitor>(with visitor: T) -> T.Result {
        return visitor.visit(self)
    }
    
    
    
    
    
    
    /**
     * True if the node has a sibling that succeeds it.
     */
    public var hasSuccessor: Bool {
        return cmark_node_next(cMarkNode) != nil
    }
    
    /**
     * Sequence of wrapped child nodes.
     */
    public var childSequence: ChildSequence {
        return ChildSequence(node: cMarkNode)
    }
    
    /**
     * Sequence of child nodes.
     */
    public struct ChildSequence: Sequence {

        let node: CMarkNode

        public func makeIterator() -> Iterator {
            return Iterator(node: cmark_node_first_child(node))
        }

        public struct Iterator: IteratorProtocol {

            var node: CMarkNode?

            public mutating func next() -> Node? {
                guard let node = node else { return nil }
                defer { self.node = cmark_node_next(node) }

                return node.wrap()
            }
        }
    }
}
















































// MARK: - Document
public class Document: Node, CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Document"
    }

    public convenience init(@BlockBuilder content: () -> [Block]) {
        let cMarkNode = createNode(type: CMARK_NODE_DOCUMENT)
        let blocks = content()
        cMarkNode.addChildren(blocks)
        self.init(cMarkNode)
    }
}


// MARK: - BlockQuote
public class BlockQuote: Node, CustomDebugStringConvertible, Block {
    public var debugDescription: String {
        return "Block Quote"
    }
    
    public convenience init(@BlockBuilder content: () -> [Block]) {
        let cMarkNode = createNode(type: CMARK_NODE_BLOCK_QUOTE)
        cMarkNode.addChildren(content())
        self.init(cMarkNode)
    }
}




// MARK: - Code
public class Code: Node, CustomDebugStringConvertible, Inline {
    
    public convenience init(_ literal: String) {
        let cMarkNode = createNode(type: CMARK_NODE_CODE)
        guard cmark_node_set_literal(cMarkNode, literal) == 1 else { fatalError("failed to set literal") }
        self.init(cMarkNode)
    }
    

    public var debugDescription: String {
        return "Code - \(literal ?? "nil")"
    }
}






// MARK: - CodeBlock
public class CodeBlock: Node, CustomDebugStringConvertible, Block {

    public convenience init(_ literal: String, fenceInfo: String) {
        let cMarkNode = createNode(type: CMARK_NODE_CODE_BLOCK)
        guard cmark_node_set_literal(cMarkNode, literal) == 1 else { fatalError("failed to set literal") }
        guard cmark_node_set_fence_info(cMarkNode, fenceInfo) == 1 else { fatalError("failed to set fence info") }
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        let content = (literal ?? "nil").replacingOccurrences(of: "\n", with: "\\n")
        return "Code Block - fenceInfo: \(fenceInfo ?? "nil"), content: \(content)"
    }
}






// // MARK: - CustomBlock
// public class CustomBlock: Node, CustomDebugStringConvertible {
//
//     init(_ literal: String, fenceInfo: String) {
//         let cMarkNode = createNode(type: CMARK_NODE_CODE_BLOCK)
//         guard cmark_node_set_literal(cMarkNode, literal) == 1 else { fatalError("failed to set literal") }
//         guard cmark_node_set_fence_info(cMarkNode, fenceInfo) == 1 else { fatalError("failed to set fence info") }
//         super.init(cMarkNode)
//     }
//
//
//     public var debugDescription: String {
//         return "Custom Block - \(literal ?? "nil")"
//     }
// }






// MARK: - CustomInline
public class CustomInline: Node, CustomDebugStringConvertible, Inline {
    
    public convenience init(onEnter: String, onExit: String, @InlineBuilder content: () -> [Inline]) {
        let cMarkNode = createNode(type: CMARK_NODE_CUSTOM_INLINE)
        cMarkNode.addChildren(content())
        
        guard cmark_node_set_on_enter(cMarkNode, onEnter) == 1 else { fatalError("failed to set onEnter") }
        guard cmark_node_set_on_exit(cMarkNode, onExit) == 1 else { fatalError("failed to set onExit") }
        
        self.init(cMarkNode)
    }

    public var debugDescription: String {
        return "Custom Inline - \(literal ?? "nil")"
    }
}





// MARK: - Emphasis
public class Emphasis: Node, CustomDebugStringConvertible, Inline {
    
    public convenience init(_ text: String) {
        let cMarkNode = createNode(type: CMARK_NODE_EMPH)
        cMarkNode.addChildren([Text(text)])
        self.init(cMarkNode)
    }
    
    public convenience init(@InlineBuilder content: () -> [Inline]) {
        let cMarkNode = createNode(type: CMARK_NODE_EMPH)
        cMarkNode.addChildren(content())
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "Emphasis"
    }
}






// MARK: - Heading
public class Heading: Node, CustomDebugStringConvertible, Block {
    
    public convenience init(level: Int32, _ text: String) {
        let cMarkNode = createNode(type: CMARK_NODE_EMPH)
        cMarkNode.addChildren([Text(text)])
        
        guard cmark_node_set_heading_level(cMarkNode, level) == 1 else { fatalError("failed to set heading level") }
        
        self.init(cMarkNode)
    }
    
    public convenience init(level: Int32, @InlineBuilder content: () -> [Inline]) {
        let cMarkNode = createNode(type: CMARK_NODE_HEADING)
        cMarkNode.addChildren(content())
        
        guard cmark_node_set_heading_level(cMarkNode, level) == 1 else { fatalError("failed to set heading level") }
        
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "Heading - L\(headingLevel)"
    }
}





// MARK: - HTMLBlock
public class HtmlBlock: Node, CustomDebugStringConvertible, Block {
    
    public convenience init(_ literal: String, fenceInfo: String) {
        let cMarkNode = createNode(type: CMARK_NODE_HTML_BLOCK)
        guard cmark_node_set_literal(cMarkNode, literal) == 1 else { fatalError("failed to set literal") }
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        let content = (literal ?? "nil").replacingOccurrences(of: "\n", with: "\\n")
        return "Html Block - content: \(content)"
    }
}





// MARK: - HTMLInline
public class HtmlInline: Node, CustomDebugStringConvertible, Inline {
    
    public convenience init(_ literal: String) {
        let cMarkNode = createNode(type: CMARK_NODE_HTML_INLINE)
        guard cmark_node_set_literal(cMarkNode, literal) == 1 else { fatalError("failed to set literal") }
        self.init(cMarkNode)
    }

    public var debugDescription: String {
        return "Html Inline - \(literal ?? "nil")"
    }
}





// MARK: - Image
public class Image: Node, CustomDebugStringConvertible, Inline {
  
    public convenience init(url: String, title: String? = nil, @InlineBuilder content: () -> [Inline]) {
        let cMarkNode = createNode(type: CMARK_NODE_IMAGE)
        cMarkNode.addChildren(content())
        
        guard cmark_node_set_title(cMarkNode, title) == 1 else { fatalError("could not set title") }
        guard cmark_node_set_url(cMarkNode, url) == 1 else { fatalError("could not set url") }
        
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "Image - title: \(title ?? "nil"), url: \(url ?? "nil"))"
    }
}






// MARK: - Item
public class Item: Node, CustomDebugStringConvertible {
    
    public convenience init(@BlockBuilder content: () -> [Block]) {
        let cMarkNode = createNode(type: CMARK_NODE_ITEM)
        cMarkNode.addChildren(content())
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "Item"
    }
}






// MARK: - LineBreak
public class LineBreak: Node, CustomDebugStringConvertible, Inline {
    
    public convenience init() {
        let cMarkNode = createNode(type: CMARK_NODE_LINEBREAK)
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "Line Break"
    }
}






// MARK: - Link
public class Link: Node, CustomDebugStringConvertible, Inline {

    public convenience init(url: String, title: String? = nil, @InlineBuilder content: () -> [Inline]) {
        let cMarkNode = createNode(type: CMARK_NODE_LINK)
        cMarkNode.addChildren(content())
        
        guard cmark_node_set_title(cMarkNode, title) == 1 else { fatalError("could not set title") }
        guard cmark_node_set_url(cMarkNode, url) == 1 else { fatalError("could not set url") }
        
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "Link - title: \(title ?? "nil"), url: \(url ?? "nil"))"
    }
}










// MARK: Ordered List
public class OrderedList: Node, CustomDebugStringConvertible, Block {
    
    public convenience init(delim: cmark_delim_type, start: Int32, tight: Int32, @ItemBuilder content: () -> [Item]) {
        let cMarkNode = createNode(type: CMARK_NODE_LIST)
        cMarkNode.addChildren(content())
        
        guard cmark_node_set_list_delim(cMarkNode, delim) == 1 else { fatalError("failed to set delim type") }
        guard cmark_node_set_list_start(cMarkNode, start) == 1 else { fatalError("failed to set list start") }
        guard cmark_node_set_list_tight(cMarkNode, tight) == 1 else { fatalError("failed to set list tight") }
        guard cmark_node_set_list_type(cMarkNode, CMARK_ORDERED_LIST) == 1 else { fatalError("failed to set list type") }
        
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "List - type: \(listType), isTight: \(listTight)"
    }
}







// MARK: Bullet List
public class BulletList: Node, CustomDebugStringConvertible, Block {
    
    public convenience init(tight: Int32, @ItemBuilder content: () -> [Item]) {
        let cMarkNode = createNode(type: CMARK_NODE_LIST)
        cMarkNode.addChildren(content())
        
        guard cmark_node_set_list_tight(cMarkNode, tight) == 1 else { fatalError("failed to set list tight") }
        guard cmark_node_set_list_type(cMarkNode, CMARK_BULLET_LIST) == 1 else { fatalError("failed to set list type") }
        
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "List - type: \(listType), isTight: \(listTight)"
    }
}





// MARK: - Paragraph
public class Paragraph: Node, CustomDebugStringConvertible, Block {
    
    public convenience init(@InlineBuilder content: () -> [Inline]) {
        let cMarkNode = createNode(type: CMARK_NODE_PARAGRAPH)
        cMarkNode.addChildren(content())
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "Paragraph"
    }
}





// MARK: - SoftBreak
public class SoftBreak: Node, CustomDebugStringConvertible, Inline {
    
    public convenience init() {
        let cMarkNode = createNode(type: CMARK_NODE_SOFTBREAK)
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "Soft Break"
    }
}





// MARK: - Strong
public class Strong: Node, CustomDebugStringConvertible, Inline {
    public var debugDescription: String {
        return "Strong"
    }
    
    public convenience init(_ text: String) {
        let cMarkNode = createNode(type: CMARK_NODE_STRONG)
        cMarkNode.addChildren([Text(text)])
        self.init(cMarkNode)
    }

    public convenience init(@InlineBuilder content: () -> [Inline]) {
        let cMarkNode = createNode(type: CMARK_NODE_STRONG)
        cMarkNode.addChildren(content())
        self.init(cMarkNode)
    }
}





// MARK: - Text
public class Text: Node, CustomDebugStringConvertible, Inline {
    public var debugDescription: String {
        return "Text - \(literal ?? "nil")"
    }
    
    public convenience init(_ literal: String) {
        let cMarkNode = createNode(type: CMARK_NODE_TEXT)
        guard cmark_node_set_literal(cMarkNode, literal) == 1 else { fatalError("failed to set literal") }
        self.init(cMarkNode)
    }
}





// MARK: - ThematicBreak
public class ThematicBreak: Node, CustomDebugStringConvertible, Block {
    
    public convenience init() {
        let cMarkNode = createNode(type: CMARK_NODE_THEMATIC_BREAK)
        self.init(cMarkNode)
    }
    
    public var debugDescription: String {
        return "Thematic Break"
    }
}


































// MARK: Helpers
fileprivate func createNode(type: cmark_node_type) -> CMarkNode {
    guard let node = cmark_node_new(type) else { fatalError("Could not create node of type \(type)") }
    return node
}


extension CMarkNode {
    func addChildren(_ children: [Block]) {
        for c in children {
            guard cmark_node_append_child(self, c.cMarkNode) == 1 else {
                fatalError("failed to add child")
            }
        }
    }
    
    func addChildren(_ children: [Inline]) {
        for c in children {
            guard cmark_node_append_child(self, c.cMarkNode) == 1 else {
                fatalError("failed to add child")
            }
        }
    }
    
    func addChildren(_ children: [Item]) {
        for c in children {
            guard cmark_node_append_child(self, c.cMarkNode) == 1 else {
                fatalError("failed to add child")
            }
        }
    }
}
