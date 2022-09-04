//
//  CommandPaletteItem.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct CommandPaletteItem: View {
    private let command: Command

    public init(
        command: Command
    ) {
        self.command = command
    }

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
