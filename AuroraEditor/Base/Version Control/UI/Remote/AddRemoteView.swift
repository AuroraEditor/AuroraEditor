//
//  AddRemoteView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct AddRemoteView: View {
    @Environment(\.dismiss)
    private var dismiss

    let workspace: WorkspaceDocument

    @State
    var remoteName: String = ""

    @State
    var remoteUrl: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Add exisiting remote:")
                .fontWeight(.bold)

            HStack {
                Text("Remote Name:")
                TextField("", text: $remoteName)
            }
            .padding(.top, 5)

            HStack {
                Text("Location:")
                TextField("", text: $remoteUrl)
            }

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(.primary)
                }

                if remoteName.isEmpty
                    || remoteUrl.isEmpty
                    || remoteName.count < 3
                    || remoteName.count > 250 {
                    Button {} label: {
                        Text("Add")
                            .foregroundColor(.gray)
                    }
                    .disabled(true)
                } else {
                    Button {
                        do {
                            try addRemote(directoryURL: workspace.workspaceURL(),
                                          name: remoteName,
                                          url: remoteUrl)
                            dismiss()
                        } catch {
                            Log.error("Unable to add exisiting remote.")
                        }
                    } label: {
                        Text("Add")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 500, height: 150)
    }
}

struct AddRemoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddRemoteView(workspace: WorkspaceDocument())
    }
}
