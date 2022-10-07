//
//  ThemeSetting.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public struct ThemeSetting: Codable {

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
        case scope, parentScopes, attributes, inSelectionAttributes, outSelectionAttributes
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(scope, forKey: .scope)
        try container.encode(parentScopes, forKey: .parentScopes)
        try container.encode(AttributesContainer(attributes: attributes), forKey: .attributes)
        try container.encode(AttributesContainer(attributes: inSelectionAttributes), forKey: .inSelectionAttributes)
        try container.encode(AttributesContainer(attributes: outSelectionAttributes), forKey: .outSelectionAttributes)
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: Keys.self)
        self.scope = try container.decode(String.self, forKey: .scope)
        self.parentScopes = try container.decode([String].self, forKey: .scope)
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

        // swiftlint:disable:next cyclomatic_complexity function_body_length
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)
            var lineHeightThemeAttribute: [LineHeightThemeAttribute] = []
            var tailIndentThemeAttribute: [TailIndentThemeAttribute] = []
//            var tabStopsThemeAttribute: [TabStopsThemeAttribute] = []
            var paragraphSpacingAfterThemeAttribute: [ParagraphSpacingAfterThemeAttribute] = []
            var textAlignmentThemeAttribute: [TextAlignmentThemeAttribute] = []
            var headIndentThemeAttribute: [HeadIndentThemeAttribute] = []
            var firstLineHeadIndentThemeAttribute: [FirstLineHeadIndentThemeAttribute] = []
//            var textBlockThemeAttribute: [TextBlockThemeAttribute] = []
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
//                } else if let attribute = attribute as? TabStopsThemeAttribute {
//                    tabStopsThemeAttribute.append(attribute)
                } else if let attribute = attribute as? ParagraphSpacingAfterThemeAttribute {
                    paragraphSpacingAfterThemeAttribute.append(attribute)
                } else if let attribute = attribute as? TextAlignmentThemeAttribute {
                    textAlignmentThemeAttribute.append(attribute)
                } else if let attribute = attribute as? HeadIndentThemeAttribute {
                    headIndentThemeAttribute.append(attribute)
                } else if let attribute = attribute as? FirstLineHeadIndentThemeAttribute {
                    firstLineHeadIndentThemeAttribute.append(attribute)
//                } else if let attribute = attribute as? TextBlockThemeAttribute {
//                    textBlockThemeAttribute.append(attribute)
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

            try container.encode(lineHeightThemeAttribute, forKey: .lineHeightThemeAttribute)
            try container.encode(tailIndentThemeAttribute, forKey: .tailIndentThemeAttribute)
//            try container.encode(tabStopsThemeAttribute, forKey: .tabStopsThemeAttribute)
            try container.encode(paragraphSpacingAfterThemeAttribute, forKey: .paragraphSpacingAfterThemeAttribute)
            try container.encode(textAlignmentThemeAttribute, forKey: .textAlignmentThemeAttribute)
            try container.encode(headIndentThemeAttribute, forKey: .headIndentThemeAttribute)
            try container.encode(firstLineHeadIndentThemeAttribute, forKey: .firstLineHeadIndentThemeAttribute)
//            try container.encode(textBlockThemeAttribute, forKey: .textBlockThemeAttribute)
            try container.encode(paragraphSpacingBeforeThemeAttribute, forKey: .paragraphSpacingBeforeThemeAttribute)
            try container.encode(defaultTabIntervalThemeAttribute, forKey: .defaultTabIntervalThemeAttribute)
            try container.encode(italicThemeAttribute, forKey: .italicThemeAttribute)
            try container.encode(kernThemeAttribute, forKey: .kernThemeAttribute)
            try container.encode(underlineThemeAttribute, forKey: .underlineThemeAttribute)
            try container.encode(boldThemeAttribute, forKey: .boldThemeAttribute)
            try container.encode(backgroundColorThemeAttribute, forKey: .backgroundColorThemeAttribute)
            try container.encode(colorThemeAttribute, forKey: .colorThemeAttribute)
            try container.encode(hiddenThemeAttribute, forKey: .hiddenThemeAttribute)
            try container.encode(ligatureThemeAttribute, forKey: .ligatureThemeAttribute)
            try container.encode(fontThemeAttribute, forKey: .fontThemeAttribute)
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            attributes = []
            // swiftlint:disable:next swiftlint_file_disabling
            // swiftlint:disable line_length
            attributes.append(contentsOf: try container.decode([LineHeightThemeAttribute].self,
                                                               forKey: .lineHeightThemeAttribute))
            attributes.append(contentsOf: try container.decode([TailIndentThemeAttribute].self,
                                                               forKey: .tailIndentThemeAttribute))
//            attributes.append(contentsOf: try container.decode([TabStopsThemeAttribute].self, forKey: .tabStopsThemeAttribute))
            attributes.append(contentsOf: try container.decode([ParagraphSpacingAfterThemeAttribute].self,
                                                               forKey: .paragraphSpacingAfterThemeAttribute))
            attributes.append(contentsOf: try container.decode([TextAlignmentThemeAttribute].self,
                                                               forKey: .textAlignmentThemeAttribute))
            attributes.append(contentsOf: try container.decode([HeadIndentThemeAttribute].self,
                                                               forKey: .headIndentThemeAttribute))
            attributes.append(contentsOf: try container.decode([FirstLineHeadIndentThemeAttribute].self,
                                                               forKey: .firstLineHeadIndentThemeAttribute))
//            attributes.append(contentsOf: try container.decode([TextBlockThemeAttribute].self, forKey: .textBlockThemeAttribute))
            attributes.append(contentsOf: try container.decode([ParagraphSpacingBeforeThemeAttribute].self,
                                                               forKey: .paragraphSpacingBeforeThemeAttribute))
            attributes.append(contentsOf: try container.decode([DefaultTabIntervalThemeAttribute].self,
                                                               forKey: .defaultTabIntervalThemeAttribute))
            attributes.append(contentsOf: try container.decode([ItalicThemeAttribute].self,
                                                               forKey: .italicThemeAttribute))
            attributes.append(contentsOf: try container.decode([KernThemeAttribute].self,
                                                               forKey: .kernThemeAttribute))
            attributes.append(contentsOf: try container.decode([UnderlineThemeAttribute].self,
                                                               forKey: .underlineThemeAttribute))
            attributes.append(contentsOf: try container.decode([BoldThemeAttribute].self,
                                                               forKey: .boldThemeAttribute))
            attributes.append(contentsOf: try container.decode([BackgroundColorThemeAttribute].self,
                                                               forKey: .backgroundColorThemeAttribute))
            attributes.append(contentsOf: try container.decode([ColorThemeAttribute].self,
                                                               forKey: .colorThemeAttribute))
            attributes.append(contentsOf: try container.decode([HiddenThemeAttribute].self,
                                                               forKey: .hiddenThemeAttribute))
            attributes.append(contentsOf: try container.decode([LigatureThemeAttribute].self,
                                                               forKey: .ligatureThemeAttribute))
            attributes.append(contentsOf: try container.decode([FontThemeAttribute].self,
                                                               forKey: .fontThemeAttribute))
            // swiftlint:enable line_length
        }
    }
}

class ThemeAttributeCodableContainer<ThemeAtrbItem: Codable>: Codable {
    let items: [ThemeAtrbItem]

    init(items: [ThemeAtrbItem]) {
        self.items = items
    }
}
