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
        case json
        case js
        case css
        case jsx
        case swift
        case env
        case example
        case gitignore
        case png
        case jpg
        case jpeg
        case ico
        case svg
        case entitlements
        case plist
        case md
        case txt = "text"
        case rtf
        case html
        case py
        case sh
        case LICENSE
        case java
        case h
        case m
        case vue
        case go
        case sum
        case mod
        case makefile
        case ts
    }

    private static let fileTypeToSymbol: [FileType: String] = [
            .json: "curlybraces",
            .js: "curlybraces",
            .css: "number",
            .jsx: "atom",
            .swift: "swift",
            .env: "gearshape.fill",
            .example: "gearshape.fill",
            .gitignore: "arrow.triangle.branch",
            .png: "photo",
            .jpg: "photo",
            .jpeg: "photo",
            .ico: "photo",
            .svg: "square.fill.on.circle.fill",
            .entitlements: "checkmark.seal",
            .plist: "tablecells",
            .md: "doc.plaintext",
            .txt: "doc.plaintext",
            .rtf: "doc.plaintext",
            .html: "chevron.left.forwardslash.chevron.right",
            .py: "chevron.left.forwardslash.chevron.right",
            .sh: "chevron.left.forwardslash.chevron.right",
            .LICENSE: "key.fill",
            .java: "cup.and.saucer",
            .h: "h.square",
            .m: "m.square",
            .vue: "v.square",
            .go: "g.square",
            .sum: "s.square",
            .mod: "m.square",
            .makefile: "terminal",
            .ts: "doc"
        ]

    /// Returns a string describing a SFSymbol for files
    /// If not specified otherwise this will return `"doc"`
    public static func fileIcon(fileType: FileType) -> String {
        return fileTypeToSymbol[fileType] ?? "doc"
    }

    private static let fileTypeToColor: [FileType: Color] = [
        .swift: .orange,
        .html: .orange,
        .java: .red,
        .js: Color("SidebarYellow"),
        .entitlements: Color("SidebarYellow"),
        .json: Color("SidebarYellow"),
        .LICENSE: Color("SidebarYellow"),
        .css: .blue,
        .ts: .blue,
        .jsx: .blue,
        .md: .blue,
        .py: .blue,
        .sh: .green,
        .vue: Color(red: 0.255, green: 0.722, blue: 0.514, opacity: 1.000),
        .h: Color(red: 0.667, green: 0.031, blue: 0.133, opacity: 1.000),
        .m: Color(red: 0.271, green: 0.106, blue: 0.525, opacity: 1.000),
        .go: Color(red: 0.02, green: 0.675, blue: 0.757, opacity: 1.0),
        .sum: Color(red: 0.925, green: 0.251, blue: 0.478, opacity: 1.0),
        .mod: Color(red: 0.925, green: 0.251, blue: 0.478, opacity: 1.0),
        .makefile: Color(red: 0.937, green: 0.325, blue: 0.314, opacity: 1.0)
    ]

    /// Returns a `Color` for a specific `fileType`
    /// If not specified otherwise this will return `Color.accentColor`
    public static func iconColor(fileType: FileType) -> Color {
        return fileTypeToColor[fileType] ?? .accentColor
    }
}
