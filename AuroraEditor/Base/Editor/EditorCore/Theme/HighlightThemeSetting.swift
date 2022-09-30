//
//  ThemeSetting.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public struct ThemeSetting {

    var scope: String // TODO: Make this into a list of strings
    var parentScopes: [String]

    var attributes: [ThemeAttribute]
    var inSelectionAttributes: [ThemeAttribute]
    var outSelectionAttributes: [ThemeAttribute]

    var scopeComponents: [Substring] {
        return scope.split(separator: ".")
    }

    ///
    /// Constructor
    ///
    /// - Parameter scope: Dot separated scope to apply the theme setting to.
    /// - Parameter parentScopes: **NOT IMPLEMENTED**
    /// - Parameter attributes: Base attributes to apply to text that matches the scope.
    /// - Parameter inSelectionAttributes: Attributes to apply to text that matches the scope
    ///     on a line which has some part of the selection.
    /// - Parameter outSelectionAttributes: Attributes to apply to text that matches the scope
    ///     on a line which does not have some part of the selection.
    ///
    public init(
        scope: String,
        parentScopes: [String] = [],
        attributes: [ThemeAttribute] = [],
        inSelectionAttributes: [ThemeAttribute] = [],
        outSelectionAttributes: [ThemeAttribute] = []
    ) {
        self.scope = scope
        self.parentScopes = parentScopes
        self.attributes = attributes
        self.inSelectionAttributes = inSelectionAttributes
        self.outSelectionAttributes = outSelectionAttributes
    }

    /// ThemeAttributes:
    /// - ``LineThemeAttribute``
    ///     - ``LineHeightThemeAttribute``
    ///     - ``TailIndentThemeAttribute``
    ///     - ``TabStopsThemeAttribute``
    ///     - ``ParagraphSpacingAfterThemeAttribute``
    ///     - ``TextAlignmentThemeAttribute``
    ///     - ``HeadIndentThemeAttribute``
    ///     - ``FirstLineHeadIndentThemeAttribute``
    ///     - ``TextBlockThemeAttribute``
    ///     - ``ParagraphSpacingBeforeThemeAttribute``
    ///     - ``DefaultTabIntervalThemeAttribute``
    /// - ``TokenThemeAttribute``
    ///     - ``ItalicThemeAttribute``
    ///     - ``KernThemeAttribute``
    ///     - ``UnderlineThemeAttribute``
    ///     - ``BoldThemeAttribute``
    ///     - ``ActionThemeAttribute``
    ///     - ``BackgroundColorThemeAttribute``
    ///     - ``ColorThemeAttribute``
    ///     - ``HiddenThemeAttribute``
    ///     - ``LigatureThemeAttribute``
    ///     - ``FontThemeAttribute``
    enum Keys: CodingKey {
        case scope, parentScopes

        // LineThemeAttributes
        case lineHeightThemeAttribute,
             tailIndentThemeAttribute,
             tabStopsThemeAttribute,
             paragraphSpacingAfterThemeAttribute,
             textAlignmentThemeAttribute,
             headIndentThemeAttribute,
             firstLineHeadIndentThemeAttribute,
             textBlockThemeAttribute,
             paragraphSpacingBeforeThemeAttribute,
             defaultTabIntervalThemeAttribute

        // TokenThemeAttributes
        case italicThemeAttribute,
             kernThemeAttribute,
             underlineThemeAttribute,
             boldThemeAttribute,
             actionThemeAttribute,
             backgroundColorThemeAttribute,
             colorThemeAttribute,
             hiddenThemeAttribute,
             ligatureThemeAttribute,
             fontThemeAttribute
    }

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(scope, forKey: .scope)
        try container.encode(parentScopes, forKey: .parentScopes)
        try container.encode(attributes, forKey: .attributes)
        try container.encode(inSelectionAttributes, forKey: .inSelectionAttributes)
        try container.encode(outSelectionAttributes, forKey: .outSelectionAttributes)
        try container.encode(scopeComponents, forKey: .scopeComponents)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func encodeAttribute(attribute: ThemeAttribute,
                                 container: inout KeyedEncodingContainer<ThemeSetting.Keys>) throws {
        if let attribute = attribute as? LineHeightThemeAttribute {
            try container.encode(attribute, forKey: .lineHeightThemeAttribute)
        } else if let attribute = attribute as? LineHeightThemeAttribute {
            try container.encode(attribute, forKey: .lineHeightThemeAttribute)
        } else if let attribute = attribute as? TailIndentThemeAttribute {
            try container.encode(attribute, forKey: .tailIndentThemeAttribute)
        } else if let attribute = attribute as? TabStopsThemeAttribute {
            try container.encode(attribute, forKey: .tabStopsThemeAttribute)
        } else if let attribute = attribute as? ParagraphSpacingAfterThemeAttribute {
            try container.encode(attribute, forKey: .paragraphSpacingAfterThemeAttribute)
        } else if let attribute = attribute as? TextAlignmentThemeAttribute {
            try container.encode(attribute, forKey: .textAlignmentThemeAttribute)
        } else if let attribute = attribute as? HeadIndentThemeAttribute {
            try container.encode(attribute, forKey: .headIndentThemeAttribute)
        } else if let attribute = attribute as? FirstLineHeadIndentThemeAttribute {
            try container.encode(attribute, forKey: .firstLineHeadIndentThemeAttribute)
        } else if let attribute = attribute as? TextBlockThemeAttribute {
            try container.encode(attribute, forKey: .textBlockThemeAttribute)
        } else if let attribute = attribute as? ParagraphSpacingBeforeThemeAttribute {
            try container.encode(attribute, forKey: .paragraphSpacingBeforeThemeAttribute)
        } else if let attribute = attribute as? DefaultTabIntervalThemeAttribute {
            try container.encode(attribute, forKey: .defaultTabIntervalThemeAttribute)
        } else if let attribute = attribute as? ItalicThemeAttribute {
            try container.encode(attribute, forKey: .italicThemeAttribute)
        } else if let attribute = attribute as? KernThemeAttribute {
            try container.encode(attribute, forKey: .kernThemeAttribute)
        } else if let attribute = attribute as? UnderlineThemeAttribute {
            try container.encode(attribute, forKey: .underlineThemeAttribute)
        } else if let attribute = attribute as? BoldThemeAttribute {
            try container.encode(attribute, forKey: .boldThemeAttribute)
        } else if let attribute = attribute as? ActionThemeAttribute {
            try container.encode(attribute, forKey: .actionThemeAttribute)
        } else if let attribute = attribute as? BackgroundColorThemeAttribute {
            try container.encode(attribute, forKey: .backgroundColorThemeAttribute)
        } else if let attribute = attribute as? ColorThemeAttribute {
            try container.encode(attribute, forKey: .colorThemeAttribute)
        } else if let attribute = attribute as? HiddenThemeAttribute {
            try container.encode(attribute, forKey: .hiddenThemeAttribute)
        } else if let attribute = attribute as? LigatureThemeAttribute {
            try container.encode(attribute, forKey: .ligatureThemeAttribute)
        } else if let attribute = attribute as? FontThemeAttribute {
            try container.encode(attribute, forKey: .fontThemeAttribute)
        }
    }
}
