//
//  UpdateEditorRepository.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import ZIPFoundation
import AppKit

class UpdateEditorRepository: NSObject, URLSessionDownloadDelegate {

    private var fileManager: FileManager
    private var tempDirectory: URL
    private let requiredStorageSize: Int64

    private var downloadTask: URLSessionDownloadTask?
    private var backgroundCompletionHandler: (() -> Void)?

    private var progressHandler: ((Double, String?) -> Void)?

    private let model: UpdateObservedModel = .shared
    public var updateFileUrl: String? = ""

    private var downloadStartTime: TimeInterval = 0

    override init() {
        self.fileManager = FileManager.default
        self.tempDirectory = fileManager.temporaryDirectory
        self.requiredStorageSize = 100 * 1024 * 1024 // 100 MB

        super.init()
    }

    /**
     Initiates the download of an update file with progress reporting.

     This method starts the download of an update file from a specified URL and provides progress
     updates through the `progressHandler` closure.

     - Parameters:
       - progressHandler: A closure that takes a `Double` parameter representing the download progress as 
                          a percentage. This closure is called periodically to report progress updates.

     - Note:
       This method sets the `progressHandler`, generates a download URL using `generateDownloadURL()`, 
       configures a background URLSession, creates a download task, and resumes the download task.
    **/
    public func downloadUpdateFile(downloadURL: String, progressHandler: @escaping (Double, String?) -> Void) {
        self.progressHandler = progressHandler

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        if let url = URL(string: downloadURL) {
            Log.debug("\(downloadURL)")
            downloadTask = session.downloadTask(with: url)
            downloadTask?.resume()

            downloadStartTime = Date().timeIntervalSince1970
        } else {
            UpdateObservedModel().updateState = .error
        }
    }

    /**
     Handles the completion of a download task and manages the downloaded file.

     This method is called when the download task has finished downloading the file to a temporary location.
     It checks if there is sufficient disk space available, moves the downloaded file to the 
     desired location, and logs the outcome.

     - Parameters:
       - session: The URLSession that initiated the download task.
       - downloadTask: The URLSessionDownloadTask that completed.
       - location: The local URL where the downloaded file is temporarily stored.

     - Note:
       This method checks if a suggested filename is provided by the server, moves the downloaded 
       file to a specified location, updates the `updateState` property of
       `WorkspaceManager.shared.updateEditorModel` based on the outcome,
       and logs any errors that occur during the process.
     **/
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        let tempDirectory = self.tempDirectory
        let appName = "AuroaEditor-\(UUID().uuidString)"
        let savedFile = "\(appName).zip"
        let tempLocalURL = tempDirectory.appendingPathComponent(savedFile)

        // Check for available disk space
        guard isDiskSpaceAvailable(forFileOfSize: requiredStorageSize) else {
            return
        }

        do {
            // Move the downloaded file to the temporary location
            try FileManager.default.moveItem(at: location, to: tempLocalURL)

            // Unzip the downloaded file
            let destinationURL = tempDirectory.appendingPathComponent(appName)
            try FileManager.default.unzipItem(at: tempLocalURL, to: destinationURL)

            self.updateFileUrl = destinationURL.path

            // Construct the final file path
            if let firstContent = try FileManager.default.contentsOfDirectory(atPath: destinationURL.path).first {
                let finalFilePath = destinationURL.appendingPathComponent(firstContent)

                // Calculate SHA-256 checksum and verify
                if let checksum = calculateSHA256Checksum(forFileAtPath: finalFilePath.path) {
                    DispatchQueue.main.async {
                        if checksum == self.model.updateModelJson?.sha256sum {
                            self.model.updateState = .updateReady
                        } else {
                            // If for whatever reason possible the checksum is invalid
                            // we will notify the user in the update page they will be allowed
                            // to install the update but at their own risk.
                            self.model.updateState = .checksumInvalid
                        }
                    }
                } else {
                    model.updateState = .checksumInvalid
                }
            } else {
                model.updateState = .error
            }
        } catch {
            model.updateState = .error
        }
    }

    /**
     Handles the progress of a download task by calculating and reporting the download progress as a percentage.

     This method is called as data is being downloaded, and it calculates the download progress based 
     on the number of bytes written and the total expected bytes to be written.

     - Parameters:
       - session: The URLSession that initiated the download task.
       - downloadTask: The URLSessionDownloadTask for which progress is being reported.
       - bytesWritten: The number of bytes written in the most recent data write operation.
       - totalBytesWritten: The total number of bytes written so far.
       - totalBytesExpectedToWrite: The total number of bytes expected to be written for the entire download.

     - Note:
       This method ensures that `totalBytesExpectedToWrite` is non-zero to avoid division by zero, 
       calculates the download progress as a percentage, clamps the progress value within the valid range [0, 1],
       and calls the `progressHandler` with the clamped progress value.
     **/
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {

        let fixedWrittenSize = (Double(model.updateModelJson!.size) ?? -1)

        // Calculate and report the download progress as a percentage
        let progress = Double(totalBytesWritten) / fixedWrittenSize

        // Ensure that progress is within the valid range [0, 1]
        let clampedProgress = min(max(progress, 0.0), 1.0)

        // Calculate estimated time to completion (ETC) in seconds
        if fixedWrittenSize > 0 {
            let bytesRemaining = Int64(fixedWrittenSize) - totalBytesWritten

            // Calculate an average download speed
            let currentTime = Date().timeIntervalSince1970
            let timeElapsed = currentTime - downloadStartTime
            let downloadSpeed = Double(totalBytesWritten) / timeElapsed / 1024.0  // Speed in KB/s

            if downloadSpeed > 0 {
                let etaInSeconds = Double(bytesRemaining) / downloadSpeed

                let etaString = formatETA(bytesDownloaded: totalBytesWritten,
                                          totalBytes: Int64(fixedWrittenSize),
                                          seconds: Int(etaInSeconds))

                // Call the progressHandler with the clamped progress value and ETC
                progressHandler?(clampedProgress, etaString)
            } else {
                // If download speed is zero (initial stage), report progress without ETA
                progressHandler?(clampedProgress, nil)
            }
        } else {
            // If totalBytesExpectedToWrite is not available, only report progress
            progressHandler?(clampedProgress, nil)
        }
    }

    // Function to format ETA as "X bytes of Y bytes downloaded -
    // About Z hours remaining" or "X bytes of Y bytes downloaded - About Z minutes remaining"
    func formatETA(bytesDownloaded: Int64, totalBytes: Int64, seconds: Int) -> String {
        let bytesString = "\(bytesDownloaded.fileSizeString) of \(totalBytes.fileSizeString) downloaded"

        if seconds < 60 {
            return "\(bytesString) - About 1 minute remaining"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(bytesString) - About \(minutes) minutes remaining"
        } else {
            let hours = seconds / 3600
            return "\(bytesString) - About \(hours) hours remaining"
        }
    }

    /**
     Handles the completion of a URLSessionTask.

     This method is called when a URLSessionTask has completed, either successfully or with an error.

     - Parameters:
       - session: The URLSession that initiated the task.
       - task: The URLSessionTask that completed.
       - error: An optional `Error` object indicating any error that occurred during the task's execution.
                If the task completed successfully, this will be `nil`.

     - Note:
       This method logs error information and updates the `updateState` property of the 
       `WorkspaceManager.shared.updateEditorModel` based on the type or domain of the error.
     **/
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        if let error = error {
            Log.debug("Download failed with error: \(error.localizedDescription)")

            // Handle the error based on its type or domain
            if let urlError = error as? URLError {
                switch urlError.code {
                case .cancelled:
                    model.updateState = .cancelled
                case .timedOut:
                    model.updateState = .timedOut
                case .networkConnectionLost:
                    model.updateState = .networkConnectionLost
                case .cannotFindHost:
                    model.updateState = .cannotFindHost
                case .cannotConnectToHost:
                    model.updateState = .cannotConnectToHost
                default:
                    model.updateState = .error
                }
            } else {
                UpdateObservedModel().updateState = .error
            }
        }

        backgroundCompletionHandler?()
    }

    // MARK: - Background Handling
    public func setBackgroundCompletionHandler(completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }

    // MARK: - Util Handling

    /**
     Checks if there is sufficient disk space available to store a file of a specified size.

     - Parameters:
       - fileSize: The size of the file to be stored, in bytes.

     - Returns:
       `true` if there is enough free disk space to accommodate the file, otherwise `false`.

     - Note:
       This method retrieves the system's free disk space for the temporary directory and compares 
       it with the specified file size to determine if there is sufficient space.
     **/
    private func isDiskSpaceAvailable(forFileOfSize fileSize: Int64) -> Bool {
        do {
            let attributes = try self.fileManager.attributesOfFileSystem(forPath: tempDirectory.path)
            if let freeSize = attributes[FileAttributeKey.systemFreeSize] as? Int64 {
                return freeSize >= fileSize
            }
        } catch {
            model.updateState = .notEnoughStorage
        }
        return false
    }

    func unzipFile(zipFilePath: String, to destinationDirectory: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        task.arguments = ["-o", zipFilePath, "-d", destinationDirectory]

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            model.updateState = .unzipError
        }
    }

    public func calculateSHA256Checksum(forFileAtPath filePath: String) -> String? {
        let process = Process()
        process.launchPath = "/usr/bin/shasum"
        process.arguments = ["-a", "256", filePath]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let checksum = String(data: data, encoding: .utf8)?.components(separatedBy: " ").first {
                    return checksum
                }
            }
        } catch {
            // Handle any potential errors here
            Log.debug("Error: \(error)")
        }

        return nil
    }

}
