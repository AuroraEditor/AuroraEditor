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
    @State private var selectedCommand: Command?

    public init(
        state: CommandPaletteState,
        onClose: @escaping () -> Void,
        openFile: @escaping (WorkspaceClient.FileItem) -> Void
    ) {
        self.state = state
        self.onClose = onClose
        self.openFile = openFile
    }

    /// It should return bool value in order to notify underlying handler if event was handled or not.
    /// So returning true - means you need to break the chain and do not pass event down the line
    func onKeyDown(with event: NSEvent) -> Bool {
        switch event.keyCode {
        case 125: // down arrow
            selectOffset(by: 1)
            return true

        case 126: // up arrow
            selectOffset(by: -1)
            return true

        case 36: // enter key
            if let selectedCommand = selectedCommand {
                selectedCommand.command()
            }
            self.onClose()
            return true

        case 53: // esc key
            self.onClose()
            return true

        default:
            return false
        }
    }

    func selectOffset(by offset: Int) {
        guard !state.commands.isEmpty else { return }

        // check if a command has been selected
        if let selectedCommand = selectedCommand, let currentIndex = state.commands.firstIndex(of: selectedCommand) {
            // select current index + offset, wrapping around if theres underflow or overflow.
            let newIndex = (currentIndex + offset + state.commands.count) % (state.commands.count)
            self.selectedCommand = state.commands[newIndex]
        } else {
            // if theres no selected command, just select the first or last item depending on direction
            selectedCommand = state.commands[ offset < 0 ? state.commands.count-1 : 0]
        }
    }

    func onQueryChange(text: String) {
        state.fetchCommands()
        if !state.isShowingCommands {
            selectedCommand = nil
        }
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
                    ActionAwareInput(onDown: onKeyDown,
                                     onTextChange: onQueryChange,
                                     text: $state.commandQuery)
                }
                .padding(16)
                .foregroundColor(.primary.opacity(0.85))
            }
            .frame(height: 52)
            if state.isShowingCommands {
                Divider()
                List(state.commands, selection: $selectedCommand) { command in
                    ZStack {
                        CommandPaletteItem(command: command)
                            .onTapGesture(count: 2) {
                                command.command()
                                self.onClose()
                            }
                            .onTapGesture(count: 1) {
                                self.selectedCommand = command
                            }
                            .background(self.selectedCommand == command ?
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color(red: 0, green: 0.38, blue: 0.816, opacity: 0.85)) :
                                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color.clear))

                        Button("") {
                            if let selectedCommand = selectedCommand {
                                selectedCommand.command()
                                self.onClose()
                            }
                        }
                        .buttonStyle(.borderless)
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .padding([.top, .horizontal], -5)
                .listStyle(.sidebar)
            }
        }
        .background(EffectView(.sidebar, blendingMode: .behindWindow))
        .edgesIgnoringSafeArea(.vertical)
        .frame(minWidth: 600,
           minHeight: self.state.isShowingCommands ? 400 : 28,
           maxHeight: self.state.isShowingCommands ? .infinity : 28)
    }
}

struct CommandPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        CommandPaletteView(
            state: .init(),
            onClose: {},
            openFile: { _ in }
        )
    }
}
