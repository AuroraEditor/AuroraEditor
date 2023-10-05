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
                            guard let url = repository.updateFileUrl else {
                                Log.debug("Invalid Url")
                                return
                            }
                            Log.debug("aeupdateservice:\\\(url)")
                            NSWorkspace.shared.open(URL(string: "aeupdateservice:\(url)")!)
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
