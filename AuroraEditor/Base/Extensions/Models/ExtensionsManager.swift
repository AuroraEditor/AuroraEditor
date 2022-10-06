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
    public static let shared: ExtensionsManager? = {
        try? ExtensionsManager()
    }()

    let auroraEditorFolder: URL
    let extensionsFolder: URL

    var loadedBundles: [UUID: Bundle] = [:]
    var loadedPlugins: [String: ExtensionInterface] = [:]
    var loadedLanguageServers: [String: LSPClient] = [:]

    init() throws {
        Log.info("Searching for Bundles")
        self.auroraEditorFolder = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("com.auroraeditor", isDirectory: true)

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

                    loadedPlugins[file] = builder.init().build(
                        withAPI: AuroraEditorAPI.init(extensionId: "0", workspace: .init())
                    )
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

        return bundle.principalClass as? ExtensionBuilder.Type
    }

    private func loadBundle(id: UUID, withExtension ext: String) throws -> Bundle? {
        guard let bundleURL = try FileManager.default.contentsOfDirectory(
            at: extensionsFolder.appendingPathComponent(id.uuidString,
                                                        isDirectory: true),
            includingPropertiesForKeys: nil,
            options: .skipsPackageDescendants
        ).first(where: { $0.pathExtension == ext }) else { return nil }

        guard let bundle = Bundle(url: bundleURL) else { return nil }

        loadedBundles[id] = bundle

        return bundle
    }

    private func getExtensionBuilder(id: UUID) throws -> ExtensionBuilder.Type? {
        if loadedBundles.keys.contains(id) {
            return loadedBundles[id]?.principalClass as? ExtensionBuilder.Type
        }

        guard let bundle = try loadBundle(id: id, withExtension: "ceext") else {
            return nil
        }

        guard bundle.load() else { return nil }

        return bundle.principalClass as? ExtensionBuilder.Type
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

    /// Loads extensions' bundles which were not loaded before and passes `ExtensionAPI` as a whole class
    /// or workspace's URL
    /// - Parameter apiBuilder: function which creates `ExtensionAPI` instance based on plugin's ID
    public func load(_ apiBuilder: (String) -> ExtensionAPI) throws {
        //        let plugins = try self.dbQueue.read { database in
        //            try DownloadedPlugin
        //                .filter(Column("loadable") == true)
        //                .fetchAll(database)
        //        }
        //
//                try plugins.forEach { plugin in
        //            let api = apiBuilder(plugin.plugin.uuidString)
        //            let key = PluginWorkspaceKey(releaseID: plugin.release, workspace: api.workspaceURL)
        //
        //            switch plugin.sdk {
        //            case .swift:
        //                guard let builder = try getExtensionBuilder(id: plugin.release) else {
        //                    return
        //                }
        //
        //                loadedPlugins[key] = builder.init().build(withAPI: api)
        //            case .languageServer:
        //                guard let client = try getLSPClient(id: plugin.release, workspaceURL: api.workspaceURL) else {
        //                    return
        //                }
        //                loadedLanguageServers[key] = client
        //            }
        //        }
    }
}
