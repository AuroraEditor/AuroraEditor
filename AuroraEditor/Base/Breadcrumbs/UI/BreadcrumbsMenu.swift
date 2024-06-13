//
//  BreadcrumbsMenu.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/29.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

/// A menu that represents the breadcrumbs of a file system.
public final class BreadcrumsMenu: NSMenu, NSMenuDelegate {
    /// File items
    private let fileItems: [FileSystemClient.FileItem]

    /// Tapped open file closure
    private let tappedOpenFile: (FileSystemClient.FileItem) -> Void

    /// Creates a new instance of `BreadcrumsMenu`.
    /// 
    /// - Parameter fileItems: The file items.
    /// - Parameter tappedOpenFile: The tapped open file closure.
    public init(
        fileItems: [FileSystemClient.FileItem],
        tappedOpenFile: @escaping (FileSystemClient.FileItem) -> Void
    ) {
        self.fileItems = fileItems
        self.tappedOpenFile = tappedOpenFile
        super.init(title: "")
        delegate = self
        fileItems.forEach { item in
            let menuItem = BreadcrumbsMenuItem(
                fileItem: item
            ) { item in
                tappedOpenFile(item)
            }
            self.addItem(menuItem)
        }
        autoenablesItems = false
    }

    /// Creates a new instance of `BreadcrumsMenu`.
    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Only when menu item is highlighted then generate its submenu
    /// 
    /// - Parameter menu: The menu.
    /// - Parameter item: The item.
    public func menu(_: NSMenu, willHighlight item: NSMenuItem?) {
        if let highlightedItem = item, let submenuItems = highlightedItem.submenu?.items, submenuItems.isEmpty {
            if let highlightedFileItem = highlightedItem.representedObject as? FileSystemClient.FileItem {
                highlightedItem.submenu = generateSubmenu(highlightedFileItem)
            }
        }
    }

    /// Generates the submenu.
    /// 
    /// - Parameter fileItem: The file item.
    /// 
    /// - Returns: The submenu.
    private func generateSubmenu(_ fileItem: FileSystemClient.FileItem) -> BreadcrumsMenu? {
        if let children = fileItem.children {
            let menu = BreadcrumsMenu(
                fileItems: children,
                tappedOpenFile: tappedOpenFile
            )
            return menu
        }
        return nil
    }
}

/// A menu item that represents a file item in the breadcrumbs.
final class BreadcrumbsMenuItem: NSMenuItem {
    /// The file item.
    private let fileItem: FileSystemClient.FileItem

    /// The tapped open file closure.
    private let tappedOpenFile: (FileSystemClient.FileItem) -> Void

    /// Creates a new instance of `BreadcrumbsMenuItem`.
    /// 
    /// - Parameter fileItem: The file item.
    /// - Parameter tappedOpenFile: The tapped open file closure.
    init(
        fileItem: FileSystemClient.FileItem,
        tappedOpenFile: @escaping (FileSystemClient.FileItem) -> Void
    ) {
        self.fileItem = fileItem
        self.tappedOpenFile = tappedOpenFile
        super.init(title: fileItem.fileName, action: #selector(openFile), keyEquivalent: "")

        var icon = fileItem.systemImage
        var color = fileItem.iconColor
        isEnabled = true
        target = self
        if fileItem.children != nil {
            let subMenu = NSMenu()
            submenu = subMenu
            icon = "folder.fill"
            color = .secondary
        }
        let image = NSImage(
            systemSymbolName: icon,
            accessibilityDescription: icon
        )?.withSymbolConfiguration(.init(paletteColors: [NSColor(color)]))
        self.image = image
        representedObject = fileItem
    }

    /// Creates a new instance of `BreadcrumbsMenuItem`.
    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Opens the file.
    @objc func openFile() {
        tappedOpenFile(fileItem)
    }
}
