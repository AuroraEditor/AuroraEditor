//
//  GithubEnterpriseLoginView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct GithubEnterpriseLoginView: View {

    @State var eneterpriseLink = ""
    @State var accountName = ""
    @State var accountToken = ""

    @Environment(\.openURL) var createToken

    @Binding
    var dismissDialog: Bool

    @ObservedObject
    var accountModel: EditorAccountModel
    var loginSuccessfulCallback: EditorAccountModel.LoginSuccessfulCallback

    init(dismissDialog: Binding<Bool>, loginSuccessfulCallback: @escaping EditorAccountModel.LoginSuccessfulCallback) {
        self._dismissDialog = dismissDialog
        self.accountModel = .init(dismissDialog: dismissDialog.wrappedValue)
        self.loginSuccessfulCallback = loginSuccessfulCallback
    }

    var body: some View {
        VStack {
            Text("settings.github.enterprise.login.header")

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
                    SecureField("settings.github.enterprise.login.enter.token",
                                text: $accountToken)
                    .frame(width: 300)
                }
            }

            HStack {
                HStack {
                    Button {
                        createToken(URL(string: "https://github.com/settings/tokens/new")!)
                    } label: {
                        Text("settings.github.enterprise.login.create")
                            .foregroundColor(.primary)
                            .lineLimit(1)
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
                            accountModel.loginGithubEnterprise(gitAccountName: accountName,
                                                               accountToken: accountToken,
                                                               accountName: accountName,
                                                               enterpriseLink: eneterpriseLink,
                                                               successCallback: loginSuccessfulCallback)
                            self.dismissDialog = accountModel.dismissDialog
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
        .frame(width: 525, height: 190)
    }
}
