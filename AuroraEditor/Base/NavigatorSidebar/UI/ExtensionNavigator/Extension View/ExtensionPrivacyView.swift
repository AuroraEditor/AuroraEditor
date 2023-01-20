//
//  ExtensionPrivacyView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/11/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct ExtensionPrivacyView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Extension Privacy")
                    .font(.title)
                    .fontWeight(.medium)

                Spacer()

                Text("See Details")
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
            }
            // swiftlint:disable:next line_length
            Text("The extension developer, **Nanashi Li**, indicated that the extensions privacy practices may include handling of data as described below. For more information, see the [extension developer's privacy policy](https://auroraeditor.com).")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 5)

            // swiftlint:disable:next line_length
            Text("Extension privacy practices may vary based, for example, on the feature being used or editor usage. [Learn More](https://auroraeditor.com)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
    }
}

struct ExtensionPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        ExtensionPrivacyView()
    }
}
