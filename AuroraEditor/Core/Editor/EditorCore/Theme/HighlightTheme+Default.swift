//
//  HighlightTheme+Default.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 9/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit

public extension HighlightTheme {
    /// Default Highlight theme
    @available(*, deprecated)
    nonisolated(unsafe) static let `default`: HighlightTheme = HighlightTheme(settings: [
        ThemeSetting(scope: "source", parentScopes: [], attributes: [
            ColorThemeAttribute(color: .exampleTextColor),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize, weight: .regular)),
            LigatureThemeAttribute(ligature: 0)
        ]),

        // Scope looks like following - // or //
        ThemeSetting(scope: "comment", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#A0D07D"))
        ]),
        ThemeSetting(scope: "punctuation.definition.comment", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#A0D07D"))
        ]),

        // Scope looks like following - ""
        ThemeSetting(scope: "punctuation.definition.string", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FC6A5D"))
        ]),

        // Scope looks like following - 0, 1, 2, 3, 4
        ThemeSetting(scope: "constant.numeric", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D0BF69"))
        ]),
        ThemeSetting(scope: "keyword.other.unit", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D0BF69"))
        ]),
        ThemeSetting(scope: "support.constant", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D0BF69"))
        ]),

        ThemeSetting(scope: "constant.language", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                           weight: .bold))
        ]),
        ThemeSetting(scope: "entity.name.tag", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                           weight: .bold))
        ]),
        ThemeSetting(scope: "keyword", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                           weight: .bold))
        ]),
        ThemeSetting(scope: "storage.modifier.swift", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                           weight: .bold))
        ]),
        ThemeSetting(scope: "storage.type", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                           weight: .bold))
        ]),
        ThemeSetting(scope: "support.type.primitive", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                           weight: .bold))
        ]),
        ThemeSetting(scope: "variable.language", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                           weight: .bold))
        ]),

        ThemeSetting(scope: "support.type", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#ACF2E4"))
        ]),

        ThemeSetting(scope: "meta.definition.function", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#5DD8FF"))
        ]),
        ThemeSetting(scope: "meta.definition.method", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#5DD8FF"))
        ]),
        ThemeSetting(scope: "meta.method.declaration", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#5DD8FF"))
        ]),

        ThemeSetting(scope: "variable.parameter", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#48b7db"))
        ]),

        ThemeSetting(scope: "entity.name.type", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#E5CFFF"))
        ]),

        ThemeSetting(scope: "entity.other.inherited-class", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#5DD8FF"))
        ]),

        ThemeSetting(scope: "keyword.operator", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#A167E6"))
        ]),
        ThemeSetting(scope: "keyword.control.preprocessor", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FFA14F"))
        ]),
        ThemeSetting(scope: "keyword.control.import", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D0A8FF")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                           weight: .bold))
        ]),
        ThemeSetting(scope: "keyword.control.exception", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D0A8FF")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                           weight: .bold))
        ]),
        ThemeSetting(scope: "keyword.control.async.swift", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#5DD8FF")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                           weight: .bold))
        ]),
        ThemeSetting(scope: "punctuation.definition.preprocessor", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FFA14F"))
        ]),

        ThemeSetting(scope: "markup.underline.link", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#6699FF"))
        ]),

        ThemeSetting(scope: "meta.object-literal.key", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#72BFAE"))
        ]),

        ThemeSetting(scope: "support.constant", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D0BF69"))
        ]),
        ThemeSetting(scope: "meta.function-call", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#CDA1FF"))
        ]),
        ThemeSetting(scope: "meta.function", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D0A8FF"))
        ]),
        ThemeSetting(scope: "meta.function", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D0A8FF"))
        ]),
        ThemeSetting(scope: "support.type", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D0A8FF"))
        ]),
        ThemeSetting(scope: "meta.interface", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D0A8FF"))
        ]),

        ThemeSetting(scope: "constant.language.boolean", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D6C455"))
        ]),
        ThemeSetting(scope: "meta.objectliteral", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#D6C455"))
        ]),

        ThemeSetting(scope: "enum-case-clause", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#48b7db"))
        ]),
        ThemeSetting(scope: "keyword.control.branch", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#48b7db"))
        ]),

        ThemeSetting(scope: "punctuation", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#DFDFE0"))
        ]),

        ThemeSetting(scope: "support.variable", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#83C9BC"))
        ]),

        ThemeSetting(scope: "punctuation.terminator.statement", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#FFFFFF"))
        ]),

        ThemeSetting(scope: "comment.block.documentation", parentScopes: [], attributes: [
            ColorThemeAttribute(color: NSColor(hex: "#A0D07D")),
            FontThemeAttribute(font: .monospacedSystemFont(ofSize: 11, weight: .medium))
        ])
    ])
}

private let fontSize: CGFloat = 12

fileprivate extension NSColor {
    static let exampleTextColor = NSColor(hex: "#FFF")
}
