//
//  GitlabHostedLoginView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct GitlabHostedLoginView: View {
    @State var eneterpriseLink = ""
    @State var accountName = ""
    @State var accountToken = ""

    @Environment(\.openURL) var createToken

    @Binding
    var dismissDialog: Bool

    @ObservedObject
    var accountModel: EditorAccountModel

    init(dismissDialog: Binding<Bool>) {
        self._dismissDialog = dismissDialog
        self.accountModel = .init(dismissDialog: dismissDialog.wrappedValue)
    }

    var body: some View {
        VStack {
            Text("settings.gitlab.enterprise.login.header")

            VStack(alignment: .trailing) {
                HStack {
                    Text("settings.global.login.server")
                    TextField("https://example.com", text: $eneterpriseLink)
                        .frame(width: 300)
                }
                HStack {
                    Text("settings.global.login.account")
                    TextField("", text: $accountName)
                        .frame(width: 300)
                }
                HStack {
                    Text("settings.global.login.token")
                    SecureField("settings.gitlab.enterprise.login.enter.token",
                                text: $accountToken)
                    .frame(width: 300)
                }
            }

            HStack {
                HStack {
                    Button {
                        createToken(URL(string: "https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html")!)
                    } label: {
                        Text("settings.gitlab.enterprise.login.create")
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button {
                        dismissDialog = false
                    } label: {
                        Text("global.cancel")
                            .foregroundColor(.primary)
                    }

                    if accountToken.isEmpty {
                        Button("settings.global.login") {}
                        .disabled(true)
                    } else {
                        Button {
                            accountModel.loginGitlabSelfHosted(gitAccountName: accountName,
                                                               accountToken: accountToken,
                                                               enterpriseLink: eneterpriseLink)
                        } label: {
                            Text("settings.global.login")
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.top, 10)
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .frame(width: 545, height: 190)
    }
}
