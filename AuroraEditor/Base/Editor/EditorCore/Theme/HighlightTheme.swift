//
//  HighlightTheme.swift
//  
//
//  Created by Matthew Davidson on 28/11/19.
//

import Foundation

public class HighlightTheme: Codable {

    var root: ThemeTrieElement

    var settings: [ThemeSetting]

    public init(settings: [ThemeSetting]) {
        self.settings = settings
        self.root = HighlightTheme.createTrie(settings: settings)
    }

    static func sortSettings(settings: [ThemeSetting]) -> [ThemeSetting] {
        return settings.sorted { (first, second) -> Bool in
            if first.scopes.count != second.scopes.count {
                return first.scopes.count < second.scopes.count
            }
            return first.parentScopes.count < second.parentScopes.count
        }
    }

    static func createTrie(settings: [ThemeSetting]) -> ThemeTrieElement {
        var settings = sortSettings(settings: settings)
        let root = ThemeTrieElement(
            children: [:],
            attributes: [:],
            inSelectionAttributes: [:],
            outSelectionAttributes: [:],
            parentScopeElements: [:]
        )

        if settings.isEmpty {
            return root
        }

        if settings[0].scopes.isEmpty {
            root.attributes = settings.removeFirst().attributes.reduce([:], {
                var res = $0
                res[$1.key] = $1
                return res
            })
            root.inSelectionAttributes = settings.removeFirst().inSelectionAttributes.reduce([:], {
                var res = $0
                res[$1.key] = $1
                return res
            })
            root.outSelectionAttributes = settings.removeFirst().outSelectionAttributes.reduce([:], {
                var res = $0
                res[$1.key] = $1
                return res
            })
        }

        for setting in settings {
            addSettingToTrie(root: root, setting: setting)
        }

        return root
    }

    static func addSettingToTrie(root: ThemeTrieElement, setting: ThemeSetting) {
        var curr = root
        var prev: ThemeTrieElement?
        // TODO: Optimise to collapse
        for scope in setting.scopes {
            for comp in scope.scopeComponents {
                if let child = curr.children[String(comp)] {
                    prev = curr
                    curr = child
                } else {
                    let new = ThemeTrieElement(
                        children: [:],
                        attributes: [:],
                        inSelectionAttributes: [:],
                        outSelectionAttributes: [:],
                        parentScopeElements: [:]
                    )
                    curr.children[String(comp)] = new
                    prev = curr
                    curr = new
                }
            }
        }
        guard prev != nil else {
            print("Error: prev is nil") // swiftlint:disable:this disallow_print
            return
        }
        curr.attributes = (prev?.attributes ?? [:])
        curr.inSelectionAttributes = (prev?.inSelectionAttributes ?? [:])
        curr.outSelectionAttributes = (prev?.outSelectionAttributes ?? [:])
        for attr in setting.attributes {
            curr.attributes[attr.key] = attr
        }
        for attr in setting.inSelectionAttributes {
            curr.inSelectionAttributes[attr.key] = attr
        }
        for attr in setting.outSelectionAttributes {
            curr.outSelectionAttributes[attr.key] = attr
        }

        if !setting.parentScopes.isEmpty {
            print("Warning: HighlightTheme parent scopes not implemented")
        }
    }

    public func allAttributes(forScopeName scopeName: ScopeName
    ) -> ([ThemeAttribute], [ThemeAttribute], [ThemeAttribute]) { // swiftlint:disable:this large_tuple
        var curr = root
        for comp in scopeName.components {
            if let child = curr.children[String(comp)] {
                curr = child
            } else {
                break
            }
        }
        return (Array(curr.attributes.values),
                Array(curr.inSelectionAttributes.values),
                Array(curr.outSelectionAttributes.values))
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let settings = try container.decode([ThemeSetting].self, forKey: .settings)
        self.init(settings: settings)
    }

    enum Keys: CodingKey {
        case settings
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(settings, forKey: .settings)
    }
}
