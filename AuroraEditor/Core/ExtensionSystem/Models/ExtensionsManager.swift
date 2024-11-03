//
//  ExtensionsManager.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 31-10-2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AEExtensionKit
import OSLog

/// ExtensionsManager
/// This class handles all extensions
@MainActor
public final class ExtensionsManager {
    /// Shared instance of `ExtensionsManager`
    public static let shared: ExtensionsManager = ExtensionsManager()

    /// Aurora Editor folder (`~/Library/com.auroraeditor/`)
    private let auroraEditorFolder: URL

    /// Aurora Editor extensions folder (`~/Library/com.auroraeditor/Extensions`)
    public let extensionsFolder: URL

    /// Dictionary of current loaded extensions
    private(set) var loadedExtensions: [String: ExtensionInterface] = [:]

    /// The current workspace document
    private var workspace: WorkspaceDocument?

    /// Extensions logger
    private let logger = Logger(subsystem: "com.auroraeditor.extensions", category: "Extensions Manager")

    /// Initialize ExtensionsManager
    init() {
        logger.info("[ExtensionsManager] init()")

        guard let extensionsPath = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            fatalError("Cannot load extensions directory")
        }

        self.auroraEditorFolder = extensionsPath.appendingPathComponent(
            "com.auroraeditor",
            isDirectory: true
        )

        self.extensionsFolder = auroraEditorFolder.appendingPathComponent(
            "Extensions",
            isDirectory: true
        )
    }

    /// Set workspace document
    ///
    /// - Parameter workspace: Workspace document
    func set(workspace: WorkspaceDocument) {
        self.workspace = workspace
        loadPlugins()
    }

    /// Create an Aurora API Callback handler.
    ///
    /// - Parameter file: extension name
    ///
    /// - Returns: AuroraAPI
    private func auroraAPICallback(file: String) -> AuroraAPI {
        return { function, parameters in
            if let workspace = self.workspace {
                self.logger.info("Broadcasting \(function), \(parameters)")
                workspace.broadcaster.broadcast(
                    sender: file.replacingOccurrences(of: ".AEext", with: ""),
                    command: function,
                    parameters: parameters
                )
            } else {
                self.logger.warning("Failed to broadcast \(function), \(parameters)")
            }
        }
    }

    /// Load plugins
    ///
    /// all extensions in `~/Library/com.auroraeditor/Extensions` will be loaded.
    public func loadPlugins() {
        loadedExtensions = [:]

        try? FileManager.default.createDirectory(
            at: extensionsFolder,
            withIntermediateDirectories: false,
            attributes: nil
        )

        do {
            let directory = try FileManager.default.contentsOfDirectory(
                atPath: extensionsFolder.relativePath
            )

            for file in directory {
                if file.hasSuffix("JSext") {
                    loadJSExtension(at: file)
                }

                if file.hasSuffix("AEext") {
                    if let builder = self.loadBundle(path: file) {
                        loadedExtensions[file] = builder.init().build(
                            withAPI: AuroraEditorAPI(extensionId: "0", workspace: workspace ?? .init())
                        )

                        loadedExtensions[file]?.respond(
                            action: "registerCallback",
                            parameters: ["callback": auroraAPICallback(file: file)]
                        )

                        logger.info("Registered \(file)")
                    } else {
                        logger.warning("Failed to init() \(file)")
                        logger.fault("\(file) is compiled for a different version of AuroraEditor.")
                        Task { @MainActor in
                            auroraMessageBox(
                                type: .critical,
                                message: "\(file) is compiled for a different version of AuroraEditor.\n" +
                                "Please unload this plugin, or update it"
                            )
                        }
                    }
                }
            }
        } catch {
            logger.fault("Error while loading plugins \(error.localizedDescription)")
            return
        }
    }

    /// Can build editor
    ///
    /// Is an extension able to build an editor for the provided file?
    ///
    /// - Parameter item: file item
    /// - Returns: editor code, or null.
    public func canBuildEditor(for item: FileSystemClient.FileItem) -> Any? {
        let canOpenEvent = self.sendEvent(
            event: "canOpen",
            parameters: ["file": item.url.relativeString]
        )

        if canOpenEvent.compactMap({ $0 as? Bool }).contains(true) {
            if let editorBuilder = self.sendEvent(
                event: "buildEditor",
                parameters: ["file": item.url.relativeString]
            ).compactMap({ $0 as? [String: Any] }).first {
               return editorBuilder["view"] ?? nil
            }
        }

        return nil
    }

    /// Load JS Extension
    ///
    /// - Parameter directory: Directory
    private func loadJSExtension(at directory: String) {
        let extensionName = directory.replacingOccurrences(of: ".JSext", with: "")

        if let extensionInterface = JSSupport(
            name: extensionName,
            path: self.extensionsFolder.relativePath + "/" + directory + "/extension.js",
            workspace: workspace
        ) {
            logger.info("Registered extension \(extensionName)")
            loadedExtensions[directory] = extensionInterface
        } else {
            logger.fault("Failed to load \(extensionName)")
            Task { @MainActor in
                auroraMessageBox(
                    type: .critical,
                    message: "Failed to load \(extensionName)"
                )
            }
        }
    }

    /// Load the bundle at path
    ///
    /// - Parameter path: path
    ///
    /// - Returns: ExtensionBuilder.Tyoe
    private func loadBundle(path: String, isResigned: Bool = false) -> ExtensionBuilder.Type? {
        let bundleURL = extensionsFolder.appendingPathComponent(path, isDirectory: true)

        // Initialize bundle
        guard let bundle = Bundle(url: bundleURL) else {
            logger.warning("Failed to load extension \(path)")
            return nil
        }

        // Pre-flight
        do {
            try bundle.preflight()
        } catch {
            logger.fault("Preflight \(path), \(error)")
            return nil
        }

        // Check if bundle can be loaded.
        if !bundle.load() {
            logger.warning("We were unable to load extension \(path).")

            if !isResigned {
                logger.info("Trying to resign.")
                let task = resign(bundle: bundleURL)

                if task?.terminationStatus != 0 {
                    logger.info("Resigning failed.")
                } else {
                    logger.info("Resigning succeed, reloading")
                    return loadBundle(path: path, isResigned: true)
                }
            }

            return nil
        }

        // Can we convert the principalClass to an ExtensionBuilder.Type?
        // If not than this is probably not an Aurora Editor extension.
        guard let AEext = bundle.principalClass as? ExtensionBuilder.Type else {
            let warning = "\(path), Failed to convert \(String(describing: bundle.principalClass.self))" +
            "to \(ExtensionBuilder.Type.self) Is the principal class correct?"

            logger.warning("\(warning)")

            return nil
        }

        return AEext
    }

    /// Resign the bundle
    ///
    /// - Parameter bundle: Bundle
    ///
    /// - Returns: Process
    private func resign(bundle: URL) -> Process? {
        if !FileManager().fileExists(atPath: "/usr/bin/xcrun") {
            return nil
        }

        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["codesign", "--sign", "-", bundle.path]
        task.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        task.launch()
        task.waitUntilExit()

#if DEBUG
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        logger.info("Resign \(String(describing: String(data: data, encoding: .utf8)))")
#endif

        return task
    }

    /// Send event to all loaded extensions
    ///
    /// - Parameter event: Event to send
    /// - Parameter parameters: Parameters to send
    @discardableResult
    public func sendEvent(event: String, parameters: [String: Any]) -> [Any] {
        var reactions: [Any] = []

        let params = Array(parameters.keys).joined(separator: ": ..., ")

        self.logger.info(
            "Send \(event)(\(params)) to \(ExtensionsManager.shared.loadedExtensions.count) extensions."
        )

        // Let the extensions know we opened a file (from a workspace)
        for (_, AEExt) in ExtensionsManager.shared.loadedExtensions {
            reactions.append(
                AEExt.respond(action: event, parameters: parameters)
            )
        }

        return reactions
    }

    /// Is installed
    ///
    /// - Parameter plugin: Plugin
    ///
    /// - Returns: Is installed?
    public func isInstalled(plugin: Plugin) -> Bool? {
        return false
    }
}
