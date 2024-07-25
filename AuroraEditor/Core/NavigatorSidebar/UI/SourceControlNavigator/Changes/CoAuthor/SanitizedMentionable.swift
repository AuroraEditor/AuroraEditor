//
//  SanitizedMentionable.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/16.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct SanitizedMentionable: View {
    let suggestion: IAPIMentionableUser

    var body: some View {
        Group {
            if suggestion.name == nil {
                Text(suggestion.login)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .cornerRadius(5)
            } else {
                HStack(alignment: .center) {
                    Text(suggestion.name ?? "")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.leading)
                        .padding(.trailing, 0)
                        .padding(.vertical, 5)
                        .cornerRadius(5)

                    Text("(\(suggestion.login))")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 0)
                        .padding(.vertical, 5)
                        .cornerRadius(5)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
