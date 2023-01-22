//
//  AboutViewModal.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

class AboutViewModal: ObservableObject {

    static var shared: AboutViewModal = .init()

    let auroraContributers: String = "https://api.github.com/repos/AuroraEditor/AuroraEditor/contributors?per_page=100"

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
                DispatchQueue.main.async {
                    self.contributers.append(contentsOf: contributers)
                }
            case .failure(let error):
                Log.debug(error)
            }
        }
    }

    public func loadCredits() -> String {
        if let filepath = Bundle.main.path(forResource: "Credits", ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                return "Could not load credits for Aurora Editor."
            }
        } else {
            return "Credit file not found."
        }
    }

    public func loadLicense() -> String {
        if let filepath = Bundle.main.path(forResource: "License", ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                return "Could not load license for Aurora Editor."
            }
        } else {
            return "License file not found."
        }
    }
}
