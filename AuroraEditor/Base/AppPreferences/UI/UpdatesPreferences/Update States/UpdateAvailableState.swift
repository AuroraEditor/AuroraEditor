//
//  UpdateAvailableState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct UpdateAvailableState: View {

    @State
    private var isUpdateButtonDisabled: Bool = false

    @State
    private var prefs: AppPreferencesModel

    @State
    private var model: UpdateObservedModel

    @State
    private var showLicenseSheet: Bool = false

    init(model: UpdateObservedModel, prefs: AppPreferencesModel) {
        self.model = model
        self.prefs = prefs
    }

    var body: some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("settings.update.channel.update.available")
                            .font(.system(size: 12, weight: .medium))

                        Spacer()
                        Button {
                            showLicenseSheet.toggle()
                        } label: {
                            Text("settings.update.channel.update.now")
                        }
                        .sheet(isPresented: $showLicenseSheet) {
                            LicenseView(closeSheet: $showLicenseSheet, model: model)
                        }
                    }

                    // swiftlint:disable:next line_length
                    Text("\u{00B7} Aurora Editor \(model.updateModelJson?.versionCode ?? "") \(prefs.preferences.updates.updateChannel.rawValue) - \(getDownloadSize())")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    if isUpdateButtonDisabled {
                        Text("settings.update.channel.debug.build.warning")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(5)
                    }

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
            .disabled(isUpdateButtonDisabled)
        }
    }

    private func getDownloadSize() -> String {
        return Int64(model.updateModelJson!.size)?.fileSizeString ?? "Unknown Size"
    }
}
