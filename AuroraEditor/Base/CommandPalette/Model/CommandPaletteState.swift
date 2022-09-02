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
    @Published var isShowingCommands: Bool = false

    public let fileURL: URL
    private let queue = DispatchQueue(label: "com.auroraeditor.quickOpen.commandPalette")

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func fetchCommands() {
        guard !commandQuery.isEmpty else {
            commands = []
            self.isShowingCommands = !commands.isEmpty
            return
        }

        queue.async { [weak self] in
            guard let self = self else { return }
            // TODO: Filter commands somehow
            DispatchQueue.main.async {
                self.commands = [
                    Command(name: "Test", icon: "circle"),
                    Command(name: "Pants", icon: "square"),
                    Command(name: "Pink", icon: "triangle")
                ]
                self.isShowingCommands = !self.commands.isEmpty
            }
        }
    }
}
