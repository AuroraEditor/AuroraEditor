//
//  UpdateUpToDateState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/04.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents the update up to date state.
struct UpdateUpToDateState: View {
    /// Preferences model
    @State
    private var prefs: AppPreferencesModel

    /// Update model
    @State
    private var model: UpdateObservedModel

    /// Update up to date state
    /// 
    /// - Parameter prefs: The preferences model
    /// - Parameter model: The update model
    init(prefs: AppPreferencesModel,
         model: UpdateObservedModel) {
        self.prefs = prefs
        self.model = model
    }

    /// The view body
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
