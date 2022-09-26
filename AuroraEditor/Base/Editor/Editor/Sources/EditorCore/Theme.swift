//
//  Theme.swift
//  
//
//  Created by Matthew Davidson on 28/11/19.
//

import Foundation

public class Theme {

    var name: String

    var root: ThemeTrieElement

    public init(name: String, settings: [ThemeSetting]) {
        self.name = name

        self.root = Theme.createTrie(settings: settings)
    }

    static func sortSettings(settings: [ThemeSetting]) -> [ThemeSetting] {
        return settings.sorted { (first, second) -> Bool in
            if first.scopeComponents.count != second.scopeComponents.count {
                return first.scopeComponents.count < second.scopeComponents.count
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

        if settings[0].scope.isEmpty {
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
        for comp in setting.scopeComponents {
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
            print("Warning: Theme parent scopes not implemented")
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
}
