//
//  FileIcon.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// File icon
public enum FileIcon {
    // Checks the file of the item extension
    public enum FileType: String {
        /// JSON file icon
        case json

        /// JavaScript file icon
        case js

        /// CSS file icon
        case css

        /// JSX file icon
        case jsx

        /// Swift file icon
        case swift

        /// Environment file icon
        case env

        /// Example file icon
        case example

        /// Gitignore file icon
        case gitignore

        /// PNG file icon
        case png

        /// JPG file icon
        case jpg

        /// JPEG file icon
        case jpeg

        /// ICO file icon
        case ico

        /// SVG file icon
        case svg

        /// Entitlements file icon
        case entitlements

        /// Plist file icon
        case plist

        /// Markdown file icon
        case md

        /// Text file icon
        case txt = "text"

        /// RTF file icon
        case rtf

        /// HTML file icon
        case html

        /// Python file icon
        case py

        /// Shell file icon
        case sh

        /// License file icon
        case LICENSE

        /// Java file icon
        case java

        /// Header file icon
        case h

        /// Objective-C file icon
        case m

        /// Vue file icon
        case vue

        /// Go file icon
        case go

        /// Sum file icon
        case sum

        /// Mod file icon
        case mod

        /// Makefile file icon
        case makefile

        /// TypeScript file icon
        case ts
    }

    /// Returns a string describing a SFSymbol for files
    /// If not specified otherwise this will return `"doc"`
    /// 
    /// - Parameter fileType: The file type
    /// 
    /// - Returns: The SFSymbol name
    public static func fileIcon(
        fileType: FileType
    ) -> String {
        switch fileType {
        case .json, .js:
            return "curlybraces"
        case .css:
            return "number"
        case .jsx:
            return "atom"
        case .swift:
            return "swift"
        case .env, .example:
            return "gearshape.fill"
        case .gitignore:
            return "arrow.triangle.branch"
        case .png, .jpg, .jpeg, .ico:
            return "photo"
        case .svg:
            return "square.fill.on.circle.fill"
        case .entitlements:
            return "checkmark.seal"
        case .plist:
            return "tablecells"
        case .md, .txt, .rtf:
            return "doc.plaintext"
        case .html, .py, .sh:
            return "chevron.left.forwardslash.chevron.right"
        case .LICENSE:
            return "key.fill"
        case .java:
            return "cup.and.saucer"
        case .h:
            return "h.square"
        case .m:
            return "m.square"
        case .vue:
            return "v.square"
        case .go:
            return "g.square"
        case .sum:
            return "s.square"
        case .mod:
            return "m.square"
        case .makefile:
            return "terminal"
        default:
            return "doc"
        }
    }

    /// Returns a `Color` for a specific `fileType`
    /// If not specified otherwise this will return `Color.accentColor`
    /// 
    /// - Parameter fileType: The file type
    /// 
    /// - Returns: The color
    public static func iconColor(fileType: FileType) -> Color {
        switch fileType {
        case .swift, .html:
            return .orange
        case .java:
            return .red
        case .js, .entitlements, .json, .LICENSE:
            return Color("SidebarYellow")
        case .css, .ts, .jsx, .md, .py:
            return .blue
        case .sh:
            return .green
        case .vue:
            return Color(red: 0.255, green: 0.722, blue: 0.514, opacity: 1.000)
        case .h:
            return Color(red: 0.667, green: 0.031, blue: 0.133, opacity: 1.000)
        case .m:
            return Color(red: 0.271, green: 0.106, blue: 0.525, opacity: 1.000)
        case .go:
            return Color(red: 0.02, green: 0.675, blue: 0.757, opacity: 1.0)
        case .sum, .mod:
            return Color(red: 0.925, green: 0.251, blue: 0.478, opacity: 1.0)
        case .makefile:
            return Color(red: 0.937, green: 0.325, blue: 0.314, opacity: 1.0)
        default:
            return .accentColor
        }
    }
}
