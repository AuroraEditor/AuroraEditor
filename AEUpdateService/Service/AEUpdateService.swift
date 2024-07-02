//
//  Aurora Editor Updater.swift
//  Aurora Editor Updater
//
//  Created by Nanashi Li on 2023/10/03.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Sentry

/// The Aurora Editor update service
class AEUpdateService: NSObject {
    /// install the Aurora Editor update
    /// 
    /// - Parameter updateFile: The update file
    func installAuroraEditorUpdate(updateFile: String) {
        do {
            // Mount the disk image
            let mountProcess = Process()
            mountProcess.launchPath = "/usr/bin/hdiutil"
            mountProcess.arguments = ["attach", updateFile]
            mountProcess.launch()
            mountProcess.waitUntilExit()

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

            guard let volumes = listVolumes(),
                  let volume = findAuroraEditorVolume(volumes),
                  let url = URL(string: "auroraeditor://") else {
                    throw NSError(domain: "com.auroraeditor.update", code: 1)
                  }
            // Unmount the disk image
            let unmountProcess = Process()
            unmountProcess.launchPath = "/usr/bin/hdiutil"
            unmountProcess.arguments = ["detach", volume]
            unmountProcess.launch()
            unmountProcess.waitUntilExit()

            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                NSWorkspace.shared.open(url)
                exit(0)
            }
        } catch {
            SentrySDK.capture(message: "Error during update installation: \(error)")
        }
    }

    /// Function to list volumes using diskutil
    /// 
    /// - Returns: The output of the diskutil command
    func listVolumes() -> String? {
        let listProcess = Process()
        listProcess.launchPath = "/usr/sbin/diskutil"
        listProcess.arguments = ["list"]

        let pipe = Pipe()
        listProcess.standardOutput = pipe
        listProcess.standardError = pipe

        listProcess.launch()
        listProcess.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }

    /// Function to parse the list of volumes and identify the Aurora Editor volume
    ///
    /// - Parameter diskutilOutput: The output of the diskutil command
    /// - Returns: The disk image path for the Aurora Editor volume
    func findAuroraEditorVolume(_ diskutilOutput: String) -> String? {
        // Split the output by newlines to process each line separately
        let lines = diskutilOutput.split(separator: "\n")

        // Variable to store the volume disk image
        var auroraEditorDiskImage: String?

        // Flag to indicate if we are currently looking at information about the Aurora Editor volume
        var isAuroraEditorVolume = false

        for line in lines {
            // Check if the line contains the volume name or any other identifying information for Aurora Editor
            if line.contains("Aurora Editor") {
                isAuroraEditorVolume = true
            } else if isAuroraEditorVolume && line.hasPrefix("/dev/") {
                // Assuming that the line with "/dev/" prefix contains the disk image path
                auroraEditorDiskImage = String(line)
                break // We found what we needed, so we can exit the loop
            } else if isAuroraEditorVolume && line.isEmpty {
                // If we encounter an empty line after identifying the Aurora Editor volume, stop looking
                break
            }
        }

        return auroraEditorDiskImage
    }
}
