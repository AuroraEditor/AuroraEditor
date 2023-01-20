//
//  WelcomeModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/20.
//

import SwiftUI

var appVersion: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
}

var appBuild: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
}

/// Get the MacOS version & build
var macOsVersion: String {
    let url = URL(fileURLWithPath: "/System/Library/CoreServices/SystemVersion.plist")
    guard let dict = NSDictionary(contentsOf: url),
          let version = dict["ProductUserVisibleVersion"],
          let build = dict["ProductBuildVersion"]
    else {
        return ProcessInfo.processInfo.operatingSystemVersionString
    }

    return "\(version) (\(build))"
}

/// Return the Xcode version and build (if installed)
var xcodeVersion: String? {
    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode"),
          let bundle = Bundle(url: url),
          let infoDict = bundle.infoDictionary,
          let version = infoDict["CFBundleShortVersionString"] as? String,
          let buildURL = URL(string: "\(url)Contents/version.plist"),
          let buildDict = try? NSDictionary(contentsOf: buildURL, error: ()),
          let build = buildDict["ProductBuildVersion"]
    else {
        return nil
    }

    return "\(version) (\(build))"
}

/// Get program and operating system information
func copyInformation() {
    var copyString = "Aurora Editor: \(appVersion) (\(appBuild))\n"

    if let hash = Bundle.commitHash {
        copyString.append("Commit: \(hash)\n")
    }

    copyString.append("MacOS: \(macOsVersion)\n")

    if let xcodeVersion = xcodeVersion {
        copyString.append("Xcode: \(xcodeVersion)")
    }

    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(copyString, forType: .string)
}
