    import XCTest
    @testable import Down
    @testable import cmark

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
            XCTAssertEqual(md, "A very nice multiline document\n\nThis is the second line\n\n**A Bold*And italic*String**\n\n1)  First Item\n2)  Second Item\n3)  > Third Item\n\n<!-- end list -->\n\n  - First Item\n  - Second Item\n  - > Third Item\n")
        }
    }
