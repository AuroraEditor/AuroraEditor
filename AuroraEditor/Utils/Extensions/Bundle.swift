//
//  Bundle.swift
//  AuroraEditorModules/AuroraEditorUtils
//
//  Created by Lukas Pistrol on 01.05.22.
//

import Foundation

public extension Bundle {

    /// Returns the main bundle's version string if available (e.g. 1.0.0)
    static var versionString: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    /// Returns the main bundle's build string if available (e.g. 123)
    static var buildString: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    /// Returns the main bundle's commitHash string if available (e.g. 7dbca499d2ae5e4a6d674c6cb498a862e930f4c3)
    static var commitHash: String? {
        guard let path = Bundle.main.url(forResource: "", withExtension: "githash"),
              let data = try? Data.init(contentsOf: path),
              let commit = String(data: data, encoding: .utf8) else {
            Log.error("Failed to get latest commit data.")
            return nil
        }

        return commit
    }
}

extension Bundle {
  static var module: Bundle { Bundle(identifier: "com.auroraeditor")! }
}
