//
//  ExtensionsManager.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 31-10-2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AEExtensionKit

/// ExtensionsManager
/// This class handles all extensions
public final class ExtensionsManager {
    /// Shared instance of `ExtensionsManager`
    public static let shared: ExtensionsManager = ExtensionsManager()

    /// Aurora Editor folder (`~/Library/com.auroraeditor/`)
    let auroraEditorFolder: URL

    /// Aurora Editor extensions folder (`~/Library/com.auroraeditor/Extensions`)
    let extensionsFolder: URL

    /// Dictionary of current loaded extensions
    var loadedExtensions: [String: ExtensionInterface] = [:]

    /// The current workspace document
    var workspace: WorkspaceDocument?

    init() {
        Log.info("[ExtensionsManager] init()")

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

        loadPlugins()
    }

    /// Set workspace document
    /// - Parameter workspace: Workspace document
    func set(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    /// Create an Aurora API Callback handler.
    /// - Parameter file: extension name
    /// - Returns: AuroraAPI
    private func auroraAPICallback(file: String) -> AuroraAPI {
        return { function, parameters in
            if let workspace = self.workspace {
                Log.info("Broadcasting \(function), \(parameters)")
                workspace.broadcaster.broadcast(
                    sender: file.replacingOccurrences(of: ".AEext", with: ""),
                    command: function,
                    parameters: parameters
                )
            } else {
                Log.warning("Failed to broadcast \(function), \(parameters)")
            }
        }
    }

    /// Load plugins
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

            for file in directory where file.hasSuffix("AEext") {
                if let builder = self.loadBundle(path: file) {
                    loadedExtensions[file] = builder.init().build(
                        withAPI: AuroraEditorAPI(extensionId: "0", workspace: workspace ?? .init())
                    )

                    loadedExtensions[file]?.respond(
                        action: "registerCallback",
                        parameters: ["callback": auroraAPICallback(file: file)]
                    )

                    Log.info("Registered \(file)")
                } else {
                    Log.warning("Failed to init() \(file)")
                    Log.fault("\(file) is compiled for a different version of AuroraEditor.")
                    auroraMessageBox(
                        type: .critical,
                        message: "\(file) is compiled for a different version of AuroraEditor.\n" +
                                "Please unload this plugin, or update it"
                    )
                }
            }
        } catch {
            Log.fault("Error while loading plugins \(error.localizedDescription)")
            return
        }
    }

    /// Load the bundle at path
    /// - Parameter path: path
    /// - Returns: ExtensionBuilder.Tyoe
    private func loadBundle(path: String, isResigned: Bool = false) -> ExtensionBuilder.Type? {
        let bundleURL = extensionsFolder.appendingPathComponent(path, isDirectory: true)

        // Initialize bundle
        guard let bundle = Bundle(url: bundleURL) else {
            Log.warning("Failed to load extension \(path)")
            return nil
        }

        // Pre-flight
        do {
            try bundle.preflight()
        } catch {
            Log.fault("Preflight \(path), \(error)")
            return nil
        }

        // Check if bundle can be loaded.
        if !bundle.load() {
            Log.warning("We were unable to load extension \(path).")

            if !isResigned {
                Log.info("Trying to resign.")
                let task = resign(bundle: bundleURL)

                if task?.terminationStatus != 0 {
                    Log.info("Resigning failed.")
                } else {
                    Log.info("Resigning succeed, reloading")
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

            Log.warning("\(warning)")

            return nil
        }

        return AEext
    }

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
        if let outputString = String(data: data, encoding: .utf8) {
            Log.info("Resign \(outputString)")
        }
        #endif

        return task
    }

    /// Is installed
    /// - Parameter plugin: Plugin
    /// - Returns: Is installed?
    public func isInstalled(plugin: Plugin) -> Bool? {
        return false
    }
}
