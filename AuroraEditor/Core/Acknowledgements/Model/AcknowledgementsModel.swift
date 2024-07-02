//
//  AcknowledgementsModel.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 01.05.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The model for the acknowledgements
final class AcknowledgementsModel: ObservableObject {
    @Published
    /// The dependencies
    private (set) var acknowledgements: [Dependency]

    /// Initializes the model
    public init(_ dependencies: [Dependency] = []) {
        self.acknowledgements = dependencies

        if acknowledgements.isEmpty {
            fetchDependencies()
        }
    }

    /// Fetches the dependencies
    public func fetchDependencies() {
        self.acknowledgements.removeAll()
        do {
            if let bundlePath = Bundle.main.path(forResource: "Package.resolved", ofType: nil),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                let parsedJSON = try JSONDecoder().decode(RootObject.self, from: jsonData)
                for dependency in parsedJSON.object.pins.sorted(by: { $0.package < $1.package })
                where dependency.package.range(
                        of: "[Aa]rora[Ee]ditor",
                        options: .regularExpression,
                        range: nil,
                        locale: nil
                    ) == nil {
                    self.acknowledgements.append(
                        Dependency(
                            name: dependency.package,
                            repositoryLink: dependency.repositoryURL,
                            version: dependency.state.version ?? ""
                        )
                    )
                }
            }
        } catch {
            self.logger.info(error.localizedDescription)
        }
    }
}
