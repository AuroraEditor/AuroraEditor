//
//  Constants.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/28.
//

// swiftlint:disable:next convenience_type
struct Constants {
    static var auroraEditorBaseURL: String = "https://api.auroraeditor.com/v1/"

    // OAuth
    static let login: String = "oauth/login"

    // Extensions
    static let extensions: String = "extensions"
    static func downloadExtension(extensionId: String) -> String {
        return "extensions/download?extensionId=\(extensionId)"
    }
}
