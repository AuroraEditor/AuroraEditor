//
//  ExtensionsManager.swift
//  AuroraEditorModules/ExtensionStore
//
//  Created by Pavel Kasila on 7.04.22.
//

import Foundation
import AEExtensionKit

/// Class which handles all extensions (its bundles, instances for each workspace and so on)
public final class ExtensionsManager {
    /// Shared instance of `ExtensionsManager`
    public static let shared: ExtensionsManager = ExtensionsManager()

    let auroraEditorFolder: URL
    let extensionsFolder: URL

    var loadedBundles: [UUID: Bundle] = [:]
    var loadedExtensions: [String: ExtensionInterface] = [:]
    var loadedLanguageServers: [String: LSPClient] = [:]

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

    /// Temporary load function, all extensions in ~/Library/com.auroraeditor/Extensions will be loaded.
    public func loadPlugins() {
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
                Log.info("Loading \(file)")
                if let builder = self.loadBundle(path: file) {
                    loadedExtensions[file] = builder.init().build(
                        withAPI: AuroraEditorAPI.init(extensionId: "0", workspace: .init())
                    )
                    Log.info("Registered \(file)")
                } else {
                    Log.warning("Failed to init() \(file)")
                }
            }
        } catch {
            Log.error("Error while loading plugins", error.localizedDescription)
            return
        }
    }

    /// Load the bundle at path
    /// - Parameter path: path
    /// - Returns: ExtensionBuilder.Tyoe
    private func loadBundle(path: String) -> ExtensionBuilder.Type? {
        let bundleURL = extensionsFolder.appendingPathComponent(path, isDirectory: true)

        /// Initialize bundle
        guard let bundle = Bundle(url: bundleURL),
              bundle.load() else {
            Log.warning("Failed to load bundle")
            return nil
        }

        guard let AEext = bundle.principalClass as? ExtensionBuilder.Type else {
            Log.warning(
                "Failed to convert",
                bundle.principalClass.self ?? "None",
                "to",
                ExtensionBuilder.Type.self,
                "Is the principal class correct?"
            )

            return nil
        }

        return AEext
    }

    private func loadLSPClient(file: String) {
        //                guard let client = try getLSPClient(id: plugin.release, workspaceURL: api.workspaceURL) else {
        //                    return
        //                }
        //                loadedLanguageServers[key] = client
    }

    private func getLSPClient(id: UUID, workspaceURL: URL) throws -> LSPClient? {
        //        if loadedBundles.keys.contains(id) {
        //            guard let lspFile = loadedBundles[id]?.infoDictionary?["CELSPExecutable"] as? String else {
        //                return nil
        //            }
        //
        //            guard let lspURL = loadedBundles[id]?.url(forResource: lspFile, withExtension: nil) else {
        //                return nil
        //            }
        //
        //            return try LSPClient(lspURL,
        //                                 workspace: workspaceURL,
        //                                 arguments: loadedBundles[id]?.infoDictionary?["CELSPArguments"] as? [String])
        //        }
        //
        //        guard let bundle = try loadBundle(id: id, withExtension: "celsp") else {
        //            return nil
        //        }
        //
        //        guard let lspFile = bundle.infoDictionary?["CELSPExecutable"] as? String else {
        //            return nil
        //        }
        //
        //        guard let lspURL = bundle.url(forResource: lspFile, withExtension: nil) else {
        //            return nil
        //        }
        //
        //        return try LSPClient(lspURL,
        //                             workspace: workspaceURL,
        //                             arguments: loadedBundles[id]?.infoDictionary?["CELSPArguments"] as? [String])
        return nil
    }

    public func isInstalled(plugin: Plugin) -> Bool? {
        return false
    }
}
