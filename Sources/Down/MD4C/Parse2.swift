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

public func parse2(_ string: String) -> Node? {
    
    root = nil
    nodeStack = []
    ignoreBlockLevel = 0
    
    var parser = MD_PARSER(
        abi_version: 0,
        flags: UInt32(MD_FLAG_NOINDENTEDCODEBLOCKS)) { blockType, detail, userData in
            
            guard ignoreBlockLevel == 0 else { return 1 }
            
            switch blockType {
            case MD_BLOCK_DOC:
                print("dbg - entered block: doc")
                nodeStack.append(Document {})
                
            case MD_BLOCK_QUOTE:
                print("dbg - entered block: quote")
                nodeStack.append(BlockQuote {})
                
            case MD_BLOCK_UL:
                print("dbg - entered block: bullet list")
                let detail = detail?.bindMemory(to: MD_BLOCK_UL_DETAIL.self, capacity: 1)
                nodeStack.append(BulletList(tight: detail?.pointee.is_tight ?? 1) {})
                
            case MD_BLOCK_OL:
                print("dbg - entered block: numbered list")
                let detail = detail?.bindMemory(to: MD_BLOCK_OL_DETAIL.self, capacity: 1)
                nodeStack.append(OrderedList(delim: CMARK_PERIOD_DELIM, start: Int32(detail?.pointee.start ?? 1), tight: detail?.pointee.is_tight ?? 1) {})
                
            case MD_BLOCK_LI:
                print("dbg - entered block: item")
                // let detail = detail?.bindMemory(to: MD_BLOCK_LI_DETAIL.self, capacity: 1)
                nodeStack.append(Item {})
                
            case MD_BLOCK_HR:
                print("dbg - entered block: hr")
                nodeStack.append(ThematicBreak())
                
            case MD_BLOCK_H:
                print("dbg - entered block: header")
                let detail = detail?.bindMemory(to: MD_BLOCK_H_DETAIL.self, capacity: 1)
                nodeStack.append(Heading(level: Int32(detail?.pointee.level ?? 1)) {})
                
            case MD_BLOCK_CODE:
                print("dbg - entered block: code")
                let detail = detail?.bindMemory(to: MD_BLOCK_CODE_DETAIL.self, capacity: 1)
                nodeStack.append(CodeBlock("", fenceInfo: detail?.pointee.lang.string ?? ""))
                
            case MD_BLOCK_HTML:
                print("dbg - entered block: html")
                nodeStack.append(HtmlBlock("", fenceInfo: ""))
                
            case MD_BLOCK_P:
                print("dbg - entered block: paragraph")
                nodeStack.append(Paragraph {})
                
            case MD_BLOCK_TABLE:
                print("dbg - entered block: table")
                ignoreBlockLevel += 1
                
            case MD_BLOCK_THEAD:
                print("dbg - entered block: table header")
                ignoreBlockLevel += 1
                
            case MD_BLOCK_TBODY:
                print("dbg - entered block: table body")
                ignoreBlockLevel += 1
                
            case MD_BLOCK_TR:
                print("dbg - entered block: table row")
                ignoreBlockLevel += 1
                
            case MD_BLOCK_TH:
                print("dbg - entered block: table h")
                ignoreBlockLevel += 1
                
            case MD_BLOCK_TD:
                print("dbg - entered block: table d")
                ignoreBlockLevel += 1
                
            default:
                print("dbg - entered block: unknown")
                ignoreBlockLevel += 1
            }
            
            return 0
            
        } leave_block: { blockType, detail, userData in
            
            switch blockType {
            case MD_BLOCK_DOC:
                print("dbg - left block: doc")
                
            case MD_BLOCK_QUOTE:
                print("dbg - left block: quote")
                
            case MD_BLOCK_UL:
                print("dbg - left block: ul")
                
            case MD_BLOCK_OL:
                print("dbg - left block: ol")
                
            case MD_BLOCK_LI:
                print("dbg - left block: li")
                
                // remove added paragraph for item
                if nodeStack.last is Paragraph {
                    let b = nodeStack.popLast() as! Block
                    if let l = nodeStack.last {
                        l.addChildren([b])
                    }
                }
                
            case MD_BLOCK_HR:
                print("dbg - left block: hr")
                
            case MD_BLOCK_H:
                print("dbg - left block: header")
                
            case MD_BLOCK_CODE:
                print("dbg - left block: code")
                
            case MD_BLOCK_HTML:
                print("dbg - left block: html")
                
            case MD_BLOCK_P:
                print("dbg - left block: paragraph")
                
            case MD_BLOCK_TABLE:
                print("dbg - left block: table")
                ignoreBlockLevel -= 1
                
            case MD_BLOCK_THEAD:
                print("dbg - left block: table header")
                ignoreBlockLevel -= 1
                
            case MD_BLOCK_TBODY:
                print("dbg - left block: table body")
                ignoreBlockLevel -= 1
                
            case MD_BLOCK_TR:
                print("dbg - left block: table row")
                ignoreBlockLevel -= 1
                
            case MD_BLOCK_TH:
                print("dbg - left block: table h")
                ignoreBlockLevel -= 1
                
            case MD_BLOCK_TD:
                print("dbg - left block: table d")
                ignoreBlockLevel -= 1
                
            default:
                print("dbg - left block: unknown")
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
                print("dbg - entered span: em")
                nodeStack.append(Emphasis {})
                
            case MD_SPAN_STRONG:
                print("dbg - entered span: strong")
                nodeStack.append(Strong {})
                
            case MD_SPAN_A:
                print("dbg - entered span: link")
                let detail = detail?.bindMemory(to: MD_SPAN_A_DETAIL.self, capacity: 1)
                nodeStack.append(Link(url: detail?.pointee.href.string ?? "", title: detail?.pointee.title.string ?? nil) {})
                
            case MD_SPAN_IMG:
                print("dbg - entered span: image")
                let detail = detail?.bindMemory(to: MD_SPAN_IMG_DETAIL.self, capacity: 1)
                nodeStack.append(Image(url: detail?.pointee.src.string ?? "", title: detail?.pointee.title.string ?? nil) {})
                
            case MD_SPAN_CODE:
                print("dbg - entered span: code")
                nodeStack.append(CustomInline(onEnter: "`", onExit: "`") {})
                
            case MD_SPAN_DEL:
                print("dbg - entered span: del")
                ignoreBlockLevel += 1
                
            case MD_SPAN_LATEXMATH:
                print("dbg - entered span: latexMath")
                ignoreBlockLevel += 1
                
            case MD_SPAN_LATEXMATH_DISPLAY:
                print("dbg - entered span: latexMathDisplay")
                ignoreBlockLevel += 1
                
            case MD_SPAN_WIKILINK:
                print("dbg - entered span: wikilink")
                ignoreBlockLevel += 1
                
            case MD_SPAN_U:
                print("dbg - entered span: span u")
                ignoreBlockLevel += 1
                
            default:
                print("dbg - entered span: unknown")
                ignoreBlockLevel += 1
            }
            
            return 0
            
        } leave_span: { blockType, detail, userData in
            
            switch blockType {
            case MD_SPAN_EM:
                print("dbg - left span: em")
                
            case MD_SPAN_STRONG:
                print("dbg - left span: strong")
                
            case MD_SPAN_A:
                print("dbg - left span: link")
                
            case MD_SPAN_IMG:
                print("dbg - left span: image")
                
            case MD_SPAN_CODE:
                print("dbg - left span: code")
                
            case MD_SPAN_DEL:
                print("dbg - left span: del")
                ignoreBlockLevel -= 1
                
            case MD_SPAN_LATEXMATH:
                print("dbg - left span: latexMath")
                ignoreBlockLevel -= 1
                
            case MD_SPAN_LATEXMATH_DISPLAY:
                print("dbg - left span: latexMathDisplay")
                ignoreBlockLevel -= 1
                
            case MD_SPAN_WIKILINK:
                print("dbg - left span: wikilink")
                ignoreBlockLevel -= 1
                
            case MD_SPAN_U:
                print("dbg - left span: span u")
                ignoreBlockLevel -= 1
                
            default:
                print("dbg - left span: unknown")
                ignoreBlockLevel -= 1
            }
            
            // append children
            if let block = nodeStack.popLast(), let b = block as? Inline {
                
                if let l = nodeStack.last {
                    l.addChildren([b])
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
                    nodeStack.append(Paragraph {})
                }
                
                nodeStack.last?.addChildren(nodes)
            }
            
            switch textType {
            case MD_TEXT_NORMAL:
                print("dbg - textType: normal")
                _addChildren([Text(str)])
                
            case MD_TEXT_NULLCHAR:
                print("dbg - textType: null")
                _addChildren([Text(str)])
                
            case MD_TEXT_BR:
                print("dbg - textType: break")
                _addChildren([LineBreak()])
                
            case MD_TEXT_SOFTBR:
                print("dbg - textType: softBreak")
                _addChildren([SoftBreak()])
                
            case MD_TEXT_ENTITY:
                print("dbg - textType: entity")
                _addChildren([Text(str)])
                
            case MD_TEXT_CODE:
                print("dbg - textType: code")
                nodeStack.last?.setLiteral(str)
                
            case MD_TEXT_HTML:
                print("dbg - textType: html")
                nodeStack.last?.setLiteral(str)
                
            case MD_TEXT_LATEXMATH:
                print("dbg - textType: latex")
                _addChildren([Text(str)])
                
            default:
                print("dbg - textType: unknown")
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
