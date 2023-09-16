//
//  UpdateModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/23.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

private var prefs: AppPreferencesModel = .shared

public class UpdateObservedModel: ObservableObject {

    public static let shared: UpdateObservedModel = .init()

    private var commitHash: String {
        Bundle.commitHash ?? "No Hash"
    }

    enum UpdateState {
        case loading
        case error
        case success
        case updateFound
    }

    // We put this as success as to avoid a constant loading loop in debug builds
    @Published
    var updateState: UpdateState = .success

    @Published
    var updateStatus: UpdateModel?

    /// This function allows us to to check for any new updates for the editor.
    ///
    /// We fetch a json based on the users update channel, currently there are three channels
    ///  Base URL: https://auroraeditor.com
    ///  * Release - updates/dynamic/macos/release.json
    ///  * Beta - updates/dynamic/macos/beta.json
    ///  * Nightly - updates/dynamic/macos/nightly.json
    public func checkForUpdates() {
        DispatchQueue.main.async {
            self.updateState = .loading
        }

        // We are just doing this to show the user there is a check instead of it being an instant fetch
        // of the update json... Coperate 101 never do anything quickly 🤣
        //
        // Reason for this not being on main thread is that it's a network call and it's best practice
        // to have network calls on the background thread leaving the main thread just for UI.
        DispatchQueue(label: "Update", qos: .background).asyncAfter(deadline: .now() + 5) {
            let constants = UpdateConstants()
            AuroraNetworking().request(baseURL: constants.baseURL,
                                       path: constants.updateFileURL(),
                                       useAuthType: .none,
                                       method: .GET,
                                       parameters: nil,
                                       completionHandler: { result in
                switch result {
                case .success(let data):
                    do {
                        if data.isEmpty {
                            DispatchQueue.main.async {
                                self.updateState = .error
                            }
                        }

                        let decoder = JSONDecoder()
                        let updateFile = try decoder.decode(UpdateModel.self, from: data)
                        DispatchQueue.main.async {
                            self.updateStatus = updateFile

                            if updateFile.sha256sum != self.commitHash {
                                self.updateState = .updateFound
                                return
                            }

                            self.updateState = .success
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.updateState = .error
                        }
                        Log.debug(
                            "Error: \(error)",
                            String(data: data, encoding: .utf8) ?? ""
                        )
                    }
                case .failure(let failure):
                    DispatchQueue.main.async {
                        self.updateState = .error
                    }
                    Log.debug(failure)
                }
            })
        }
    }
}

struct UpdateModel: Codable {
    let versionCode: String
    let versionName: String
    let sha256sum: String
    let url: String
}

private struct UpdateConstants {
    /// Base URL
    public let baseURL = "https://auroraeditor.com/"

    /// get update file url
    /// - Returns: update url
    public func updateFileURL() -> String {
        switch prefs.preferences.updates.updateChannel {
        case .release:
            return "updates/dynamic/macos/release.json"
        case .beta:
            return "updates/dynamic/macos/beta.json"
        case .nightly:
            return "updates/dynamic/macos/nightly.json"
        }
    }
}
