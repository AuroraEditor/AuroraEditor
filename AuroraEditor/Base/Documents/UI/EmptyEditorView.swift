//
//  EmptyEditorView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct EmptyEditorView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.bar)
            Text("No Editor")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .frame(minHeight: 0)
                .clipped()
                .overlay {
                    Button(
                        action: {
                            NSApplication.shared.keyWindow?.close()
                        },
                        label: { EmptyView() }
                    )
                    .frame(width: 0, height: 0)
                    .padding(0)
                    .opacity(0)
                    .keyboardShortcut("w", modifiers: [.command])
                }
        }
    }
}

struct EmptyEditorView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyEditorView()
    }
}
