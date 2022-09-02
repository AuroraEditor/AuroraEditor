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
            Image(systemName: command.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .padding(2)
                .padding(.leading, 5)
            VStack(alignment: .leading, spacing: 0) {
                Text(command.name).font(.system(size: 14))
                    .lineLimit(1)
            }.padding(.trailing, 15)
            Spacer()
        }
    }
}
