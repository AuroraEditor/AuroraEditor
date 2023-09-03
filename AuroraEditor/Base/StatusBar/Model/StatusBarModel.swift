//
//  StatusBarModel.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 20.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import SwiftUI

/// # StatusBarModel
///
/// A model class to host and manage data for the ``StatusBarView``
///
public class StatusBarModel: ObservableObject {

    // TODO: Implement logic for updating values
    // TODO: Add @Published vars for indentation, encoding, linebreak

    /// The selected tab in the main section.
    /// - **0**: Terminal
    /// - **1**: Debugger
    /// - **2**: Output
    @Published
    public var selectedTab: Int = 0

    /// Returns true when the drawer is visible
    @Published
    public var isExpanded: Bool = false

    /// Returns true when the drawer is visible
    @Published
    public var isMaximized: Bool = false

    /// The current height of the drawer. Zero if hidden
    @Published
    public var currentHeight: Double = 0

    /// Indicates whether the drawer is beeing resized or not
    @Published
    public var isDragging: Bool = false

    /// Indicates whether the breakpoint is enabled or not
    @Published
    public var isBreakpointEnabled: Bool = true

    /// Search value to filter in drawer
    @Published
    public var searchText: String = ""

    /// Which format of bracket to display
    @Published
    public var bracketDisplay: BracketDisplayType = .seperated

    /// Returns the font for status bar items to use
    private(set) var toolbarFont: Font = .system(size: 11)

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    /// The maximum height of the drawer
    /// when isMaximized is true the height gets set to maxHeight
    private(set) var maxHeight: Double = 5000

    /// The default height of the drawer
    private(set) var standardHeight: Double = 300

    /// The minimum height of the drawe
    private(set) var minHeight: Double = 100

    /// Initialize with a GitClient
    /// - Parameter workspaceURL: the current workspace URL
    public init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
    }
}
