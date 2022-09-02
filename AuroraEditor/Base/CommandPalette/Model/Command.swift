//
//  Command.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

class Command: ObservableObject, Identifiable, Hashable {
    static func == (lhs: Command, rhs: Command) -> Bool {
        lhs.id == rhs.id
    }

    @Published var name: String
    var command: () -> Void = {}
    var id = UUID()

    init(name: String, command: @escaping () -> Void = {}) {
        self.name = name
        self.command = command
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
