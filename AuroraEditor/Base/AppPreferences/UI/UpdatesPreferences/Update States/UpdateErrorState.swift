//
//  UpdateErrorState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct UpdateErrorState: View {

    @State
    public var prefs: AppPreferencesModel

    @State
    public var updateModel: UpdateObservedModel

    init(prefs: AppPreferencesModel,
         updateModel: UpdateObservedModel) {
        self.prefs = prefs
        self.updateModel = updateModel
    }

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
