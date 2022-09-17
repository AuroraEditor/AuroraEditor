//
//  ReRunJobSheetView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/17.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ReRunJobSheetView: View {

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var enableDebugging: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Re-Run Single Job")

            Text("A new attempt of this workflow will be started, including **build** and dependents.")
                .font(.system(size: 11))
                .padding(.vertical, 1)

            HStack {
                Toggle(isOn: $enableDebugging) {
                    Text("Enable debug logging")
                }
                .toggleStyle(.checkbox)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(.primary)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Re-Run Jobs")
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .padding()
    }
}

struct ReRunJobSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ReRunJobSheetView()
    }
}
