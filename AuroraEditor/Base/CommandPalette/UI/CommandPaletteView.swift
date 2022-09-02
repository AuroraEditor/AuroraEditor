//
//  CommandPaletteView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct CommandPaletteView: View {
    @ObservedObject private var state: CommandPaletteState
    private let onClose: () -> Void
    private let openFile: (WorkspaceClient.FileItem) -> Void
    @State private var selectedItem: WorkspaceClient.FileItem?

    public init(
        state: CommandPaletteState,
        onClose: @escaping () -> Void,
        openFile: @escaping (WorkspaceClient.FileItem) -> Void
    ) {
        self.state = state
        self.onClose = onClose
        self.openFile = openFile
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "command")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 12)
                        .offset(x: 0, y: 1)
                    TextField("Execute Command", text: $state.openQuicklyQuery)
                        .font(.system(size: 20, weight: .light, design: .default))
                        .textFieldStyle(.plain)
                        .onReceive(
                            state.$openQuicklyQuery
                                .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
                        ) { _ in
                            state.fetchOpenQuickly()
                        }
                }
                    .padding(16)
                    .foregroundColor(.primary.opacity(0.85))
                    .background(EffectView(.sidebar, blendingMode: .behindWindow))
            }
            Divider()
            List(state.openQuicklyFiles, selection: $selectedItem) { file in
                CommandPaletteItem(baseDirectory: state.fileURL, fileItem: file)
                .onTapGesture(count: 2) {
                    self.openFile(file)
                    self.onClose()
                }
                .onTapGesture(count: 1) {
                    self.selectedItem = file
                }
                .background(self.selectedItem == file ?
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(Color(red: 0, green: 0.38, blue: 0.816, opacity: 0.85)) :
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(Color.clear))
            }
        }
            .background(EffectView(.sidebar, blendingMode: .behindWindow))
            .edgesIgnoringSafeArea(.vertical)
            .frame(minWidth: 600,
               minHeight: self.state.isShowingOpenQuicklyFiles ? 400 : 28,
               maxHeight: self.state.isShowingOpenQuicklyFiles ? .infinity : 28)
    }
}

struct CommandPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        CommandPaletteView(
            state: .init(fileURL: .init(fileURLWithPath: "")),
            onClose: {},
            openFile: { _ in }
        )
    }
}
