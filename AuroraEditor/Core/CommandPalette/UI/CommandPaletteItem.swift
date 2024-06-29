//
//  CommandPaletteItem.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents a command palette item.
struct CommandPaletteItem: View {
    /// The command to display.
    private let command: Command

    /// Creates a new instance of the command palette item.
    /// 
    /// - Parameter command: The command to display.
    public init(
        command: Command
    ) {
        self.command = command
    }

    /// The view body.
    public var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(command.name).font(.system(size: 14))
                    .lineLimit(1)
                    .opacity(command.isEnabled ? 1 : 0.5)
            }.padding(.horizontal, 15)
            Spacer()
        }
    }
}
