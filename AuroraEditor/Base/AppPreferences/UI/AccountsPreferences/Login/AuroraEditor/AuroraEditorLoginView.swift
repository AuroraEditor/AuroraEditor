//
//  Aurora EditorLoginView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/28.
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

    init(dismissDialog: Binding<Bool>) {
        self._dismissDialog = dismissDialog
        self.accountModel = .init(dismissDialog: dismissDialog.wrappedValue)
    }

    var body: some View {
        VStack {
            Text("Sign in to your Aurora Editor account")

            VStack(alignment: .trailing) {
                HStack {
                    Text("Account:")
                    TextField("Enter your email",
                              text: $email)
                    .frame(width: 300)
                }
                HStack {
                    Text("Password:")
                    SecureField("Enter your Password",
                                text: $password)
                    .frame(width: 300)
                }
            }

            HStack {
                HStack {
                    Button {
                        createAccount(URL(string: "https://auroraeditor.com/#/sign-up")!)
                    } label: {
                        Text("Create a Aurora Editor account")
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button {
                        dismissDialog.toggle()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.primary)
                    }
                    if email.isEmpty && password.isEmpty {
                        Button("Sign In") {}
                        .disabled(true)
                    } else {
                        Button {
                            accountModel.loginAuroraEditor(email: email,
                                                           password: password)
                        } label: {
                            Text("Sign In")
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
