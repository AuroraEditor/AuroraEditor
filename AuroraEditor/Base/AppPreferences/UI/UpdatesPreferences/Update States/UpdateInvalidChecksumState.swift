//
//  UpdateInvalidChecksumState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/04.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

/// A view that represents the update invalid checksum state.
struct UpdateInvalidChecksumState: View {
    /// Update editor repository
    private let repository: UpdateEditorRepository

    /// Preferences model
    @State
    private var prefs: AppPreferencesModel

    /// Update model
    @State
    private var model: UpdateObservedModel

    /// Update invalid checksum state
    /// 
    /// - Parameter repository: The update editor repository
    /// - Parameter prefs: The preferences model
    /// - Parameter model: The update model
    init(repository: UpdateEditorRepository,
         prefs: AppPreferencesModel,
         model: UpdateObservedModel) {
        self.repository = repository
        self.prefs = prefs
        self.model = model
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
                            guard let url = repository.updateFileUrl else {
                                return
                            }
                            NSWorkspace.shared.open(URL(string: "aeupdateservice:\\\(url)")!)
                        } label: {
                            Text("Install Now")
                        }

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
