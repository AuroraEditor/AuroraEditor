//
//  ExtensionView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/11/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Extension view.
struct ExtensionView: View {

    /// Extension data
    @State
    var extensionData: Plugin

    /// The view body.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ExtensionHeaderView(extensionInfo: extensionData)
//                Divider()
//                    .padding(.vertical)
//                ExtensionWhatsNewView()
                Divider()
                    .padding(.vertical)
                ExtensionDescriptionView(extensionInfo: extensionData)
                Divider()
                    .padding(.vertical)
                ExtensionPrivacyView()
                Divider()
                    .padding(.vertical)
                ExtensionInformationView(extensionInfo: extensionData)
            }
            .padding()
        }
    }
}
