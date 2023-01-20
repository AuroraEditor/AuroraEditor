//
//  ExtensionInstallationViewModel.swift
//  AuroraEditor
//
//  Created by Pavel Kasila on 8.04.22.
//

import Foundation
import Combine

final class ExtensionInstallationViewModel: ObservableObject {

    enum State {
        case loading
        case error
        case success
    }

    @Published
    var state: State = .loading

    @Published
    var extensions: [Plugin] = []

    init() {
        fetchExtensions()
    }

    func fetchExtensions() {
        AuroraNetworking().request(baseURL: Constants.auroraEditorBaseURL,
                                   path: Constants.extensions,
                                   useAuthType: .none,
                                   method: .GET,
                                   parameters: nil,
                                   completionHandler: { completion in
            switch completion {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    guard let extensions = try decoder.decode([Plugin]?.self, from: data) else {
                        Log.debug(
                            "Error: Unable to decode",
                            String(data: data, encoding: .utf8) ?? ""
                        )
                        DispatchQueue.main.async {
                            self.state = .error
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.state = .success
                        self.extensions = extensions
                    }
                } catch {
                    Log.debug(error)
                }
            case .failure(let failure):
                self.state = .error
                Log.error(failure)
            }

        })
    }

    func downloadExtension(extensionId: String) {
        AuroraNetworking().request(baseURL: Constants.auroraEditorBaseURL,
                                   path: Constants.downloadExtension(extensionId: extensionId),
                                   useAuthType: .none,
                                   method: .GET,
                                   parameters: nil,
                                   completionHandler: { completion in
            switch completion {
            case .success(let success):
                Log.debug(String(data: success, encoding: .utf8))
            case .failure(let failure):
                Log.debug(failure)
            }

        })
    }

}
