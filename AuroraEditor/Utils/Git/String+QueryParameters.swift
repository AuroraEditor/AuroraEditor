//
//  String+QueryParameters.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

extension String {
    var bitbucketQueryParameters: [String: String] {
        let parametersArray = components(separatedBy: "&")
        var parameters = [String: String]()
        parametersArray.forEach { parameter in
            let keyValueArray = parameter.components(separatedBy: "=")
            let (key, value) = (keyValueArray.first, keyValueArray.last)
            if let key = key?.removingPercentEncoding, let value = value?.removingPercentEncoding {
                parameters[key] = value
            }
        }
        return parameters
    }
}
