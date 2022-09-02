//
//  CommandPaletteState.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Combine
import Foundation

public final class CommandPaletteState: ObservableObject {
    @Published var commandQuery: String = ""
    @Published var commands: [Command] = []
    @Published var possibleCommands: [Command] = []
    @Published var isShowingCommands: Bool = false

    private let queue = DispatchQueue(label: "com.auroraeditor.quickOpen.commandPalette")

    init(commands: [Command] = []) {
        self.possibleCommands = commands
    }

    func fetchCommands() {
        guard !commandQuery.isEmpty else {
            Log.info("Query is empty")
            DispatchQueue.main.async {
                self.commands = []
                self.isShowingCommands = false
            }
            return
        }

        queue.async { [weak self] in
            guard let self = self else { return }
            // TODO: Filter commands somehow
            DispatchQueue.main.async {
                self.commands = self.possibleCommands
                self.isShowingCommands = !self.commands.isEmpty
            }
        }
    }
}
