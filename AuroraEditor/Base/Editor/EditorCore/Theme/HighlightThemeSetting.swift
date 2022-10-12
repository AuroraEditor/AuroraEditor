//
//  ThemeSetting.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public struct ThemeSetting: Codable {

    var scopes: [String]
    var parentScopes: [String]

    var attributes: [ThemeAttribute]
    var inSelectionAttributes: [ThemeAttribute]
    var outSelectionAttributes: [ThemeAttribute]

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
        scopes: [String],
        parentScopes: [String] = [],
        attributes: [ThemeAttribute] = [],
        inSelectionAttributes: [ThemeAttribute] = [],
        outSelectionAttributes: [ThemeAttribute] = []
    ) {
        self.scopes = scopes
        self.parentScopes = parentScopes
        self.attributes = attributes
        self.inSelectionAttributes = inSelectionAttributes
        self.outSelectionAttributes = outSelectionAttributes
    }

    /// Allows init using a single scope instead of an array
    public init(
        scope: String,
        parentScopes: [String] = [],
        attributes: [ThemeAttribute] = [],
        inSelectionAttributes: [ThemeAttribute] = [],
        outSelectionAttributes: [ThemeAttribute] = []
    ) {
        self.scopes = [scope]
        self.parentScopes = parentScopes
        self.attributes = attributes
        self.inSelectionAttributes = inSelectionAttributes
        self.outSelectionAttributes = outSelectionAttributes
    }

    /// ThemeAttributes:
    /// - ``LineThemeAttribute``
    ///     - ``LineHeightThemeAttribute``
    ///     - ``TailIndentThemeAttribute``
    ///     - ``TabStopsThemeAttribute`` NOTE: not implemented due to difficulties with NSTextTab
    ///     - ``ParagraphSpacingAfterThemeAttribute``
    ///     - ``TextAlignmentThemeAttribute``
    ///     - ``HeadIndentThemeAttribute``
    ///     - ``FirstLineHeadIndentThemeAttribute``
    ///     - ``TextBlockThemeAttribute`` NOTE: not implemented due to difficulties with NSTextBlock
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
        case scopes, parentScopes, attributes, inSelectionAttributes, outSelectionAttributes
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(scopes, forKey: .scopes)
        try container.encode(parentScopes, forKey: .parentScopes)
        try container.encode(AttributesContainer(attributes: attributes), forKey: .attributes)
        try container.encode(AttributesContainer(attributes: inSelectionAttributes), forKey: .inSelectionAttributes)
        try container.encode(AttributesContainer(attributes: outSelectionAttributes), forKey: .outSelectionAttributes)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.scopes = try container.decode([String].self, forKey: .scopes)
        self.parentScopes = try container.decode([String].self, forKey: .scopes)
        self.attributes = try container.decode(AttributesContainer.self, forKey: .attributes).attributes
        self.inSelectionAttributes = try container.decode(AttributesContainer.self,
                                                          forKey: .inSelectionAttributes).attributes
        self.outSelectionAttributes = try container.decode(AttributesContainer.self,
                                                           forKey: .outSelectionAttributes).attributes
    }

    class AttributesContainer: Codable {
        var attributes: [ThemeAttribute]

        init(attributes: [ThemeAttribute]) {
            self.attributes = attributes
        }

        enum Keys: CodingKey {
            // LineThemeAttributes
            case lineHeightThemeAttribute,
                 tailIndentThemeAttribute,
//                 tabStopsThemeAttribute,
                 paragraphSpacingAfterThemeAttribute,
                 textAlignmentThemeAttribute,
                 headIndentThemeAttribute,
                 firstLineHeadIndentThemeAttribute,
//                 textBlockThemeAttribute,
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

        // swiftlint:disable:next swiftlint_file_disabling
        // swiftlint:disable line_length opening_brace

        // swiftlint:disable:next cyclomatic_complexity function_body_length
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)
            var lineHeightThemeAttribute: [LineHeightThemeAttribute] = []
            var tailIndentThemeAttribute: [TailIndentThemeAttribute] = []
            var paragraphSpacingAfterThemeAttribute: [ParagraphSpacingAfterThemeAttribute] = []
            var textAlignmentThemeAttribute: [TextAlignmentThemeAttribute] = []
            var headIndentThemeAttribute: [HeadIndentThemeAttribute] = []
            var firstLineHeadIndentThemeAttribute: [FirstLineHeadIndentThemeAttribute] = []
            var paragraphSpacingBeforeThemeAttribute: [ParagraphSpacingBeforeThemeAttribute] = []
            var defaultTabIntervalThemeAttribute: [DefaultTabIntervalThemeAttribute] = []

            var italicThemeAttribute: [ItalicThemeAttribute] = []
            var kernThemeAttribute: [KernThemeAttribute] = []
            var underlineThemeAttribute: [UnderlineThemeAttribute] = []
            var boldThemeAttribute: [BoldThemeAttribute] = []
            var backgroundColorThemeAttribute: [BackgroundColorThemeAttribute] = []
            var colorThemeAttribute: [ColorThemeAttribute] = []
            var hiddenThemeAttribute: [HiddenThemeAttribute] = []
            var ligatureThemeAttribute: [LigatureThemeAttribute] = []
            var fontThemeAttribute: [FontThemeAttribute] = []

            for attribute in attributes {
                if let attribute = attribute as? LineHeightThemeAttribute {
                    lineHeightThemeAttribute.append(attribute)
                } else if let attribute = attribute as? TailIndentThemeAttribute {
                    tailIndentThemeAttribute.append(attribute)
                } else if let attribute = attribute as? ParagraphSpacingAfterThemeAttribute {
                    paragraphSpacingAfterThemeAttribute.append(attribute)
                } else if let attribute = attribute as? TextAlignmentThemeAttribute {
                    textAlignmentThemeAttribute.append(attribute)
                } else if let attribute = attribute as? HeadIndentThemeAttribute {
                    headIndentThemeAttribute.append(attribute)
                } else if let attribute = attribute as? FirstLineHeadIndentThemeAttribute {
                    firstLineHeadIndentThemeAttribute.append(attribute)
                } else if let attribute = attribute as? ParagraphSpacingBeforeThemeAttribute {
                    paragraphSpacingBeforeThemeAttribute.append(attribute)
                } else if let attribute = attribute as? DefaultTabIntervalThemeAttribute {
                    defaultTabIntervalThemeAttribute.append(attribute)
                } else if let attribute = attribute as? ItalicThemeAttribute {
                    italicThemeAttribute.append(attribute)
                } else if let attribute = attribute as? KernThemeAttribute {
                    kernThemeAttribute.append(attribute)
                } else if let attribute = attribute as? UnderlineThemeAttribute {
                    underlineThemeAttribute.append(attribute)
                } else if let attribute = attribute as? BoldThemeAttribute {
                    boldThemeAttribute.append(attribute)
                } else if let attribute = attribute as? BackgroundColorThemeAttribute {
                    backgroundColorThemeAttribute.append(attribute)
                } else if let attribute = attribute as? ColorThemeAttribute {
                    colorThemeAttribute.append(attribute)
                } else if let attribute = attribute as? HiddenThemeAttribute {
                    hiddenThemeAttribute.append(attribute)
                } else if let attribute = attribute as? LigatureThemeAttribute {
                    ligatureThemeAttribute.append(attribute)
                } else if let attribute = attribute as? FontThemeAttribute {
                    fontThemeAttribute.append(attribute)
                }
            }

            if !lineHeightThemeAttribute.isEmpty             { try container.encode(lineHeightThemeAttribute, forKey: .lineHeightThemeAttribute) }
            if !tailIndentThemeAttribute.isEmpty             { try container.encode(tailIndentThemeAttribute, forKey: .tailIndentThemeAttribute) }
            if !paragraphSpacingAfterThemeAttribute.isEmpty  { try container.encode(paragraphSpacingAfterThemeAttribute, forKey: .paragraphSpacingAfterThemeAttribute) }
            if !textAlignmentThemeAttribute.isEmpty          { try container.encode(textAlignmentThemeAttribute, forKey: .textAlignmentThemeAttribute) }
            if !headIndentThemeAttribute.isEmpty             { try container.encode(headIndentThemeAttribute, forKey: .headIndentThemeAttribute) }
            if !firstLineHeadIndentThemeAttribute.isEmpty    { try container.encode(firstLineHeadIndentThemeAttribute, forKey: .firstLineHeadIndentThemeAttribute) }
            if !paragraphSpacingBeforeThemeAttribute.isEmpty { try container.encode(paragraphSpacingBeforeThemeAttribute, forKey: .paragraphSpacingBeforeThemeAttribute) }
            if !defaultTabIntervalThemeAttribute.isEmpty     { try container.encode(defaultTabIntervalThemeAttribute, forKey: .defaultTabIntervalThemeAttribute) }
            if !italicThemeAttribute.isEmpty                 { try container.encode(italicThemeAttribute, forKey: .italicThemeAttribute) }
            if !kernThemeAttribute.isEmpty                   { try container.encode(kernThemeAttribute, forKey: .kernThemeAttribute) }
            if !underlineThemeAttribute.isEmpty              { try container.encode(underlineThemeAttribute, forKey: .underlineThemeAttribute) }
            if !boldThemeAttribute.isEmpty                   { try container.encode(boldThemeAttribute, forKey: .boldThemeAttribute) }
            if !backgroundColorThemeAttribute.isEmpty        { try container.encode(backgroundColorThemeAttribute, forKey: .backgroundColorThemeAttribute) }
            if !colorThemeAttribute.isEmpty                  { try container.encode(colorThemeAttribute, forKey: .colorThemeAttribute) }
            if !hiddenThemeAttribute.isEmpty                 { try container.encode(hiddenThemeAttribute, forKey: .hiddenThemeAttribute) }
            if !ligatureThemeAttribute.isEmpty               { try container.encode(ligatureThemeAttribute, forKey: .ligatureThemeAttribute) }
            if !fontThemeAttribute.isEmpty                   { try container.encode(fontThemeAttribute, forKey: .fontThemeAttribute) }
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            attributes = []

            attributes.append(contentsOf: (try? container.decode([LineHeightThemeAttribute].self,
                                                               forKey: .lineHeightThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([TailIndentThemeAttribute].self,
                                                               forKey: .tailIndentThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([ParagraphSpacingAfterThemeAttribute].self,
                                                               forKey: .paragraphSpacingAfterThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([TextAlignmentThemeAttribute].self,
                                                               forKey: .textAlignmentThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([HeadIndentThemeAttribute].self,
                                                               forKey: .headIndentThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([FirstLineHeadIndentThemeAttribute].self,
                                                               forKey: .firstLineHeadIndentThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([ParagraphSpacingBeforeThemeAttribute].self,
                                                               forKey: .paragraphSpacingBeforeThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([DefaultTabIntervalThemeAttribute].self,
                                                               forKey: .defaultTabIntervalThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([ItalicThemeAttribute].self,
                                                               forKey: .italicThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([KernThemeAttribute].self,
                                                               forKey: .kernThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([UnderlineThemeAttribute].self,
                                                               forKey: .underlineThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([BoldThemeAttribute].self,
                                                               forKey: .boldThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([BackgroundColorThemeAttribute].self,
                                                               forKey: .backgroundColorThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([ColorThemeAttribute].self,
                                                               forKey: .colorThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([HiddenThemeAttribute].self,
                                                               forKey: .hiddenThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([LigatureThemeAttribute].self,
                                                               forKey: .ligatureThemeAttribute)) ?? [])
            attributes.append(contentsOf: (try? container.decode([FontThemeAttribute].self,
                                                               forKey: .fontThemeAttribute)) ?? [])
        }

        // swiftlint:enable line_length
    }
}

class ThemeAttributeCodableContainer<ThemeAtrbItem: Codable>: Codable {
    let items: [ThemeAtrbItem]

    init(items: [ThemeAtrbItem]) {
        self.items = items
    }
}

extension String {
    var scopeComponents: [Substring] {
        self.split(separator: ".")
    }
}
