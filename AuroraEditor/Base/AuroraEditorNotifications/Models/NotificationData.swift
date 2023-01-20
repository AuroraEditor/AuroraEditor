//
//  NotificationData.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/12.
//

import Foundation
import SwiftUI

// TODO: DOCS
/// TODO: DOCS
public typealias NotificationMessage = String

// TODO: DOCS
/// TODO: DOCS
public protocol NotificationProperties {

    /**
     * Sticky notifications are not automatically removed after a certain timeout. By
     * default, notifications with primary actions and severity error are always sticky.
     */
    var sticky: Bool? { get }

    /**
     * Silent notifications are not shown to the user unless the notification center
     * is opened. The status bar will still indicate all number of notifications to
     * catch some attention.
     */
    var silent: Bool? { get }

    /**
     * Adds an action to never show the notification again. The choice will be persisted
     * such as future requests will not cause the notification to show again.
     */
    var neverShowAgain: INeverShowAgainOptions? { get }
}

// TODO: DOCS
/// TODO: DOCS
public enum NeverShowAgainScope {
    /// Will never show this notification on the current workspace again.
    case WORKSPACE

    /// Will never show this notification on any workspace of the same profile again.
    case PROFILE

    /// Will never show this notification on any workspace across all profiles again.
    case APPLICATION
}

// TODO: DOCS
/// TODO: DOCS
public protocol INeverShowAgainOptions {

    /**
     * The id is used to persist the selection of not showing the notification again.
     */
    var id: String { get }

    /**
     * By default the action will show up as primary action. Setting this to true will
     * make it a secondary action instead.
     */
    var isSecondary: Bool? { get }

    /**
     * Whether to persist the choice in the current workspace or for all workspaces. By
     * default it will be persisted for all workspaces across all profiles
     * (= `NeverShowAgainScope.APPLICATION`).
     */
    var scope: NeverShowAgainScope? { get }
}

public protocol INotification: NotificationProperties {

    /**
     * The id of the notification. If provided, will be used to compare
     * notifications with others to decide whether a notification is
     * duplicate or not.
     */
    var id: String? { get }

    /**
     * The message of the notification. This can either be a `string` or `Error`. Messages
     * can optionally include links in the format: `[text](link)`
     */
    var message: NotificationMessage? { get }

    /**
     * The source of the notification appears as additional information.
     */
    var source: String? { get }

    /**
     * The initial set of progress properties for the notification. To update progress
     * later on, access the `INotificationHandle.progress` property.
     */
    var progress: INotificationProgressProperties { get }
}

// TODO: DOCS
/// TODO: DOCS
public protocol INotificationProgressProperties {

    /**
     * Causes the progress bar to spin infinitley.
     */
    var infinite: Bool? { get }

    /**
     * Indicate the total amount of work.
     */
    var total: Int64? { get }

    /**
     * Indicate that a specific chunk of work is done.
     */
    var worked: Int64? { get }
}

// TODO: DOCS
/// TODO: DOCS
public protocol INotificationProgress {

    /**
     * Causes the progress bar to spin infinitley.
     */
    func infinite()

    /**
     * Indicate the total amount of work.
     */
    func total(value: Int64)

    /**
     * Indicate that a specific chunk of work is done.
     */
    func worked(value: Int64)

    /**
     * Indicate that the long running operation is done.
     */
    func done()
}

/// Notifications filter
public enum NotificationsFilter {
    /// No filter is enabled.
    case OFF

    /// All notifications are configured as silent. See
    /// `INotificationProperties.silent` for more info.
    case SILENT

    /// All notifications are silent except error notifications.
    case ERROR
}

public struct NotificationData: Codable {
    let title: String
    var source: String?

    let priority: Priority
    let style: Style

    var primaryTitle: String = ""
    var secondaryTitle: String = ""

    public enum Style: Codable {
        case basic
        case action
        case progress
    }

    public enum Priority: Codable {
        case warning
        case info
        case error
        case success

        var icon: some View {
            switch self {
            case .error:
                return Image(systemName: "xmark.circle.fill").font(.subheadline)
                    .foregroundColor(Color.red)
            case .info:
                return Image(systemName: "info.circle.fill").font(.subheadline)
                    .foregroundColor(Color.blue)
            case .warning:
                return Image(systemName: "exclamationmark.triangle.fill").font(.subheadline)
                    .foregroundColor(Color.yellow)
            case .success:
                return Image(systemName: "checkmark.circle.fill").font(.subheadline)
                    .foregroundColor(Color.green)
            }
        }
    }
}

extension NotificationData {
    func makeBanner(isPresented: Binding<Bool>, isRemoved: Binding<Bool>) -> some View {
        switch style {
        case .progress:
            return AnyView(
                NotificationWithProgress(data: self, isPresented: isPresented, isRemoved: isRemoved))
        case .basic:
            return AnyView(NotificationView(data: self, isPresented: isPresented, isRemoved: isRemoved))
        case .action:
            return AnyView(
                NotificationWithButton(data: self, isPresented: isPresented, isRemoved: isRemoved))
        }
    }
}
