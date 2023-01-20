//
//  AboutViewModal.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

class AboutViewModal: ObservableObject {

    public var shared: AboutViewModal = .init()

    let auroraContributers: String = "https://api.github.com/repos/AuroraEditor/AuroraEditor/contributors"

    @Published
    public var contributers: [Contributor] = []

    init() {
        loadContributors(from: auroraContributers)
    }

    private func loadContributors(from url: String) {
        AuroraNetworking().request(baseURL: url,
                                   path: "",
                                   useAuthType: .none,
                                   method: .GET,
                                   parameters: [:]) { data in
            switch data {
            case .success(let data):
                let decoder = JSONDecoder()
                guard let contributers = try? decoder.decode([Contributor].self, from: data) else {
                    Log.debug(
                        "Error: Unable to decode",
                        String(data: data, encoding: .utf8) ?? ""
                    )
                    return
                }
                self.contributers.append(contentsOf: contributers)
            case .failure(let error):
                Log.debug(error)
            }
        }
    }
}
