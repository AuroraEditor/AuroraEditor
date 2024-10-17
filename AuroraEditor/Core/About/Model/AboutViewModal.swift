//
//  AboutViewModal.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import OSLog

/// About View Modal
/// 
/// This class is responsible for loading the content of the About view.
@MainActor
public class AboutViewModal: ObservableObject {
    /// The shared instance of the AboutViewModal
    static var shared: AboutViewModal = .init()

    /// The URL to fetch the list of contributors
    let auroraContributors: String = "https://api.github.com/repos/AuroraEditor/AuroraEditor/contributors?per_page=100"

    @Published
    /// The list of contributors
    public var contributors: [Contributor] = []

    @Published
    /// The state of the detail view
    var aboutDetailState: AboutDetailState = .license

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "About view modal")

    /// Initializes the class
    init() {
        loadContributors(from: auroraContributors)
    }

    /// Loads the list of contributors from the given URL
    /// 
    /// - Parameter url: The URL to fetch the list of contributors
    private func loadContributors(from url: String) {
        AuroraNetworking().request(
            baseURL: url,
            path: "",
            useAuthType: .none,
            method: .GET,
            parameters: [:]
        ) { data in
            switch data {
            case .success(let data):
                let decoder = JSONDecoder()
                guard let contributors = try? decoder.decode([Contributor].self, from: data) else {
                    self.logger.debug(
                        "Error: Unable to decode \(String(describing: String(data: data, encoding: .utf8)))"
                    )
                    return
                }
                Task { @MainActor in
                    self.contributors.append(contentsOf: contributors)
                }
            case .failure(let error):
                self.logger.fault("\(error)")
            }
        }
    }

    /// Loads the content of the given file
    /// 
    /// - Parameter fileName: The name of the file
    /// - Parameter fileType: The type of the file
    public func loadFileContent(fileName: String, fileType: String) -> String {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            return "\(fileName) file not found."
        }
        do {
            let contents = try String(contentsOfFile: filepath)
            return contents
        } catch {
            return "Could not load \(fileName) for Aurora Editor."
        }
    }

    /// Loads the credits content
    public func loadCredits() -> String {
        loadFileContent(fileName: "Credits", fileType: "md")
    }

    /// Loads the license content
    public func loadLicense() -> String {
        loadFileContent(fileName: "License", fileType: "md")
    }
}
