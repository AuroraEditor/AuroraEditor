//
//  BranchErrorMessageView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/22.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

struct BranchErrorMessageView: View {

    @State
    var isWarning: Bool = false

    @State
    var errorMessage: String = ""

    var body: some View {
        HStack {
            Image(systemName: isWarning ? "exclamationmark.triangle.fill" : "exclamationmark.octagon.fill")
                .symbolRenderingMode(.multicolor)
                .accessibilityHidden(true)

            Text(errorMessage)
                .font(.system(size: 11))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
}
