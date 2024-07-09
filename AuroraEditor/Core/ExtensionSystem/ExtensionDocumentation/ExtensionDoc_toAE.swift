//
//  ExtensionDoc_toAE.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 09/07/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI
import AEExtensionKit

/// This class does not execute any code, this is made to generate documentation for the extension system
/// This are items which an extension can expect from AuroraEditor.
public protocol ExtensionDocumentationToAuroraEditor {

    /// Open settings
    func openSettings()

    /// Show a notification
    ///
    /// - Parameter title: Notification title
    /// - Parameter message: Notification message
    func showNotification(title: String, message: String)

    /// Show a warning notification
    ///
    /// - Parameter title: Notification title
    /// - Parameter message: Notification message
    func showWarning(title: String, message: String)

    /// Show a error notification
    ///
    /// - Parameter title: Notification title
    /// - Parameter message: Notification message
    func showError(title: String, message: String)

    /// Open a sheet view
    ///
    /// - Parameter view: View to show (can be SwiftUI, JSON, HTML)
    ///
    /// - Note: JSON Views do not yet return on interactions (e.g. button is clicked)
    func openSheet(view: any View)

    /// Open a tab view
    ///
    /// - Parameter view: View to show (can be SwiftUI, JSON, HTML)
    ///
    /// - Note: JSON Views do not yet return on interactions (e.g. button is clicked)
    func openTab(view: any View)

    /// Open a window
    ///
    /// - Parameter view: View to show (can be SwiftUI, JSON, HTML)
    ///
    /// - Note: JSON Views do not yet return on interactions (e.g. button is clicked)
    func openWindow(view: any View)
}
