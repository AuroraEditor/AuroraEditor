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
        lhs.name == rhs.name && lhs.icon == rhs.icon
    }

    @Published var name: String
    @Published var icon: String
    var id = UUID()

    init(name: String, icon: String) {
        self.name = name
        self.icon = icon
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(icon)
    }
}
