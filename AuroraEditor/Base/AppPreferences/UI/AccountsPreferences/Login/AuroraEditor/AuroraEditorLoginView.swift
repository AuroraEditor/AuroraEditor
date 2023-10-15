//
//  Aurora EditorLoginView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/28.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct AuroraEditorLoginView: View {

    @State
    var email = ""
    @State
    var password = ""

    @Environment(\.openURL)
    var createAccount

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
            Text("settings.aurora.login.header")

            VStack(alignment: .trailing) {
                HStack {
                    Text("settings.global.login.account")
                    TextField("settings.aurora.login.email",
                              text: $email)
                    .frame(width: 300)
                }
                HStack {
                    Text("settings.global.login.password")
                    SecureField("settings.aurora.login.password",
                                text: $password)
                    .frame(width: 300)
                }
            }

            HStack {
                HStack {
                    Button {
                        createAccount(URL(string: "https://auroraeditor.com/#/sign-up")!)
                    } label: {
                        Text("settings.aurora.login.create")
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
                    if email.isEmpty && password.isEmpty {
                        Button("settings.global.login") {}
                        .disabled(true)
                    } else {
                        Button {
                            accountModel.loginAuroraEditor(email: email,
                                                           password: password, successCallback: loginSuccessfulCallback)
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
