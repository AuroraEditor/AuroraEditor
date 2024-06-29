//
//  Config.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Look up a config value by name in the repository.
///
/// - Parameter directoryURL: The directory to look up the value in.
/// - Parameter name: The name of the configuration value to look up.
/// - Parameter onlyLocal Whether or not the value to be retrieved should stick to
/// the local repository settings. It is false by default. This
/// is equivalent to using the `--local` argument in the `git config` invocation.
/// 
/// - Returns: The value of the configuration value, or nil if it does not exist.
/// 
/// - Throws: Error
func getConfigValue(directoryURL: URL,
                    name: String,
                    onlyLocal: Bool = false) throws -> String? {
    return try getConfigValueInPath(name: name,
                                    path: String(contentsOf: directoryURL),
                                    onlyLocal: onlyLocal,
                                    type: nil)
}

/// Look up a global config value by name.
/// 
/// - Parameter name: The name of the configuration value to look up.
/// 
/// - Returns: The value of the configuration value, or nil if it does not exist.
/// 
/// - Throws: Error
func getGlobalConfigVlaue(name: String) throws -> String? {
    return try getConfigValueInPath(name: name,
                                    path: nil,
                                    onlyLocal: false,
                                    type: nil)
}

/// Look up a global config value by name.
///
/// Treats the returned value as a boolean as per Git's
/// own definition of a boolean configuration value (i.e.
/// 0 -> false, "off" -> false, "yes" -> true etc)
/// 
/// - Parameter name: The name of the configuration value to look up.
/// 
/// - Returns: The value of the configuration value, or nil if it does not exist.
/// 
/// - Throws: Error
func getGlobalBooleanConfigValue(name: String) throws -> Bool? {
    let value = try getConfigValueInPath(name: name,
                                         path: nil,
                                         onlyLocal: false,
                                         type: Bool.self)
    return value == nil ? nil : (value != nil) != false
}

/// Look up a config value by name
///
/// - Parameter name: The name of the configuration value to look up.
/// - Parameter path: The path to execute the `git` command in. If null
///                   we'll use the global configuration (i.e. --global)
///                   and execute the Git call from the same location that
///                   Aurora Editor is installed in.
/// - Parameter onlyLocal: Whether or not the value to be retrieved should stick to
///                        the local repository settings (if a path is specified). It
///                        is false by default. It is equivalent to using the `--local`
///                        argument in the `git config` invocation.
/// - Parameter type: Canonicalize configuration values according to the
///                  expected type (i.e. 0 -> false, "on" -> true etc).
/// 
/// - Returns: The value of the configuration value, or nil if it does not exist.
/// 
/// - Throws: Error
func getConfigValueInPath(name: String,
                          path: String?,
                          onlyLocal: Bool = false,
                          type: Any?) throws -> String? {

    var gitCommand: String

    var flags = ["config", "-z"]

    if path == nil {
        flags.append("--global")
    } else if onlyLocal {
        flags.append("--local")
    }

    if let type = type {
        flags.append("--type \(type)")
    }

    flags.append(name)

    if let path = path {
        gitCommand = "cd \(path.escapedWhiteSpaces()); git \(flags)"
    } else {
        gitCommand = "git \(flags)"
    }

    let result = try ShellClient.live().run(gitCommand)

    let output = result
    let pieces = output.split(separator: "\0")
    return pieces[0].description
}

/// Get the path to the global git config.
/// 
/// - Returns: The path to the global git config, or nil if it does not exist.
/// 
/// - Throws: Error
func getGlobalConfig() throws -> String? {
    let result = try ShellClient.live().run(
        "git config --global --list --show-origin --name-only -z"
    )

    let segments = result.split(separator: "\0")
    if segments.count < 1 {
        return nil
    }

    let pathSegment = segments[0]
    if pathSegment.isEmpty {
        return nil
    }

    let path = pathSegment.ranges(of: "file:/")
    if path.count < 2 {
        return nil
    }

    return path[1].description
}

/// Set the local config value by name.
/// 
/// - Parameter directoryURL: The directory to set the value in.
/// - Parameter name: The name of the configuration value to set.
/// - Parameter value: The value to set the configuration value to.
/// 
/// - Throws: Error
func setConfigValue(directoryURL: URL,
                    name: String,
                    value: String) throws {
    try setConfigValueInPath(name: name,
                             value: value,
                             path: String(contentsOf: directoryURL))
}

/// Set the global config value by name.
/// 
/// - Parameter name: The name of the configuration value to set.
/// - Parameter value: The value to set the configuration value to.
/// 
/// - Returns: The value of the configuration value, or nil if it does not exist.
/// 
/// - Throws: Error
func setGlobalConfigValue(name: String,
                          value: String) throws -> String {
    return try setConfigValueInPath(name: name,
                                    value: value,
                                    path: nil)
}

/// Set the global config value by name.
func addGlobalConfigValue(name: String,
                          value: String) throws {
    try ShellClient().run(
        "git config --global --add \(name) \(value)"
    )
}

/// Adds a path to the `safe.directories` configuration variable if it's not
/// already present. Adding a path to `safe.directory` will cause Git to ignore
/// if the path is owner by a different user than the current.
/// 
/// - Parameter path: The path to add to the `safe.directories` configuration variable.
/// 
/// - Throws: Error
func addSafeDirectory(path: String) throws {
    try addGlobalConfigValueIfMissing(name: "safe.directory",
                                      value: path)
}

/// Set the global config value by name.
/// 
/// - Parameter name: The name of the configuration value to set.
/// - Parameter value: The value to set the configuration value to.
/// 
/// - Throws: Error
func addGlobalConfigValueIfMissing(name: String,
                                   value: String) throws {
    let result = try ShellClient.live().run(
        "git config --global -z --get-all \(name) \(value)"
    )

    if result.split(separator: "\0").description.contains(value) {
        try addGlobalConfigValue(name: name, value: value)
    }
}

/// Set config value by name
///
/// - Parameter name: The name of the configuration value to set.
/// - Parameter value: The value to set the configuration value to.
/// - Parameter path: The path to execute the `git` command in. If null
///                   we'll use the global configuration (i.e. --global)
///                   and execute the Git call from the same location that
///                   Aurora Editor is installed in.
///
/// - Returns: The value of the configuration value, or nil if it does not exist.
////
/// - Throws: Error
@discardableResult
func setConfigValueInPath(name: String,
                          value: String,
                          path: String?) throws -> String {

    var gitCommand: String

    var flags = ["config"]

    if path == nil {
        flags.append("--global")
    }

    flags.append("--replace-all")
    flags.append(name)
    flags.append(value)

    if let path = path {
        gitCommand = "cd \(path.escapedWhiteSpaces()); git \(flags)"
    } else {
        gitCommand = "git \(flags)"
    }

    return try ShellClient.live().run(gitCommand)
}

/// Remove the local config value by name.
/// 
/// - Parameter directoryURL: The directory to remove the value in.
/// - Parameter name: The name of the configuration value to remove.
/// 
/// - Throws: Error
func removeConfigValue(directoryURL: URL,
                       name: String) throws {
    try removeConfigValueInPath(name: name,
                            path: String(contentsOf: directoryURL))
}

/// Remove the global config value by name.
/// 
/// - Parameter name: The name of the configuration value to remove.
/// 
/// - Throws: Error
func removeGlobalConfigValue(name: String) throws {
    try removeConfigValueInPath(name: name, path: nil)
}

/// Remove the config value by name
/// 
/// - Parameter name: The name of the configuration value to remove.
/// - Parameter path: The path to execute the `git` command in. If null
/// 
/// - Throws: Error
func removeConfigValueInPath(name: String,
                             path: String?) throws {

    var gitCommand: String

    var flags = ["config"]

    if path == nil {
        flags.append("--global")
    }

    flags.append("--unset-all")
    flags.append(name)

    if let path = path {
        gitCommand = "cd \(path.escapedWhiteSpaces()); git \(flags)"
    } else {
        gitCommand = "git \(flags)"
    }

    try ShellClient().run(gitCommand)
}
