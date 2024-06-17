//
//  FileCreationGridView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// File creation grid view
struct FileCreationGridView: View {
    /// File creation model
    @StateObject
    private var creationSheetModel: FileCreationModel = .shared

    /// Grid item layout
    private var gridItemLayout: [GridItem] = Array(
        repeating: .init(.flexible()), count: 5
    )

    /// The view body
    var body: some View {
        ScrollView(.vertical) {
            Section {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(creationSheetModel.languageItems, id: \.self) { language in
                        GridColumn(item: language,
                                   selectedItem: $creationSheetModel.selectedLanguageItem)
                    }
                }
            } header: {
                VStack {
                    HStack {
                        Text("Source Files")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                            .padding(5)

                        Spacer()
                    }

                    Divider()
                        .padding(.vertical, -8)
                }
            }
        }
        .border(.gray.opacity(0.3))
    }

    /// Grid column view
    struct GridColumn: View {
        /// File selection item
        let item: FileSelectionItem

        /// Selected item
        @Binding
        var selectedItem: FileSelectionItem

        /// The view body
        var body: some View {
            Button(action: {
                selectedItem = item
            }, label: {
                VStack {
                    Image(item.langaugeIcon) // FIXME: TYPO
                        .padding(.bottom, 10)
                        .accessibilityLabel(Text("Language Icon"))

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
}

struct FileCreationGridView_Previews: PreviewProvider {
    static var previews: some View {
        FileCreationGridView()
    }
}
