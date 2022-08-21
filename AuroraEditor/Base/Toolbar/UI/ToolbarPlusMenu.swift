//
//  ToolbarPlusMenu.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

public struct ToolbarPlusMenu: View {

    @State var workspace: WorkspaceDocument?

    @Environment(\.controlActiveState)
    private var controlActive

    @State
    private var displayPopover: Bool = false

    public var body: some View {
        Button {
            displayPopover.toggle()
        } label: {
            Image(systemName: "plus")
                .scaledToFill()
        }
        .popover(isPresented: $displayPopover, arrowEdge: .bottom) {
            HStack {
                Button {
                    workspace?.openTab(item: WebTab(url: URL(string: "https://auroraeditor.com")))
                } label: {
                    VStack {
                        Image(systemName: "globe")
                            .font(.system(size: 30))
                            .scaledToFill()
                        Text("Web View")
                    }
                    .padding(.all, 10)
                    .frame(height: 60)
                }
                Button { } label: {
                    VStack {
                        Image(systemName: "circle")
                            .font(.system(size: 30))
                            .scaledToFill()
                        Text("Placeholder")
                    }
                    .padding(.all, 10)
                    .frame(height: 60)
                }
                Button { } label: {
                    VStack {
                        Image(systemName: "circle")
                            .font(.system(size: 30))
                            .scaledToFill()
                        Text("Placeholder")
                    }
                    .padding(.all, 10)
                    .frame(height: 60)
                }
            }
            .buttonStyle(.borderless)
            .padding(.all, 10)
        }
    }
}
