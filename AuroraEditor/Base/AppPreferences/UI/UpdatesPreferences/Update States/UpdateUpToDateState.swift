//
//  UpdateUpToDateState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/04.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct UpdateUpToDateState: View {

    @State
    private var prefs: AppPreferencesModel

    @State
    private var model: UpdateObservedModel

    init(prefs: AppPreferencesModel,
         model: UpdateObservedModel) {
        self.prefs = prefs
        self.model = model
    }

    var body: some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Check for Updates")
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                        Button {
                            prefs.preferences.updates.lastChecked = Date()
                            model.checkForUpdates()
                        } label: {
                            Text("Check Now")
                        }
                    }

                    Text("Aurora Editor \(Bundle.versionString ?? "")")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                        .padding(.bottom, -2)

                    // swiftlint:disable:next line_length
                    Text("Last Checked: \(prefs.preferences.updates.lastChecked.formatted(date: .complete, time: .standard)) ")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.bottom, -2)

                    Text("Aurora Editor is up to date")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)

                }
                .padding(5)
            }
            .padding(5)
        }
    }
}
