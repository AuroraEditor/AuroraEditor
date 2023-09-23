//
//  GithubLoginView.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/04/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct GithubLoginView: View {

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
            Text("settings.github.login.header")

            VStack(alignment: .trailing) {
                HStack {
                    Text("settings.global.login.account")
                    TextField("settings.global.login.username", text: $accountName)
                        .frame(width: 300)
                }
                HStack {
                    Text("settings.global.login.token")
                    SecureField("settings.github.login.enter.token.personal",
                                text: $accountToken)
                    .frame(width: 300)
                }
            }

            GroupBox {
                VStack {
                    Text("settings.github.login.access.scopes")
                        .fontWeight(.bold)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.secondary)
                            Text("settings.github.login.access.public.key")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.secondary)
                            Text("settings.github.login.access.discussion")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.secondary)
                            Text("settings.github.login.access.repo")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.secondary)
                            Text("settings.github.login.access.user")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 2)
                }
                .padding(.vertical, 5)
                .frame(width: 455)
            }

            HStack {
                HStack {
                    Button {
                        createToken(URL(string: "https://github.com/settings/tokens/new")!)
                    } label: {
                        Text("settings.github.login.create")
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button {
                        dismissDialog.toggle()
                    } label: {
                        Text("global.cancel")
                            .foregroundColor(.primary)
                    }

                    if accountToken.isEmpty {
                        Button("settings.global.login") {}
                        .disabled(true)
                    } else {
                        Button {
                            accountModel.loginGithub(gitAccountName: accountName,
                                                     accountToken: accountToken,
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
        .frame(width: 485, height: 280)
    }
}
