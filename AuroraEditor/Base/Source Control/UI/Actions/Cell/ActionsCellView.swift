//
//  ActionsCellView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ActionsCellView: View {

    @State
    var workflow: Workflow

    var body: some View {
        HStack {
            Image(systemName: "checkmark.diamond.fill")

            Text(workflow.name)
                .font(.system(size: 11))

            Text("(Build & Lint)")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
    }
}
