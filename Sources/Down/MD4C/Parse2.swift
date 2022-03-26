//
//  File.swift
//  
//
//  Created by Youjin Phea on 4/02/22.
//

import Foundation
import libcmark
import libmd4c

private var root: Node?
private var nodeStack = [Node]()
private var ignoreBlockLevel = 0

public func parse2(_ string: String, flags: DownOptions2 = .default) -> Node? {
    
    root = nil
    nodeStack = []
    ignoreBlockLevel = 0
    
    var parser = MD_PARSER(
        abi_version: 0,
        flags: UInt32(flags.rawValue)) { blockType, detail, userData in
            
            guard ignoreBlockLevel == 0 else { return 1 }
            
            switch blockType {
            case MD_BLOCK_DOC:
                nodeStack.append(Document {})
                
            case MD_BLOCK_QUOTE:
                nodeStack.append(BlockQuote {})
                
            case MD_BLOCK_UL:
                let detail = detail?.bindMemory(to: MD_BLOCK_UL_DETAIL.self, capacity: 1)
                nodeStack.append(BulletList(tight: detail?.pointee.is_tight ?? 1) {})
                
            case MD_BLOCK_OL:
                let detail = detail?.bindMemory(to: MD_BLOCK_OL_DETAIL.self, capacity: 1)
                nodeStack.append(OrderedList(delim: CMARK_PERIOD_DELIM, start: Int32(detail?.pointee.start ?? 1), tight: detail?.pointee.is_tight ?? 1) {})
                
            case MD_BLOCK_LI:
                // let detail = detail?.bindMemory(to: MD_BLOCK_LI_DETAIL.self, capacity: 1)
                nodeStack.append(Item {})
                
            case MD_BLOCK_HR:
                nodeStack.append(ThematicBreak())
                
            case MD_BLOCK_H:
                let detail = detail?.bindMemory(to: MD_BLOCK_H_DETAIL.self, capacity: 1)
                nodeStack.append(Heading(level: Int32(detail?.pointee.level ?? 1)) {})
                
            case MD_BLOCK_CODE:
                let detail = detail?.bindMemory(to: MD_BLOCK_CODE_DETAIL.self, capacity: 1)
                nodeStack.append(CodeBlock("", fenceInfo: detail?.pointee.lang.string ?? ""))
                
            case MD_BLOCK_HTML:
                nodeStack.append(HtmlBlock("", fenceInfo: ""))
                
            case MD_BLOCK_P:
                nodeStack.append(Paragraph {})
                
            case MD_BLOCK_TABLE:
                ignoreBlockLevel += 1
                
            case MD_BLOCK_THEAD:
                ignoreBlockLevel += 1
                
            case MD_BLOCK_TBODY:
                ignoreBlockLevel += 1
                
            case MD_BLOCK_TR:
                ignoreBlockLevel += 1
                
            case MD_BLOCK_TH:
                ignoreBlockLevel += 1
                
            case MD_BLOCK_TD:
                ignoreBlockLevel += 1
                
            default:
                ignoreBlockLevel += 1
            }
            
            return 0
            
        } leave_block: { blockType, detail, userData in
            
            switch blockType {
            case MD_BLOCK_DOC:
                do {}
                
            case MD_BLOCK_QUOTE:
                do {}
                
            case MD_BLOCK_UL:
                do {}
                
            case MD_BLOCK_OL:
                do {}
                
            case MD_BLOCK_LI:
                do {}
                
            case MD_BLOCK_HR:
                do {}
                
            case MD_BLOCK_H:
                do {}
                
            case MD_BLOCK_CODE:
                do {}
                
            case MD_BLOCK_HTML:
                do {}
                
            case MD_BLOCK_P:
                do {}
                
            case MD_BLOCK_TABLE:
                ignoreBlockLevel -= 1
                
            case MD_BLOCK_THEAD:
                ignoreBlockLevel -= 1
                
            case MD_BLOCK_TBODY:
                ignoreBlockLevel -= 1
                
            case MD_BLOCK_TR:
                ignoreBlockLevel -= 1
                
            case MD_BLOCK_TH:
                ignoreBlockLevel -= 1
                
            case MD_BLOCK_TD:
                ignoreBlockLevel -= 1
                
            default:
                ignoreBlockLevel -= 1
            }
            
            // append children
            if let block = nodeStack.popLast(), let b = block as? Block {
                
                if let l = nodeStack.last {
                    l.addChildren([b])
                }
                
                else {
                    root = block
                }
            }
            
            return 0
            
        } enter_span: { blockType, detail, userData in
            
            guard ignoreBlockLevel == 0 else { return 1 }
            
            switch blockType {
            case MD_SPAN_EM:
                nodeStack.append(Emphasis {})
                
            case MD_SPAN_STRONG:
                nodeStack.append(Strong {})
                
            case MD_SPAN_A:
                let detail = detail?.bindMemory(to: MD_SPAN_A_DETAIL.self, capacity: 1)
                nodeStack.append(Link(url: detail?.pointee.href.string ?? "", title: detail?.pointee.title.string ?? nil) {})
                
            case MD_SPAN_IMG:
                let detail = detail?.bindMemory(to: MD_SPAN_IMG_DETAIL.self, capacity: 1)
                nodeStack.append(Image(url: detail?.pointee.src.string ?? "", title: detail?.pointee.title.string ?? nil) {})
                
            case MD_SPAN_CODE:
                nodeStack.append(CustomInline(onEnter: "`", onExit: "`") {})
                
            case MD_SPAN_DEL:
                ignoreBlockLevel += 1
                
            case MD_SPAN_LATEXMATH:
                ignoreBlockLevel += 1
                
            case MD_SPAN_LATEXMATH_DISPLAY:
                ignoreBlockLevel += 1
                
            case MD_SPAN_WIKILINK:
                ignoreBlockLevel += 1
                
            case MD_SPAN_U:
                ignoreBlockLevel += 1
                
            default:
                ignoreBlockLevel += 1
            }
            
            return 0
            
        } leave_span: { blockType, detail, userData in
            
            switch blockType {
            case MD_SPAN_EM:
                do {}
                
            case MD_SPAN_STRONG:
                do {}
                
            case MD_SPAN_A:
                do {}
                
            case MD_SPAN_IMG:
                do {}
                
            case MD_SPAN_CODE:
                do {}
                
            case MD_SPAN_DEL:
                ignoreBlockLevel -= 1
                
            case MD_SPAN_LATEXMATH:
                ignoreBlockLevel -= 1
                
            case MD_SPAN_LATEXMATH_DISPLAY:
                ignoreBlockLevel -= 1
                
            case MD_SPAN_WIKILINK:
                ignoreBlockLevel -= 1
                
            case MD_SPAN_U:
                ignoreBlockLevel -= 1
                
            default:
                ignoreBlockLevel -= 1
            }
            
            // append children
            if let block = nodeStack.popLast(), let b = block as? Inline {
                
                if let l = nodeStack.last {
                    
                    // if item and adding inlines, push a paragraph first
                    if l is Item {
                        if l.children.isEmpty { l.addChildren([ Paragraph {} ])}
                        l.children.last?.addChildren([b])
                    }
                    
                    else {
                        l.addChildren([b])
                    }
                }
                
                else {
                    root = block
                }
            }
            
            return 0
            
        } text: { textType, text, length, userData in
            
            guard ignoreBlockLevel == 0 else { return 1 }
            let str: String = {
                guard let text = text else { return "" }
                let data = Data(bytes: text, count: Int(length))
                let str = String(data: data, encoding: String.Encoding.utf8)
                return str ?? ""
            }()
            
            func _addChildren(_ nodes: [Inline]) {
                guard let l = nodeStack.last else { return }
                
                // if item and adding inlines, push a paragraph first
                if l is Item {
                    if l.children.isEmpty { l.addChildren([ Paragraph {} ]) }
                    l.children.last?.addChildren(nodes)
                }
                
                else {
                    l.addChildren(nodes)
                }
            }
            
            switch textType {
            case MD_TEXT_NORMAL:
                _addChildren([Text(str)])
                
            case MD_TEXT_NULLCHAR:
                _addChildren([Text(str)])
                
            case MD_TEXT_BR:
                _addChildren([LineBreak()])
                
            case MD_TEXT_SOFTBR:
                _addChildren([SoftBreak()])
                
            case MD_TEXT_ENTITY:
                _addChildren([Text(str)])
                
            case MD_TEXT_CODE:
                nodeStack.last?.setLiteral(str)
                
            case MD_TEXT_HTML:
                nodeStack.last?.setLiteral(str)
                
            case MD_TEXT_LATEXMATH:
                _addChildren([Text(str)])
                
            default:
                _addChildren([Text(str)])
                
            }
            
            return 0
            
        } debug_log: { msg, userData in
            do {}
            
        } syntax: {
            do {}
        }
    
    string.withCString {
        let stringLength = UInt32(strlen($0))
        md_parse($0, stringLength, &parser, nil)
    }
    
    return root
}

extension MD_ATTRIBUTE {
    var string: String {
        guard let t = self.text else { return "" }
        let len = self.size
        let data = Data(bytes: t, count: Int(len))
        let str = String(data: data, encoding: String.Encoding.utf8)
        return str ?? ""
    }
}
