//
//  File.swift
//  
//
//  Created by Youjin Phea on 15/05/21.
//

import Foundation
import cmark

// MARK: - Block Builder
@resultBuilder
public enum BlockBuilder {
    public static func buildBlock(_ values: BlockConvertible...) -> [Block] {
        values.flatMap { $0.asBlocks() }
    }

    public static func buildArray(_ components: [BlockConvertible]) -> [Block] {
        components.flatMap { $0.asBlocks() }
    }

    public static func buildOptional(_ component: BlockConvertible?) -> BlockConvertible {
        component ?? []
    }

    public static func buildEither(first: BlockConvertible) -> BlockConvertible {
        first
    }

    public static func buildEither(second: BlockConvertible) -> BlockConvertible {
        second
    }
}

public protocol BlockConvertible {
    func asBlocks() -> [Block]
}

// MARK: Block
public protocol Block: BlockConvertible, ItemConvertible {
    var cMarkNode: UnsafeMutablePointer<cmark_node> { get }
}

extension Block {
    public func asBlocks() -> [Block] {
        [self]
    }
}

// MARK: Blocks Array
extension Array: BlockConvertible where Element == Block {
    public func asBlocks() -> [Block] {
        self
    }
}

// MARK: Inlines
extension Inline {
    // wrap inlines in paragraphs
    public func asBlocks() -> [Block] {
        [Paragraph { self }]
    }
}

// MARK: String
extension String: BlockConvertible {
    // wrap literals in text and then in paragraphs
    public func asBlocks() -> [Block] {
        [Paragraph { Text(self) }]
    }
}



































































// MARK: - Inline Builder

@resultBuilder
public enum InlineBuilder {
    public static func buildBlock(_ values: InlineConvertible...) -> [Inline] {
        values.flatMap { $0.asInlines() }
    }

    public static func buildArray(_ components: [InlineConvertible]) -> [Inline] {
        components.flatMap { $0.asInlines() }
    }

    public static func buildOptional(_ component: InlineConvertible?) -> InlineConvertible {
        component ?? []
    }

    public static func buildEither(first: InlineConvertible) -> InlineConvertible {
        first
    }

    public static func buildEither(second: InlineConvertible) -> InlineConvertible {
        second
    }
}

public protocol InlineConvertible {
    func asInlines() -> [Inline]
}

// MARK: Inline
public protocol Inline: InlineConvertible, BlockConvertible, ItemConvertible {
    var cMarkNode: UnsafeMutablePointer<cmark_node> { get }
}

extension Inline {
    public func asInlines() -> [Inline] {
        [self]
    }
}

// MARK: Inlines Array
extension Array: InlineConvertible where Element == Inline {
    public func asInlines() -> [Inline] {
        self
    }
}

// MARK: String
extension String: InlineConvertible {
    // wrap literals in text
    public func asInlines() -> [Inline] {
        [Text(self)]
    }
}


































































// MARK: - Item Builder
@resultBuilder
public enum ItemBuilder {
    public static func buildBlock(_ values: ItemConvertible...) -> [Item] {
        values.flatMap { $0.asItems() }
    }

    public static func buildArray(_ components: [ItemConvertible]) -> [Item] {
        components.flatMap { $0.asItems() }
    }

    public static func buildOptional(_ value: ItemConvertible?) -> ItemConvertible {
        value ?? []
    }

    public static func buildEither(first: ItemConvertible) -> ItemConvertible {
        first
    }

    public static func buildEither(second: ItemConvertible) -> ItemConvertible {
        second
    }
}

public protocol ItemConvertible {
    func asItems() -> [Item]
}

// MARK: Item
extension Item: ItemConvertible {
    public func asItems() -> [Item] {
        [self]
    }
}


// MARK: Items Array
extension Array: ItemConvertible where Element == Item {
    public func asItems() -> [Item] {
        self
    }
}

// MARK: Blocks
extension Block {
    // wrap blocks in items
    public func asItems() -> [Item] {
        [Item { self }]
    }
}

// MARK: Inlines
extension Inline {
    // wrap inlines in paragraphs and then in items
    public func asItems() -> [Item] {
        [Item { Paragraph { self } }]
    }
}

// MARK: String
extension String: ItemConvertible {
    // wrap literals in text, then paragraphs and then in items
    public func asItems() -> [Item] {
        [Item { Paragraph { Text(self) } } ]
    }
}
