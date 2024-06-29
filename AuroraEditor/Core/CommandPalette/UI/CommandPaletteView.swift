//
//  CommandPaletteView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents the command palette.
struct CommandPaletteView: View {
    /// The ObservedObject of the command palette.
    @ObservedObject
    private var state: CommandPaletteState

    /// The action to perform when the command palette is closed.
    private let onClose: () -> Void

    /// The action to perform when a file is opened.
    private let openFile: (FileSystemClient.FileItem) -> Void

    /// The selected command.
    @State
    private var selectedCommand: Command?

    /// Creates a new instance of the command palette.
    /// 
    /// - Parameter state: The state of the command palette.
    /// - Parameter onClose: The action to perform when the command palette is closed.
    /// - Parameter openFile: The action to perform when a file is opened.
    public init(
        state: CommandPaletteState,
        onClose: @escaping () -> Void,
        openFile: @escaping (FileSystemClient.FileItem) -> Void
    ) {
        self.state = state
        self.onClose = onClose
        self.openFile = openFile
    }

    /// on key down event handler
    /// 
    /// It should return bool value in order to notify underlying handler if event was handled or not.
    /// So returning true - means you need to break the chain and do not pass event down the line
    /// 
    /// - Parameter event: The NSEvent object.
    /// 
    /// - Returns: A boolean value indicating whether the event was handled.
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

    /// Selects the offset.
    /// 
    /// - Parameter offset: The offset.
    func selectOffset(by offset: Int) {
        guard !state.commands.isEmpty else { return }

        // check if a command has been selected
        if let selectedCommand = selectedCommand, let currentIndex = state.commands.firstIndex(of: selectedCommand) {
            // select current index + offset, wrapping around if theres underflow or overflow.
            let newIndex = (currentIndex + offset + state.commands.count) % (state.commands.count)
            self.selectedCommand = state.commands[newIndex]
        } else {
            // if theres no selected command, just select the first or last item depending on direction
            selectedCommand = state.commands[ offset < 0 ? state.commands.count - 1 : 0]
        }
    }

    /// on query change event handler
    /// 
    /// - Parameter text: The text.
    func onQueryChange(text: String) {
        state.fetchCommands()
        if !state.isShowingCommands {
            selectedCommand = nil
        }
    }

    /// The view body
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
                        .accessibilityLabel(Text("Command Palette"))
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
                            .accessibilityAddTraits(.isButton)
                            .onTapGesture(count: 1) {
                                self.selectedCommand = command
                            }
                            .accessibilityAddTraits(.isButton)
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
