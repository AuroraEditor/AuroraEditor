//
//  String.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/04.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

extension String {

    var lastPathComponent: String {
        return NSString(string: self).lastPathComponent
    }

    var stringByDeletingPathExtension: String {
        return NSString(string: self).deletingPathExtension
    }

    /**
     Returns a string colored with the specified color.
     - parameter color: The string representation of the color.
     - returns: A string colored with the specified color.
     */
    func withColor(_ color: String?) -> String {
        // TODO: Find a way to tint the text in the debugger (eg: \u{001b}[fg\(color);\(self)\u{001b}[;)
        return ""
    }
}
