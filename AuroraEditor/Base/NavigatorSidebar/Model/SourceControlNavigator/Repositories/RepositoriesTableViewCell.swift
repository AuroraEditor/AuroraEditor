//
//  RepositoriesTableViewController.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 17/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

/// A `NSTableCellView` showing an ``icon`` and a ``label``
final class RepositoriesTableViewCell: StandardTableViewCell {
    init(frame frameRect: NSRect,
         repository: DummyRepo,
         represents cellType: CellType = .repo,
         branchNumber: Int? = nil
    ) {
        super.init(frame: frameRect)

        // Add text and image
        var image = NSImage()
        switch cellType {
        case .repo:
            label.stringValue = "\(repository.repoName) (\(repository.branches[repository.current].name))"
            if repository.isLocal {
                image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)!
            } else {
                image = NSImage(systemSymbolName: "vault", accessibilityDescription: nil)!
            }

        case .branches:
            label.stringValue = "Branches"
            image = NSImage(systemSymbolName: "arrow.triangle.branch", accessibilityDescription: nil)!

        case .branch:
            label.stringValue = repository.branches[branchNumber ?? -1].name
            if repository.current == branchNumber ?? -1 {
                secondaryLabel.stringValue = "*"
            }
            secondaryLabelIsSmall = secondaryLabel.stringValue.isEmpty
            image = NSImage(systemSymbolName: "arrow.triangle.branch", accessibilityDescription: nil)!

        case .recentLocations:
            label.stringValue = "Recent Locations"
            image = NSImage(systemSymbolName: "arrow.triangle.branch", accessibilityDescription: nil)!

        case .tags:
            label.stringValue = "Tags"
            image = NSImage(systemSymbolName: "tag", accessibilityDescription: nil)!

        case .stashedChanges:
            label.stringValue = "Stashed Changes"
            image = NSImage(systemSymbolName: "tray", accessibilityDescription: nil)!

        case .remotes:
            label.stringValue = "Remotes"
            image = NSImage(named: "vault")!
        }
        icon.image = image
        icon.contentTintColor = .gray
    }

    enum CellType {
        case repo
        case branches
        case branch
        case recentLocations
        case tags
        case stashedChanges
        case remotes
    }

    required init?(coder: NSCoder) {
        fatalError("""
            init?(coder: NSCoder) isn't implemented on `RepositoriesTableViewCell`.
            Please use `.init(frame: NSRect)
            """)
    }
}
