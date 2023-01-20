//
//  NSTableView+Background.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 20.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension NSTableView {
    /// Allows to set a lists background color in SwiftUI
    override open func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        backgroundColor = NSColor.clear
        enclosingScrollView?.drawsBackground = false
    }
}
