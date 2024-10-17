//
//  NotificationViewAnimator.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit
import Combine
import SwiftUI
import OSLog

/// A class that manages the animation of a notification view sliding into and out of view.
@MainActor
class NotificationViewAnimator {
    /// The view representing the notification to be displayed.
    private var notificationView: NSView

    /// The parent view where the notification view will be displayed.
    private let parent: NSView

    /// The shared instance of the `NotificationsModel`.
    private var model: NotificationsModel = .shared

    /// A collection of cancellables used to manage Combine subscriptions.
    private var cancelables: Set<AnyCancellable> = []

    /// A task for scheduling actions with a delay.
    private var timerTask: DispatchWorkItem?

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Notification view animator")

    /// Initializes a new `NotificationViewManager` instance.
    ///
    /// - Parameters:
    ///   - notificationView: The view representing the notification to be displayed.
    ///   - parent: The parent view where the notification view will be displayed.
    ///   - model: The `NotificationsModel` used for managing notifications.
    init(notificationView: NSView, parent: NSView, model: NotificationsModel) {
        self.notificationView = notificationView
        self.parent = parent
        self.model = model
    }

    /// Animates the notification view sliding into view with a fade-in effect.
    func slideInNotificationView() {
        // Set the initial state of the notification view.
        notificationView.alphaValue = 0.0
        notificationView.frame.origin.x = parent.frame.width + 20

        // Run an animation to slide in the notification view.
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            notificationView.animator().alphaValue = 1.0
            notificationView.animator().frame.origin.x = parent.frame.width - notificationView.frame.width - 20
        }
    }

    /// Animates the notification view sliding out of view with a fade-out effect and hides it.
    func slideOutNotificationView() {
        // Run an animation to slide out the notification view and fade it out.
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            notificationView.animator().alphaValue = 0.0
            notificationView.animator().frame.origin.x = parent.frame.width + 20
        }

        // After the animation completes, hide the notification view and update the model.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.notificationView.isHidden = true
            self.model.showNotificationToast = false
        }
    }

    /// Observes changes in the `notificationToastData` property of the `model` and updates the user interface
    /// to display a notification toast when new notification data is available.
    func observeNotificationData() {
        // Use the `sink` operator to listen for changes in the `notificationToastData` property of the `model`.
        model.$notificationToastData.sink { [weak self] data in
            // Ensure self is still valid to prevent strong reference cycles.
            guard let self = self else { return }

            // Create an NSHostingView with the NotificationToastView using the new notification data.
            let newNotificationView = NSHostingView(rootView: NotificationToastView(notification: data))
            newNotificationView.translatesAutoresizingMaskIntoConstraints = false

            // Remove the existing notification view and its constraints.
            self.notificationView.removeFromSuperview()
            self.notificationView.removeConstraints(self.notificationView.constraints)

            // Add the newNotificationView to the parent view.
            self.parent.addSubview(newNotificationView)

            // Apply constraints to position the newNotificationView correctly within the parent view.
            NSLayoutConstraint.activate([
                newNotificationView.widthAnchor.constraint(equalToConstant: 344),
                newNotificationView.heightAnchor.constraint(equalToConstant: 104),
                newNotificationView.bottomAnchor.constraint(equalTo: self.parent.bottomAnchor, constant: -20),
                newNotificationView.trailingAnchor.constraint(equalTo: self.parent.trailingAnchor, constant: -20)
            ])

            // Assign the new view to the notificationView property.
            self.notificationView = newNotificationView

            // Initially hide the notification view.
            self.notificationView.isHidden = true

            // Slide in the notification view to make it visible to the user.
            self.slideInNotificationView()
        }
        // Store the subscription in the `cancelables` collection to manage its lifecycle.
        .store(in: &cancelables)
    }

    /// Observes the `showNotificationToast` property of the `model`
    /// and handles showing the notification view.
    ///
    /// This function listens for changes in the `showNotificationToast` property and displays
    /// the notification view when `showToast` is `true`. It also starts a timer to hide the notification
    /// view after 5 seconds if the user is not hovering over it.
    ///
    /// - Note: The `cancelTimer` function is called to ensure any existing timer is canceled before starting a new one.
    func observeShowNotification() {
        model.$showNotificationToast.sink { [weak self] showToast in
            guard let self = self else { return }

            logger.debug("The current view should show: \(showToast)")

            if showToast {
                self.notificationView.isHidden = false
                self.slideInNotificationView()
                self.cancelTimer()
                self.startTimer()
            }
        }.store(in: &cancelables)
    }

    /// Starts a timer to hide the notification view after 5 seconds if the user is not hovering over it.
    ///
    /// This function schedules a timer to hide the notification view after 5 seconds if the user is not
    /// actively hovering over it. The timer task checks the `hoveringOnToast` property and, if not
    /// hovering and the notification view is not hidden, slides out the notification view.
    ///
    /// - Note: Any existing timer is canceled before starting a new one to prevent timer conflicts.
    internal func startTimer() {
        cancelTimer()

        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            self.model.$hoveringOnToast.sink { isHovering in
                if !isHovering && !self.notificationView.isHidden {
                    self.slideOutNotificationView()
                }
            }.store(in: &self.cancelables)
        }

        timerTask = task

        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }

    /// Cancels the currently active timer, if one exists.
    ///
    /// This function checks if there's an existing timer task (`timerTask`) and cancels it if it's still pending.
    /// It ensures that the timer is cleared, preventing conflicts between multiple timer instances.
    internal func cancelTimer() {
        if let task = timerTask {
            if !task.isCancelled {
                task.cancel()
            }
            timerTask = nil
        }
    }
}
