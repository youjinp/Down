//
//  File.swift
//  
//
//  Created by Youjin Phea on 15/05/21.
//

import Foundation
import cmark

// MARK: - Public
public func buildDocument(_ children: [Node]) -> Node {
    return createNode(type: CMARK_NODE_DOCUMENT, contains: .blocks, contents: children.map { $0.cmarkNode }).wrap()
}

public func buildBlockQuote(_ children: [Node]) -> Node {
    return createNode(type: CMARK_NODE_BLOCK_QUOTE, contains: .blocks, contents: children.map { $0.cmarkNode }).wrap()
}

public func buildOrderedList(_ children: [Node], delim: cmark_delim_type, start: Int32, tight: Int32) -> Node {
    let n = createNode(type: CMARK_NODE_LIST, contains: .items, contents: children.map { $0.cmarkNode })
    
    guard cmark_node_set_list_delim(n, delim) == 1 else { fatalError("failed to set delim type") }
    guard cmark_node_set_list_start(n, start) == 1 else { fatalError("failed to set list start") }
    guard cmark_node_set_list_tight(n, tight) == 1 else { fatalError("failed to set list tight") }
    guard cmark_node_set_list_type(n, CMARK_ORDERED_LIST) == 1 else { fatalError("failed to set list type") }
    
    return n.wrap()
}

public func buildBulletList(_ children: [Node], tight: Int32) -> Node {
    let n = createNode(type: CMARK_NODE_LIST, contains: .items, contents: children.map { $0.cmarkNode })
    
    guard cmark_node_set_list_tight(n, tight) == 1 else { fatalError("failed to set list tight") }
    guard cmark_node_set_list_type(n, CMARK_BULLET_LIST) == 1 else { fatalError("failed to set list type") }
    
    return n.wrap()
}

public func buildItem(_ children: [Node]) -> Node {
    return createNode(type: CMARK_NODE_ITEM, contains: .blocks, contents: children.map { $0.cmarkNode }).wrap()
}

public func buildCodeBlock(_ code: String, fenceInfo: String) -> Node {
    let n = createNode(type: CMARK_NODE_CODE_BLOCK, contains: .literal, contents: code)
    
    guard cmark_node_set_fence_info(n, fenceInfo) == 1 else { fatalError("failed to set fence info") }
    
    return n.wrap()
}

public func buildHTMLBlock(_ s: String) -> Node {
    return createNode(type: CMARK_NODE_HTML_BLOCK, contains: .literal, contents: s).wrap()
}

public func buildCustomBlock(_ s: String, onEnter: String, onExit: String) -> Node {
    let n = createNode(type: CMARK_NODE_CUSTOM_BLOCK, contains: [.inlines, .blocks, .items], contents: s)
    
    guard cmark_node_set_on_enter(n, onEnter) == 1 else { fatalError("failed to set onEnter") }
    guard cmark_node_set_on_exit(n, onExit) == 1 else { fatalError("failed to set onExit") }
    
    return n.wrap()
}

public func buildThematicBreak() -> Node {
    return createNode(type: CMARK_NODE_THEMATIC_BREAK, contains: []).wrap()
}

public func buildHeading(_ s: String, level: Int32) -> Node {
    let n = createNode(type: CMARK_NODE_HEADING, contains: .inlines, contents: s)
    
    guard cmark_node_set_heading_level(n, level) == 1 else { fatalError("failed to set heading level") }
    
    return n.wrap()
}

public func buildParagraph(_ children: [Node]) -> Node {
    return createNode(type: CMARK_NODE_PARAGRAPH, contains: .inlines, contents: children.map { $0.cmarkNode}).wrap()
}

public func buildText(_ s: String) -> Node {
    return createNode(type: CMARK_NODE_TEXT, contains: .literal, contents: s).wrap()
}

public func buildEmph(_ children: [Node]) -> Node {
    return createNode(type: CMARK_NODE_EMPH, contains: .inlines, contents: children.map { $0.cmarkNode}).wrap()
}

public func buildStrong(_ children: [Node]) -> Node {
    return createNode(type: CMARK_NODE_STRONG, contains: .inlines, contents: children.map { $0.cmarkNode}).wrap()
}

public func buildLink(_ children: [Node], url: String, title: String? = nil) -> Node {
    let n = createNode(type: CMARK_NODE_LINK, contains: .inlines, contents: children.map { $0.cmarkNode})
    
    guard cmark_node_set_title(n, title) == 1 else { fatalError("could not set title") }
    guard cmark_node_set_url(n, url) == 1 else { fatalError("could not set url") }
    
    return n.wrap()
}

public func buildImage(_ children: [Node], url: String, title: String? = nil) -> Node {
    let n = createNode(type: CMARK_NODE_IMAGE, contains: .inlines, contents: children.map { $0.cmarkNode})
    
    guard cmark_node_set_title(n, title) == 1 else { fatalError("could not set title") }
    guard cmark_node_set_url(n, url) == 1 else { fatalError("could not set url") }
    
    return n.wrap()
}

public func buildLinebreak() -> Node {
    return createNode(type: CMARK_NODE_LINEBREAK, contains: []).wrap()
}

public func buildSoftbreak() -> Node {
    return createNode(type: CMARK_NODE_SOFTBREAK, contains: []).wrap()
}

public func buildCode(_ s: String) -> Node {
    return createNode(type: CMARK_NODE_CODE, contains: .literal, contents: s).wrap()
}

public func buildHTMLInline(_ s: String) -> Node {
    return createNode(type: CMARK_NODE_HTML_INLINE, contains: .literal, contents: s).wrap()
}

public func buildCustomInline(_ s: String, onEnter: String, onExit: String) -> Node {
    let n = createNode(type: CMARK_NODE_CUSTOM_INLINE, contains: .inlines, contents: s)
    
    guard cmark_node_set_on_enter(n, onEnter) == 1 else { fatalError("failed to set onEnter") }
    guard cmark_node_set_on_exit(n, onExit) == 1 else { fatalError("failed to set onExit") }
    
    return n.wrap()
}








// MARK: - Types
fileprivate struct Contains: OptionSet {
    let rawValue: UInt8
    static let literal = Contains(rawValue: 1 << 0)
    static let blocks = Contains(rawValue: 1 << 1)
    static let inlines = Contains(rawValue: 1 << 2)
    static let items = Contains(rawValue: 1 << 3)
}

fileprivate enum NodeClass {
    case item, block, inline, unknown
}














// MARK: - Helpers
fileprivate func nodeGetClass(node: CMarkNode) -> NodeClass {
    let nt = cmark_node_get_type(node)
    
    // item type
    if nt == CMARK_NODE_ITEM {
        return .item
    }
    
    // block types
    else if nt.rawValue >= CMARK_NODE_FIRST_BLOCK.rawValue && nt.rawValue <= CMARK_NODE_LAST_BLOCK.rawValue {
        return .block
    }
    
    // inline types
    else if nt.rawValue >= CMARK_NODE_FIRST_INLINE.rawValue && nt.rawValue <= CMARK_NODE_LAST_INLINE.rawValue {
        return .inline
    }
    
    else {
        return .unknown
    }
}

fileprivate func addChildren(node: CMarkNode, contents: Any?, contains: Contains) {
    
    // skip if nil
    guard contents != nil else { return }
    
    // if array
    if let array = contents as? [Any] {
        for c in array {
            addChildren(node: node, contents: c, contains: contains)
        }
        
        return
    }

    // set literal
    if contains == .literal {
        guard let s = contents as? String else { fatalError("content is not a string?") }
        guard cmark_node_set_literal(node, s) == 1 else { fatalError("Could not set literal") }
        return
    }
    
    // child
    let child: CMarkNode = {
        if let c = contents as? CMarkNode {
            return c
        }
        
        // if content is not a node, wrap it in a text node
        else {
            guard let n = cmark_node_new(CMARK_NODE_TEXT) else { fatalError("Could not create text node") }
            guard let s = contents as? String else { fatalError("content is not a string?") }
            guard cmark_node_set_literal(n, s) == 1 else { fatalError("Could not set literal") }
            return n
        }
    }()
    
    let childClass = nodeGetClass(node: child)
    
    // if child has correct type, add to node
    if childClass == .item && contains.contains(.items) ||
        childClass == .block && contains.contains(.blocks) ||
        childClass == .inline && contains.contains(.inlines)  {
        guard cmark_node_append_child(node, child) == 1 else { fatalError("Could not append child") }
    }
    
    // wrap blocks in items
    else if childClass == .block && contains.contains(.items) {
        guard let item = cmark_node_new(CMARK_NODE_ITEM) else { fatalError("Could not create item node") }
        guard cmark_node_append_child(item, child) == 1 else { fatalError("Could not append child to item") }
        guard cmark_node_append_child(node, item) == 1 else { fatalError("Could not append item to node") }
    }
    
    // wrap inlines in paragraphs
    else if childClass == .inline && contains.contains(.blocks) {
        guard let para = cmark_node_new(CMARK_NODE_PARAGRAPH) else { fatalError("Could not create paragraph node") }
        guard cmark_node_append_child(para, child) == 1 else { fatalError("Could not append child to para") }
        guard cmark_node_append_child(node, para) == 1 else { fatalError("Could not append para to node") }
    }
    
    // wrap inlines in paragraphs and then in items
    else if childClass == .inline && contains.contains(.items) {
        guard let para = cmark_node_new(CMARK_NODE_PARAGRAPH) else { fatalError("Could not create paragraph node") }
        guard let item = cmark_node_new(CMARK_NODE_ITEM) else { fatalError("Could not create item node") }
        guard cmark_node_append_child(para, child) == 1 else { fatalError("Could not append child to para") }
        guard cmark_node_append_child(item, para) == 1 else { fatalError("Could not append para to item") }
        guard cmark_node_append_child(node, item) == 1 else { fatalError("Could not append item to node") }
    }
    
    else {
        fatalError("Tried to add a node with class \(childClass) to a node with class \(nodeGetClass(node: node))")
    }
}

fileprivate func createNode(type: cmark_node_type, contains: Contains, contents: Any? = nil) -> CMarkNode {
    
    guard let node = cmark_node_new(type) else { fatalError("Could not create node of type \(type)") }
    
    // no content, return
    guard contents != nil else { return node }
    
    // set attributes if defined
    // if fields.count > 0, let d = contents as? [String: AnyHashable] {
    //     for (field, fn) in fields {
    //         if let v = d[field] {
    //             fn(node, v)
    //         }
    //     }
    // }
    
    // treat rest as children
    addChildren(node: node, contents: contents, contains: contains)
        
    return node
}
