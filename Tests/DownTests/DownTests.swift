import XCTest
@testable import Down
@testable import libcmark

final class DownTests: XCTestCase {
    func testExample() {
        
        let doc = Document {
            "A very nice multiline document"
            "This is the second line"
            Strong {
                "A Bold"
                Emphasis("And italic")
                "String"
            }
            OrderedList(delim: CMARK_PAREN_DELIM, start: 1, tight: 1) {
                "First Item"
                Paragraph { "Second Item" }
                Item { BlockQuote { "Third Item" } }
            }
            BulletList(tight: 1) {
                "First Item"
                Paragraph { "Second Item" }
                Item { BlockQuote { "Third Item" } }
            }
        }
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let md = try! doc.render(with: CommonMarkRenderer(), options: .default, width: 0)
        let exp = """
        A very nice multiline document
        
        This is the second line
        
        **A Bold*And italic*String**
        
        1) First Item
        2) Second Item
        3) > Third Item
        - First Item
        - Second Item
        - > Third Item
        
        """
        
        XCTAssertEqual(md, exp)
    }
    
    func testBullet() {
        let s = "- a **Offline**"
        
        let b = Down.parse2(s)!
        let expDoc = Document {
            BulletList(tight: 1) {
                Paragraph {
                    "a "
                    Strong { "Offline" }
                }
            }
        }
        
        let t = try! b.render(with: CommonMarkRenderer(), options: .default, width: 0)
        let e = try! expDoc.render(with: CommonMarkRenderer(), options: .default, width: 0)
        
        XCTAssertEqual(t, e)
    }
    
    func testNestedBullet() {
        
        let doc = Document {
            BulletList(tight: 1) {
                "First Item"
                Paragraph { "Second Item" }
                Item {
                    BlockQuote { "Third Item" }
                    BulletList(tight: 1) {
                        Item {
                            "Nested item"
                            BulletList(tight: 1) {
                                "NNested item"
                            }
                        }
                    }
                }
            }
            "Text"
        }
        
        let md = try! doc.render(with: CommonMarkRenderer(), options: .default, width: 0)
        let exp = """
        - First Item
        - Second Item
        - > Third Item
            - Nested item
                - NNested item

        Text
        
        """
        XCTAssertEqual(md, exp)
    }
    
    func testSwitchList() {
        
        let doc = Document {
            BulletList(tight: 1) {
                Item { "a" }
                Item { "b" }
            }
            OrderedList(delim: .init(rawValue: 1), start: 1, tight: 1) {
                Item { "1" }
                Item { "2" }
            }
            "Abc"
        }
        
        let md = try! doc.render(with: CommonMarkRenderer(), options: .default, width: 0)
        let exp = """
        - a
        - b
        1. 1
        2. 2

        Abc
        
        """
        XCTAssertEqual(md, exp)
    }
    
    func testNestedList() {
        
        let doc = Document {
            OrderedList(delim: .init(rawValue: 1), start: 1, tight: 1) {
                Item {
                    "Item 1"
                    BulletList(tight: 1) {
                        Item { "Item a" }
                        Item { "Item b" }
                    }
                    OrderedList(delim: .init(rawValue: 1), start: 1, tight: 1) {
                        Item { "Item c" }
                        Item { "Item d" }
                    }
                }
            }
            BulletList(tight: 1) {
                Item {
                    "Item 2"
                    BulletList(tight: 1) {
                        Item { "Item a" }
                        Item { "Item b" }
                    }
                    OrderedList(delim: .init(rawValue: 1), start: 1, tight: 1) {
                        Item { "Item c" }
                        Item { "Item d" }
                    }
                }
            }
        }
        
        let md = try! doc.render(with: CommonMarkRenderer(), options: .default, width: 0)
        let exp = """
        1. Item 1
            - Item a
            - Item b
            1. Item c
            2. Item d
        - Item 2
            - Item a
            - Item b
            1. Item c
            2. Item d
        
        """
        XCTAssertEqual(md, exp)
    }
}
