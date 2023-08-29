//
//  GitlabLoginView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct GitlabLoginView: View {

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
            Text("settings.gitlab.login.header")

            VStack(alignment: .trailing) {
                HStack {
                    Text("settings.global.login.account")
                    TextField("Enter your username", text: $accountName)
                        .frame(width: 300)
                }
                HStack {
                    Text("settings.global.login.token")
                    SecureField("settings.gitlab.login.enter.token",
                                text: $accountToken)
                    .frame(width: 300)
                }
            }

            HStack {
                HStack {
                    Button {
                        createToken(URL(string: "https://gitlab.com/-/profile/personal_access_tokens")!)
                    } label: {
                        Text("settings.gitlab.login.create")
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
                            accountModel.loginGitlab(gitAccountName: accountName,
                                                     accountToken: accountToken,
                                                     accountName: accountName)
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
        .frame(width: 485, height: 160)
    }
}
