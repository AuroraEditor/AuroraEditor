//
//  UpdateInProgressState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/03.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents the update in progress state.
struct UpdateInProgressState: View {
    /// Update editor repository
    @State
    private var repository: UpdateEditorRepository

    /// Download progress
    @State
    private var downloadProgress: Double = 0.0

    /// ETA progress
    @State
    private var etaProgress: String = ""

    /// Update model
    @State
    private var model: UpdateObservedModel

    /// Update in progress state
    /// 
    /// - Parameter repository: The update editor repository
    /// - Parameter model: The update model
    init(repository: UpdateEditorRepository,
         model: UpdateObservedModel) {
        self.repository = repository
        self.model = model
    }

    /// The view body
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                Text("Downloading Aurora Editor 1.0")
                    .font(.system(size: 12, weight: .medium))

                ProgressView(value: downloadProgress, total: 1)
                    .progressViewStyle(.linear)

                Text(etaProgress)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
        }
        .padding(5)
        .onAppear(perform: {
            guard let updateModelJson = model.updateModelJson else {
                DispatchQueue.main.async {
                    model.updateState = .error
                }
                return
            }

            repository.downloadUpdateFile(downloadURL: updateModelJson.url) { progress, eta  in
                downloadProgress = progress
                etaProgress = eta ?? "Unknown Size and Time of Completion"
            }

            repository.setBackgroundCompletionHandler {
                DispatchQueue.main.async {
                    model.updateState = .updateReady
                }
            }
        })
    }
}
