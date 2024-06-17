//
//  GitAccountItem.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/04/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The Git account item
struct GitAccountItem: View {
    /// The source control account
    @Binding
    var sourceControlAccount: SourceControlAccounts

    /// The view body
    var body: some View {
        HStack {
            Image(symbol: "vault.fill")
                .resizable()
                .frame(width: 24.0, height: 24.0)
                .accessibilityLabel(Text("Source Control Account Icon"))

            VStack(alignment: .leading) {
                Text(sourceControlAccount.gitProvider)
                    .font(.system(size: 12))
                Text(sourceControlAccount.gitProviderLink)
                    .font(.system(size: 10))
            }
        }
    }
}
