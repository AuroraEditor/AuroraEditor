//
//  NSScreen.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/05.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

extension NSScreen {
    static let screenWidth = NSScreen.main?.frame.width
    static let screenHeight = NSScreen.main?.frame.height
    static let screenSize = NSScreen.main?.frame.size
}
