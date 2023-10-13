//
//  UpdateInvalidChecksumState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/04.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct UpdateInvalidChecksumState: View {

    private let repository: UpdateEditorRepository

    @State
    private var prefs: AppPreferencesModel

    @State
    private var model: UpdateObservedModel

    init(repository: UpdateEditorRepository,
         prefs: AppPreferencesModel,
         model: UpdateObservedModel) {
        self.repository = repository
        self.prefs = prefs
        self.model = model
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
                            guard let url = repository.updateFileUrl else {
                                Log.debug("Invalid Url")
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
