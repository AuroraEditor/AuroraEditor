//
//  Main.swift
//  Aurora Editor Updater
//
//  Created by Nanashi Li on 2023/10/04.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Sentry

/// The Aurora Editor updater main app
@main
struct Main: App {
    /// Initializes the app
    init() {
        SentrySDK.start { options in
            options.dsn = ProcessInfo.processInfo.environment["SentryURL"]
            options.debug = true
            options.enabled = true
            options.enableCrashHandler = true
            options.enableMetricKit = true
            options.enableTimeToFullDisplayTracing = true
            options.swiftAsyncStacktraces = true
            options.tracesSampleRate = 1.0
        }
    }

    /// The view body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Hide close, minimize, and maximize buttons
                    if let window = NSApplication.shared.windows.first {
                        window.standardWindowButton(.closeButton)?.isHidden = true
                        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                        window.standardWindowButton(.zoomButton)?.isHidden = true
                        window.isMovableByWindowBackground = false
                        window.canHide = false

                        window.maxSize = NSSize(width: 350, height: 400)
                    }
                }
        }
//        .commandsRemoved()
//        .defaultPosition(.center)
        .windowStyle(.hiddenTitleBar)
    }
}
