//
//  View+isHidden.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 18/11/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    @ViewBuilder func isHidden(_ hidden: Bool) -> some View {
        if !hidden {
            self
        }
    }
}
