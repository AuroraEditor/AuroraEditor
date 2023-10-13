//
//  UpdateInProgressState.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/03.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct UpdateInProgressState: View {

    @State
    private var repository: UpdateEditorRepository

    @State
    private var downloadProgress: Double = 0.0

    @State
    private var etaProgress: String = ""

    @State
    private var model: UpdateObservedModel

    init(repository: UpdateEditorRepository,
         model: UpdateObservedModel) {
        self.repository = repository
        self.model = model
    }

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
            repository.downloadUpdateFile(downloadURL: model.updateModelJson!.url) { progress, eta  in
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
