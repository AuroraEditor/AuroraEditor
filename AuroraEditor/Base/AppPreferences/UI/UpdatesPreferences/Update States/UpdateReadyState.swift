//
//  UpdateReadyState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct UpdateReadyState: View {

    private let repository: UpdateEditorRepository

    @State
    private var model: UpdateObservedModel

    @State
    private var prefs: AppPreferencesModel

    @State
    private var showInstallAlert: Bool = false

    init(repository: UpdateEditorRepository, model: UpdateObservedModel, prefs: AppPreferencesModel) {
        self.repository = repository
        self.model = model
        self.prefs = prefs
    }

    var body: some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Updates Available")
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                        Button {
                            showInstallAlert.toggle()
                        } label: {
                            Text("Install Now")
                        }
                        .alert("Restart Required",
                               isPresented: $showInstallAlert, actions: {
                            Button(role: .destructive) {
                                guard let url = repository.updateFileUrl else {
                                    Log.debug("Invalid Url")
                                    return
                                }

                                NSWorkspace.shared.open(URL(string: "updateservice:\\\(url)")!)

                                exit(0)
                            } label: {
                                Text("Continue")
                            }

                            Button(role: .cancel) {
                            } label: {
                                Text("Cancel")
                            }
                        }, message: {
                            Text("The editor needs to be restarted in order to apply the update.")
                        })

                        Button {
                        } label: {
                            Text("Remind me Later")
                        }
                    }

                    // swiftlint:disable:next line_length
                    Text("\u{00B7} Aurora Editor \(model.updateModelJson?.versionCode ?? "") \(prefs.preferences.updates.updateChannel.rawValue)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)

                    Divider()
                        .padding(.vertical, 5)

                    Link("More Info...",
                         destination: URL(string: "https://auroraeditor.com")!)
                    .font(.system(size: 12))
                    .foregroundColor(.accentColor)
                }
                .padding(5)
            }
            .padding(5)
        }
    }
}
