//
//  CommandPaletteState.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Combine
import Foundation

/// The state of the command palette.
public final class CommandPaletteState: ObservableObject {
    /// The query of the command palette.
    @Published
    var commandQuery: String = ""

    /// The commands that match the query.
    @Published
    var commands: [Command] = []

    /// The possible commands that can be executed.
    @Published
    var possibleCommands: [Command] = []

    /// A boolean value indicating whether the command palette is showing.
    @Published
    var isShowingCommands: Bool = false

    /// The queue to perform the search.
    private let queue = DispatchQueue(label: "com.auroraeditor.quickOpen.commandPalette")

    /// Creates a new instance of the command palette state.
    init(possibleCommands: [Command] = []) {
        self.possibleCommands = possibleCommands
    }

    /// Fetches the commands that match the query.
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
            DispatchQueue.main.async {
                self.commands = self.possibleCommands.filter({
                    $0.name.lowercased().contains(self.commandQuery.lowercased())
                }).sorted(by: { $0.name.count < $1.name .count })
                self.isShowingCommands = !self.commands.isEmpty
            }
        }
    }

    /// Adds a command to the possible commands.
    /// 
    /// - Parameter command: The command to add.
    func addCommand(command: Command) {
        possibleCommands.append(command)
    }

    /// Adds commands to the possible commands.
    /// 
    /// - Parameter commands: The commands to add.
    func addCommands(commands: [Command]) {
        possibleCommands.append(contentsOf: commands)
    }
}
