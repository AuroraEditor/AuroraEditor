//
//  StashChangesSheet.swift
//  
//
//  Created by Nanashi Li on 2022/07/13.
//

import SwiftUI

public struct StashChangesSheet: View {

    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject
    private var gitModel: GitUIModel

    @State
    private var stashMessage: String = ""

    public init(workspaceURL: URL) {
        self.gitModel = .init(workspaceURL: workspaceURL)
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text("Stash Changes")
                .fontWeight(.bold)
                .padding([.leading, .top])
                .padding(.bottom, 5)

            Text("Enter a description for your stashed changes so you can reference them later.")
                .font(.system(size: 11))
                .padding(.horizontal)
            Text("Stashes will appear in the Source Control navigator for your repository.")
                .font(.system(size: 11))
                .padding(.horizontal)

            TextEditor(text: $stashMessage)
                .border(Color(NSColor.separatorColor))
                .overlay {
                    if stashMessage.isEmpty {
                        Text("Optional Message")
                            .font(.system(size: 14))
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding([.horizontal, .bottom])
                .frame(height: 97)

            HStack {
                Spacer()

                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.primary)
                    }

                    Button {
                        gitModel.stashChanges(message: stashMessage)
                        dismiss()
                    } label: {
                        Text("Stash")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding([.trailing, .bottom])
        }
        .frame(width: 485)
    }
}
