//
//  AEUpdateService.swift
//  AEUpdateService
//
//  Created by Nanashi Li on 2023/10/03.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Sentry

class AEUpdateService: NSObject {

    func installAuroraEditorUpdate(updateFile: String) {
        do {
            // Mount the disk image
            let mountProcess = Process()
            mountProcess.launchPath = "/usr/bin/hdiutil"
            mountProcess.arguments = ["attach", updateFile]
            mountProcess.launch()
            mountProcess.waitUntilExit()

            SentrySDK.capture(message: mountProcess.arguments!.joined())

            // Define paths
            let applicationsFolder = try FileManager.default.url(for: .applicationDirectory, 
                                                                 in: .localDomainMask,
                                                                 appropriateFor: nil,
                                                                 create: false)
            let sourcePath = "/Volumes/Aurora Editor/Aurora Editor.app"
            let destinationPath = applicationsFolder.appendingPathComponent("Aurora Editor.app")

            // Remove existing app if it exists
            if FileManager.default.fileExists(atPath: destinationPath.path) {
                try FileManager.default.removeItem(at: destinationPath)
            }

            // Copy files
            try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath.path)

            // Unmount the disk image
            let unmountProcess = Process()
            unmountProcess.launchPath = "/usr/bin/hdiutil"
            unmountProcess.arguments = ["detach", sourcePath]
            unmountProcess.launch()
            unmountProcess.waitUntilExit()

            SentrySDK.capture(message: "Update installed successfully.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                exit(0)
            }
        } catch {
            SentrySDK.capture(message: "Error during update installation: \(error)")
        }
    }
}
