//
//  AccountItemView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct AccountItemView: View {

    @Environment(\.openURL)
    var openGithubProfile

    @Binding
    var account: SourceControlAccounts

    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    AsyncImage(url: URL(string: account.gitAccountImage)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 42, height: 42)
                        } else if phase.error != nil {
                            defaultAvatar
                        } else {
                            defaultAvatar
                        }
                    }

                    Text(account.gitAccountName)
                        .foregroundColor(.primary)

                    Spacer()

                    Button {
                        openGithubProfile(URL(string: "\(account.gitProviderLink)/\(account.gitAccountUsername)")!)
                    } label: {
                        Text("Show Profile...")
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 5)
                .padding(.horizontal, 10)

                Divider()

                HStack {
                    Text("Username")

                    Spacer()

                    Text(account.gitAccountUsername)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)

                Divider()

                Text("Your username is public and will represent you in \(account.gitProvider)")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                    .padding(6)
                    .padding(.horizontal, 5)
            }
        }
    }

    private var defaultAvatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .foregroundColor(.gray)
            .frame(width: 42, height: 42)
    }
}
