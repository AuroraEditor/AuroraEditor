//
//  Command.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A command that can be executed.
class Command: ObservableObject, Identifiable, Hashable {
    /// Compares two commands.
    /// 
    /// - Parameter lhs: The first command.
    /// - Parameter rhs: The second command. 
    /// 
    /// - Returns: A boolean value indicating whether the two commands are equal.
    static func == (lhs: Command, rhs: Command) -> Bool {
        lhs.id == rhs.id
    }

    /// The name of the command.
    @Published
    var name: String

    /// The command to execute.
    var command: () -> Void = {}

    /// The unique identifier of the command.
    var id = UUID()

    /// A boolean value indicating whether the command is enabled.
    var isEnabled: Bool

    /// Creates a new instance of the command.
    /// 
    /// - Parameter name: The name of the command.
    /// - Parameter command: The command to execute.
    /// - Parameter isEnabled: A boolean value indicating whether the command is enabled.
    init(name: String, command: @escaping () -> Void = {}, isEnabled: Bool = true) {
        self.name = name
        self.command = command
        self.isEnabled = isEnabled
    }

    /// Hash the command.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
