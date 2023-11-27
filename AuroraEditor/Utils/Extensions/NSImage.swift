//
//  NSImage.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/11/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit

extension NSImage {
    func resizing(to targetSize: NSSize) -> NSImage {
        if size.width <= targetSize.width && size.height <= targetSize.height {
            return self
        }
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        draw(in: NSRect(origin: .zero, size: targetSize),
             from: NSRect(origin: .zero, size: size),
             operation: .sourceOver,
             fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}
