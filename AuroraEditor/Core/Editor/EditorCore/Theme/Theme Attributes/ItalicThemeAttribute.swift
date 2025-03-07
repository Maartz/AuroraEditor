//
//  ItalicThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 5/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Cocoa

@available(*, deprecated)
public class ItalicThemeAttribute: TokenThemeAttribute, Codable {
    public var key: String = "italic"

    public init() {}

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        let font = attrStr.attributes(at: range.location, effectiveRange: nil)[.font] as? NSFont ?? NSFont()
        let newFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
        attrStr.addAttribute(.font, value: newFont, range: range)
    }

}
