//
//  UpdateReadyState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents the update ready state.
struct UpdateReadyState: View {
    /// Update editor repository
    private let repository: UpdateEditorRepository

    /// Update model
    @State
    private var model: UpdateObservedModel

    /// Preferences model
    @State
    private var prefs: AppPreferencesModel

    /// Show install alert
    @State
    private var showInstallAlert: Bool = false

    /// Update ready state
    /// 
    /// - Parameter repository: The update editor repository
    /// - Parameter model: The update model
    /// - Parameter prefs: The preferences model
    init(repository: UpdateEditorRepository, model: UpdateObservedModel, prefs: AppPreferencesModel) {
        self.repository = repository
        self.model = model
        self.prefs = prefs
    }

    /// The view body
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
                                    return
                                }

                                NSWorkspace.shared.open(URL("updateservice://\(url)"))

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
                         destination: URL("https://auroraeditor.com"))
                    .font(.system(size: 12))
                    .foregroundColor(.accentColor)
                }
                .padding(5)
            }
            .padding(5)
        }
    }
}
