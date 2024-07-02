//
//  GitlabLoginView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The login view for Gitlab
struct GitlabLoginView: View {
    /// The account name
    @State
    var accountName = ""

    /// The account token
    @State
    var accountToken = ""

    /// The open URL environment
    @Environment(\.openURL)
    var createToken

    /// Dismiss dialog
    @Binding
    var dismissDialog: Bool

    /// The account model
    @ObservedObject
    var accountModel: EditorAccountModel

    /// Login successful callback
    var loginSuccessfulCallback: EditorAccountModel.LoginSuccessfulCallback

    /// Initializes the Gitlab login view
    /// 
    /// - Parameter dismissDialog: Dismiss dialog
    /// - Parameter loginSuccessfulCallback: Login successful callback
    init(dismissDialog: Binding<Bool>, loginSuccessfulCallback: @escaping EditorAccountModel.LoginSuccessfulCallback) {
        self._dismissDialog = dismissDialog
        self.accountModel = .init(dismissDialog: dismissDialog.wrappedValue)
        self.loginSuccessfulCallback = loginSuccessfulCallback
    }

    /// The view body
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
                        createToken(URL( "https://gitlab.com/-/profile/personal_access_tokens"))
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
                                                     accountName: accountName, successCallback: loginSuccessfulCallback)
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
        .frame(width: 485, height: 160)
    }
}
