//
//  SettingsModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/19.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

class SettingsModel: ObservableObject {

    init(setting: [SettingItem] = SettingsModel.settingItems) {
        self.setting = setting
        self.selectedId = setting[0].id
    }

    @Published
    var setting: [SettingItem]

    @Published
    var selectedId: String?

    static let settingItems = [
        SettingItem(name: "General",
                    image: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!,
                    colour: .gray),
        SettingItem(name: "Accounts",
                    image: NSImage(systemSymbolName: "at", accessibilityDescription: nil)!,
                    colour: .purple),
        SettingItem(name: "Behaviors",
                    image: NSImage(systemSymbolName: "flowchart", accessibilityDescription: nil)!,
                    colour: .blue),
        SettingItem(name: "Navigation",
                    image: NSImage(systemSymbolName: "arrow.triangle.turn.up.right.diamond",
                                   accessibilityDescription: nil)!,
                    colour: .gray),
        SettingItem(name: "Themes",
                    image: NSImage(systemSymbolName: "paintbrush", accessibilityDescription: nil)!,
                    colour: .cyan),
        SettingItem(name: "Text Editing",
                    image: NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)!,
                    colour: .green),
        SettingItem(name: "Terminal",
                    image: NSImage(systemSymbolName: "terminal", accessibilityDescription: nil)!,
                    colour: .red),
        SettingItem(name: "Key Bindings",
                    image: NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)!,
                    colour: .gray),
        SettingItem(name: "Source Control",
                    image: NSImage.vault,
                    colour: .purple),
        SettingItem(name: "Components",
                    image: NSImage(systemSymbolName: "puzzlepiece", accessibilityDescription: nil)!,
                    colour: .green),
        SettingItem(name: "Locations",
                    image: NSImage(systemSymbolName: "externaldrive", accessibilityDescription: nil)!,
                    colour: .purple),
        SettingItem(name: "Advanced",
                    image: NSImage(systemSymbolName: "gearshape.2", accessibilityDescription: nil)!,
                    colour: .pink)
    ]
}
