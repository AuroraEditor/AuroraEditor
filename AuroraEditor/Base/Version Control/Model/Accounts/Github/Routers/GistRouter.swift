//
//  GistRouter.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Gist Router
enum GistRouter: JSONPostRouter {

    /// Read Authenticated Gists
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    case readAuthenticatedGists(GitConfiguration, String, String)

    /// Read Gists
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    case readGists(GitConfiguration, String, String, String)

    /// Read Gist
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter id: Identifier
    case readGist(GitConfiguration, String)

    /// Post Gist File
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter description: Description
    /// - Parameter filename: Filename
    /// - Parameter fileContent: File Content
    /// - Parameter publicAccess: Public Access
    case postGistFile(GitConfiguration, String, String, String, Bool)

    /// Patch Gist File
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter id: Identifier
    /// - Parameter description: Description
    /// - Parameter filename: Filename
    /// - Parameter fileContent: File Content
    case patchGistFile(GitConfiguration, String, String, String, String)

    /// HTTP Method
    var method: HTTPMethod {
        switch self {
        case .postGistFile, .patchGistFile:
            return .POST
        default:
            return .GET
        }
    }

    /// HTTP Encoding
    var encoding: HTTPEncoding {
        switch self {
        case .postGistFile, .patchGistFile:
            return .json
        default:
            return .url
        }
    }

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case let .readAuthenticatedGists(config, _, _): return config
        case let .readGists(config, _, _, _): return config
        case let .readGist(config, _): return config
        case let .postGistFile(config, _, _, _, _): return config
        case let .patchGistFile(config, _, _, _, _): return config
        }
    }

    /// Parameters
    var params: [String: Any] {
        switch self {
        case let .readAuthenticatedGists(_, page, perPage):
            return ["per_page": perPage, "page": page]
        case let .readGists(_, _, page, perPage):
            return ["per_page": perPage, "page": page]
        case .readGist:
            return [:]
        case let .postGistFile(_, description, filename, fileContent, publicAccess):
            var params = [String: Any]()
            params["public"] = publicAccess
            params["description"] = description
            var file = [String: Any]()
            file["content"] = fileContent
            var files = [String: Any]()
            files[filename] = file
            params["files"] = files
            return params
        case let .patchGistFile(_, _, description, filename, fileContent):
            var params = [String: Any]()
            params["description"] = description
            var file = [String: Any]()
            file["content"] = fileContent
            var files = [String: Any]()
            files[filename] = file
            params["files"] = files
            return params
        }
    }

    /// Path
    var path: String {
        switch self {
        case .readAuthenticatedGists:
            return "gists"
        case let .readGists(_, owner, _, _):
            return "users/\(owner)/gists"
        case let .readGist(_, id):
            return "gists/\(id)"
        case .postGistFile:
            return "gists"
        case let .patchGistFile(_, id, _, _, _):
            return "gists/\(id)"
        }
    }
}
