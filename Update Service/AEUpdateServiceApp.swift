//
//  Aurora Editor UpdaterApp.swift
//  Aurora Editor Updater
//
//  Created by Nanashi Li on 2023/10/03.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The Aurora Editor updater main app
@main
struct AEUpdateServiceApp: App {
    /// The app delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    /// The view body
    var body: some Scene {
        WindowGroup {}
    }
}
