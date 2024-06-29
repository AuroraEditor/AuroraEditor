//
//  UpdateErrorState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents the update error state.
struct UpdateErrorState: View {
    /// Preferences model
    @State
    public var prefs: AppPreferencesModel

    /// Update model
    @State
    public var updateModel: UpdateObservedModel

    /// Update error state view
    /// 
    /// - Parameter prefs: The preferences model
    /// - Parameter updateModel: The update model
    init(prefs: AppPreferencesModel,
         updateModel: UpdateObservedModel) {
        self.prefs = prefs
        self.updateModel = updateModel
    }

    /// The view body
    var body: some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("settings.update.failure.checking")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.red)
                        Spacer()
                        Button {
                            prefs.preferences.updates.lastChecked = Date()
                            updateModel.checkForUpdates()
                        } label: {
                            Text("settings.update.retry")
                        }
                    }
                }
                .padding(5)
            }
            .padding(5)
        }
    }
}
