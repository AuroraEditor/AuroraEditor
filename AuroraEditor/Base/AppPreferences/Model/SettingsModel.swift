//
//  SettingsModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
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
                    colorStart: Color(hex: "#C2C2C6"),
                    colorEnd: Color(hex: "#98989D")),
        SettingItem(name: "Accounts",
                    image: NSImage(systemSymbolName: "at", accessibilityDescription: nil)!,
                    colorStart: Color(hex: "#5FA5F8"),
                    colorEnd: Color(hex: "#3A82F7")),
        SettingItem(name: "Behaviors",
                    image: NSImage(systemSymbolName: "flowchart", accessibilityDescription: nil)!,
                    colorStart: Color(hex: "#EF8277"),
                    colorEnd: Color(hex: "#EB5545")),
        SettingItem(name: "Navigation",
                    image: NSImage(systemSymbolName: "arrow.triangle.turn.up.right.diamond",
                                   accessibilityDescription: nil)!,
                    colorStart: Color(hex: "#88E783"),
                    colorEnd: Color(hex: "#6BD45F")),
        SettingItem(name: "Themes",
                    image: NSImage(systemSymbolName: "paintbrush", accessibilityDescription: nil)!,
                    colorStart: Color(hex: "#84D8C9"),
                    colorEnd: Color(hex: "#11CBAA")),
        SettingItem(name: "Text Editing",
                    image: NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)!,
                    colorStart: Color(hex: "#D05FF8"),
                    colorEnd: Color(hex: "#9325BA")),
        SettingItem(name: "Terminal",
                    image: NSImage(systemSymbolName: "terminal", accessibilityDescription: nil)!,
                    colorStart: Color(hex: "#F9F6BC"),
                    colorEnd: Color(hex: "#DCD410")),
        SettingItem(name: "Key Bindings",
                    image: NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)!,
                    colorStart: Color(hex: "#515151"),
                    colorEnd: Color(hex: "#212121")),
        SettingItem(name: "Source Control",
                    image: NSImage.vault,
                    colorStart: Color(hex: "#5FA5F8"),
                    colorEnd: Color(hex: "#3A82F7")),
        SettingItem(name: "Components",
                    image: NSImage(systemSymbolName: "puzzlepiece", accessibilityDescription: nil)!,
                    colorStart: Color(hex: "#C2C2C6"),
                    colorEnd: Color(hex: "#98989D")),
        SettingItem(name: "Advanced",
                    image: NSImage(systemSymbolName: "gearshape.2", accessibilityDescription: nil)!,
                    colorStart: Color(hex: "#EE7994"),
                    colorEnd: Color(hex: "#EB4B63")),
        SettingItem(name: "Updates",
                    image: NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: nil)!,
                    colorStart: Color(hex: "#FC8C85"),
                    colorEnd: Color(hex: "#AB0800"))
    ]
}
