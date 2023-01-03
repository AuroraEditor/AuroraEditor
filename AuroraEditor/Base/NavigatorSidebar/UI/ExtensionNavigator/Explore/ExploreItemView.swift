//
//  ExploreItemView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/10/29.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ExploreItemView: View {

    @State
    var extensionData: Plugin

    @State
    var extensionsModel: ExtensionInstallationViewModel

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "\(extensionData.extensionImage)")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .cornerRadius(8)
                } else if phase.error != nil {
                    Image(systemName: "lasso")
                        .frame(width: 36, height: 36)
                        .background(.blue)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "lasso")
                        .frame(width: 36, height: 36)
                        .background(.blue)
                        .cornerRadius(8)
                }
            }

            VStack(alignment: .leading) {
                Text(extensionData.extensionName)
                    .font(.system(size: 13))
                    .fontWeight(.medium)

                Text(extensionData.extensionDescription)
                    .font(.system(size: 11))
                    .truncationMode(.tail)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(minWidth: 87)

            Button {
                extensionsModel.downloadExtension(extensionId: extensionData.id.uuidString)
            } label: {
                Text("GET")
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.bordered)
            .cornerRadius(40)
        }
    }
}
