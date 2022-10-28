//
//  GitlabHostedLoginView.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Nanashi Li on 2022/04/21.
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
            Text("Sign in to your Gitlab account")

            VStack(alignment: .trailing) {
                HStack {
                    Text("Server:")
                    TextField("https://example.com", text: $eneterpriseLink)
                        .frame(width: 300)
                }
                HStack {
                    Text("Account:")
                    TextField("", text: $accountName)
                        .frame(width: 300)
                }
                HStack {
                    Text("Token:")
                    SecureField("Enter your Personal Access Token",
                                text: $accountToken)
                    .frame(width: 300)
                }
            }

            HStack {
                HStack {
                    Button {
                        createToken(URL(string: "https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html")!)
                    } label: {
                        Text("Create a Token on Gitlab Self-Hosted")
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button {
                        dismissDialog = false
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.primary)
                    }

                    if accountToken.isEmpty {
                        Button("Sign In") {}
                        .disabled(true)
                    } else {
                        Button {
                            accountModel.loginGitlabSelfHosted(gitAccountName: accountName,
                                                               accountToken: accountToken,
                                                               enterpriseLink: eneterpriseLink)
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
        .frame(width: 545, height: 190)
    }
}
