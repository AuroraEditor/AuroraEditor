//
//  ThemeAttribtue.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 04/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Base theme attribute protocol
///
/// - Important: Do not just conform to `ThemeAttribute`, instead conform to either `TokenThemeAttribute`
/// or `LineThemeAttribute`. Only then will the attribute be applied.
public protocol ThemeAttribute: Codable {

    /// Unique key for this type of attribute
    var key: String { get }
}
