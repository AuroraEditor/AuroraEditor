//
//  String+Ranges.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

extension StringProtocol where Index == String.Index {
    /// Returns the ranges of the specified substring in the string.
    /// 
    /// - Parameter substring: The substring to search for.
    /// - Parameter options: The search options.
    /// - Parameter locale: The locale to use.
    /// 
    /// - Returns: The ranges of the specified substring in the string.
    func ranges<T: StringProtocol>(
        of substring: T,
        options: String.CompareOptions = [],
        locale: Locale? = nil
    ) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let result = range(
            of: substring,
            options: options,
            range: (ranges.last?.upperBound ?? startIndex)..<endIndex,
            locale: locale) {
            ranges.append(result)
        }
        return ranges
    }
}
