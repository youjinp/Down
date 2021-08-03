//
//  File.swift
//  
//
//  Created by Youjin Phea on 15/05/21.
//

import Foundation
import libcmark








// MARK: - Options
public struct DownOptions: OptionSet {

    // MARK: Properties
    public let rawValue: Int32

    // MARK: Life cycle
    public init(rawValue: Int32) { self.rawValue = rawValue }

    /**
     * Default options.
     */
    public static let `default` = DownOptions(rawValue: CMARK_OPT_DEFAULT)

    // MARK: Rendering Options
    /**
     * Include a `data-sourcepos` attribute on all block elements.
     */
    public static let sourcePos = DownOptions(rawValue: CMARK_OPT_SOURCEPOS)

    /**
     * Render `softbreak` elements as hard line breaks.
     */
    public static let hardBreaks = DownOptions(rawValue: CMARK_OPT_HARDBREAKS)

    /**
     * Suppress raw HTML and unsafe links (`javascript:`, `vbscript:`,
     * `file:`, and `data:`, except for `image/png`, `image/gif`,
     * `image/jpeg`, or `image/webp` mime types).  Raw HTML is replaced
     * by a placeholder HTML comment. Unsafe links are replaced by
     * empty strings.
     *
     * Note: this is the default option as of cmark v0.29.0. Use `unsafe`
     *       to disable this behavior.
     */
    public static let safe = DownOptions(rawValue: CMARK_OPT_SAFE)

    
    
    
    /**
     * Render raw HTML and unsafe links (`javascript:`, `vbscript:`,
     * `file:`, and `data:`, except for `image/png`, `image/gif`,
     * `image/jpeg`, or `image/webp` mime types).  By default,
     * raw HTML is replaced by a placeholder HTML comment. Unsafe
     * links are replaced by empty strings.
     *
     * Note: `safe` is the default as of cmark v0.29.0
     */
    public static let unsafe = DownOptions(rawValue: CMARK_OPT_UNSAFE)

    
    
    
    
    // MARK: Parsing Options
    /**
     * Normalize tree by consolidating adjacent text nodes.
     */
    public static let normalize = DownOptions(rawValue: CMARK_OPT_NORMALIZE)

    /**
     * Validate UTF-8 in the input before parsing, replacing illegal
     * sequences with the replacement character U+FFFD.
     */
    public static let validateUTF8 = DownOptions(rawValue: CMARK_OPT_VALIDATE_UTF8)

    
    
    
    /**
     * Convert straight quotes to curly, --- to em dashes, -- to en dashes.
     */
    public static let smart = DownOptions(rawValue: CMARK_OPT_SMART)

    
    
    
    
    // MARK: Combo Options
    /**
     * Combines 'unsafe' and 'smart' to render raw HTML and produce smart typography.
     */
    public static let smartUnsafe = DownOptions(rawValue: CMARK_OPT_SMART + CMARK_OPT_UNSAFE)

}












// MARK: - Errors
public enum DownErrors: Error {

    /**
     * Thrown when there was an issue converting the Markdown into an abstract syntax tree.
     */
    case markdownToASTError

    /**
     * Thrown when the abstract syntax tree could not be rendered into another format.
     */
    case astRenderingError

    /**
     * Thrown when an HTML string cannot be converted into an `NSData` representation.
     */
    case htmlDataConversionError

    #if os(macOS)

    /**
     * Thrown when a custom template bundle has a non-standard bundle format.
     *
     * Specifically, the file URL of the bundle’s subdirectory containing resource files could
     * not be found (i.e. the bundle's `resourceURL` property is nil).
     */
    case nonStandardBundleFormatError

    #endif

}
