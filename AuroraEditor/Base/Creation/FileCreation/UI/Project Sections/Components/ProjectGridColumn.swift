//
//  ProjectGridColumn.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/02.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ProjectGridColumn: View {
    let item: ProjectSelectionItem

    @Binding
    var selectedItem: ProjectSelectionItem

    var body: some View {
        Button(action: {
            selectedItem = item
        }, label: {
            VStack {
                Image(item.langaugeIcon)
                    .padding(.bottom, 10)

                Text(item.languageName)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .font(.system(size: 11))
            }
        })
        .buttonStyle(.plain)
        .frame(width: 85, height: 85)
        // swiftlint:disable:next line_length
        .background(selectedItem == item ? Color(nsColor: NSColor.controlAccentColor).opacity(0.08) : Color.white.opacity(0))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
