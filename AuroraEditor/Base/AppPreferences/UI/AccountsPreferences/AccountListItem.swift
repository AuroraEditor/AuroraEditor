//
//  AccountListItem.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/04/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The account list item
struct AccountListItem: View {
    /// The git client name
    var gitClientName: String

    /// The git client symbol
    var gitClientSymbol: String

    /// The client ID
    var clientId: String

    /// The view body
    var body: some View {
        HStack {
            if clientId == "auroraEditor" {
                Image(systemName: gitClientSymbol)
                    .resizable()
                    .frame(width: 28.0, height: 28.0)
            } else {
                Image(gitClientSymbol)
                    .resizable()
                    .frame(width: 28.0, height: 28.0)
            }
            Text(gitClientName)
                .font(.system(size: 12))
        }
    }
}
