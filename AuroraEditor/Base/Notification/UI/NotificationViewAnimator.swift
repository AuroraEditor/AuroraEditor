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

class NotificationViewAnimator {
    private var notificationView: NSView
    private let parent: NSView
    private var model: NotificationsModel = .shared
    private var cancelables: Set<AnyCancellable> = []
    private var timerTask: DispatchWorkItem?

    init(notificationView: NSView, parent: NSView, model: NotificationsModel) {
        self.notificationView = notificationView
        self.parent = parent
        self.model = model
    }

    func slideInNotificationView() {
        notificationView.alphaValue = 0.0
        notificationView.frame.origin.x = parent.frame.width + 20

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            notificationView.animator().alphaValue = 1.0
            notificationView.animator().frame.origin.x = parent.frame.width - notificationView.frame.width - 20
        }
    }

    func slideOutNotificationView() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            notificationView.animator().alphaValue = 0.0
            notificationView.animator().frame.origin.x = parent.frame.width + 20
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.notificationView.isHidden = true
            self.model.showNotificationToast = false
        }
    }

    func observeNotificationData() {
        model.$notificationToastData.sink { [weak self] data in
            guard let self = self else { return }

            // Create the NSHostingView with NotificationToastView
            let newNotificationView = NSHostingView(rootView: NotificationToastView(notification: data))
            newNotificationView.translatesAutoresizingMaskIntoConstraints = false

            self.notificationView.removeFromSuperview()
            self.notificationView.removeConstraints(self.notificationView.constraints)

            // Add the newNotificationView to the parent view
            self.parent.addSubview(newNotificationView)

            // Apply constraints to position it correctly
            NSLayoutConstraint.activate([
                newNotificationView.widthAnchor.constraint(equalToConstant: 344),
                newNotificationView.heightAnchor.constraint(equalToConstant: 104),
                newNotificationView.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -20),
                newNotificationView.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -20)
            ])

            // Assign the new view to notificationView
            self.notificationView = newNotificationView
            self.notificationView.isHidden = true

            // Slide in the notification view
            self.slideInNotificationView()
        }.store(in: &cancelables)
    }

    /**
     Observes the `showNotificationToast` property of the `model`
     and handles showing the notification view.

     This function listens for changes in the `showNotificationToast` property and displays
     the notification view when `showToast` is `true`. It also starts a timer to hide the notification
     view after 5 seconds if the user is not hovering over it.

     - Note: The `cancelTimer` function is called to ensure any existing timer is canceled before starting a new one.
     */
    func observeShowNotification() {
        model.$showNotificationToast.sink { [weak self] showToast in
            guard let self = self else { return }

            Log.debug("The current view should show: \(showToast)")

            if showToast {
                self.notificationView.isHidden = false
                self.slideInNotificationView()
                self.cancelTimer()
                self.startTimer()
            }
        }.store(in: &cancelables)
    }

    /**
     Starts a timer to hide the notification view after 5 seconds if the user is not hovering over it.

     This function schedules a timer to hide the notification view after 5 seconds if the user is not
     actively hovering over it. The timer task checks the `hoveringOnToast` property and, if not
     hovering and the notification view is not hidden, slides out the notification view.

     - Note: Any existing timer is canceled before starting a new one to prevent timer conflicts.
     */
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

    /**
     Cancels the currently active timer, if one exists.

     This function checks if there's an existing timer task (`timerTask`) and cancels it if it's still pending.
     It ensures that the timer is cleared, preventing conflicts between multiple timer instances.
     */
    internal func cancelTimer() {
        if let task = timerTask {
            if !task.isCancelled {
                task.cancel()
            }
            timerTask = nil
        }
    }
}
