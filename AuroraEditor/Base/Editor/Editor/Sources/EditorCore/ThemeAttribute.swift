//
//  ThemeAttribtue.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

/// Base theme attribute protocol
///
/// - Important: Do not just conform to `ThemeAttribute`, instead conform to either `TokenThemeAttribute` or `LineThemeAttribute`. Only then will the attribute be applied.
public protocol ThemeAttribute {

    /// Unique key for this type of attribute
    var key: String { get }
}
