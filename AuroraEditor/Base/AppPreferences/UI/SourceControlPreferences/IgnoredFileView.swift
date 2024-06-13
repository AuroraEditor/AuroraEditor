//
//  IgnoredFileView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The ignored file view
struct IgnoredFileView: View {
    /// The ignored files
    @Binding
    var ignoredFile: IgnoredFiles

    /// The view body
    var body: some View {
        Text(ignoredFile.name)
    }
}
