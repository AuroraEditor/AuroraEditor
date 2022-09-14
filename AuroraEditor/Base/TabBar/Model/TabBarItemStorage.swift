//
//  TabBarItemStorage.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 14/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

class TabBarItemStorage: NSObject, NSCoding, Encodable, Decodable {

    var tabBarID: TabBarItemID
    var children: [TabBarItemStorage]?

    init(tabBarID: TabBarItemID, children: [TabBarItemStorage]? = nil) {
        self.tabBarID = tabBarID
        self.children = children
    }

    required convenience init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        guard let data = propertyList as? Data,
              let tabBarItemStorage = try? PropertyListDecoder()
                .decode(TabBarItemStorage.self, from: data) else { return nil }
        self.init(tabBarID: tabBarItemStorage.tabBarID, children: tabBarItemStorage.children)
    }

    required init?(coder: NSCoder) {
        guard let tabBarID = coder.decodeObject(forKey: "tabBarID") as? TabBarItemID,
              let children = coder.decodeObject(forKey: "children") as? [TabBarItemStorage] else { return nil }

        self.tabBarID = tabBarID
        self.children = children
    }

    func encode(with coder: NSCoder) {
        coder.encode(tabBarID, forKey: "tabBarID")
        coder.encode(children, forKey: "children")
    }

    var itemCount: Int {
        if let children = children {
            var soFar = 1 // 1 for the item itself

            // for each child, add its item count (recursive)
            for child in children {
                soFar += child.itemCount
            }
            return soFar
        } else {
            return 1 // 1 for the item itself
        }
    }
}

extension Array<TabBarItemStorage> {
    var allTabs: Int {
        return reduce(0, { soFar, tab in
            return soFar + (tab.itemCount)
        })
    }
}
