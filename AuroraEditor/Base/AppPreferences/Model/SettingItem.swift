//
//  SettingItem.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/19.
//

import SwiftUI

struct SettingItem: Identifiable {
    let id = UUID().uuidString
    let name: String
    let image: NSImage
    let colorStart: Color
    let colorEnd: Color
}
