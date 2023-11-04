//
//  URL.swift
//  Aurora Editor Updater
//
//  Created by Nanashi Li on 2023/10/03.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }

        var parameters = [String: String]()
        for queryItem in queryItems {
            if let name = queryItem.name, let value = queryItem.value {
                parameters[name] = value
            }
        }
        return parameters
    }
}
