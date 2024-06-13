//
//  UpdateLoadingState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents the update loading state.
struct UpdateLoadingState: View {
    /// The view body
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    Text("Checking for Updates...")
                        .font(.system(size: 12, weight: .medium))
                    Spacer()

                    ProgressView()
                        .progressViewStyle(.linear)
                        .frame(width: 100)

                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
        }
        .padding(5)
    }
}
