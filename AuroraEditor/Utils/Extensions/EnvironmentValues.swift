//
//  EnvironmentValues.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/24.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    /// The current code editor theme.
    public var codeHighlightTheme: Theme {
        get {
            self[CodeHighlightTheme.self]
        }
        set {
            self[CodeHighlightTheme.self] = newValue
        }
    }
}
