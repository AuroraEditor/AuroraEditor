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

    @Binding var dismissDialog: Bool

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    private let keychain = AuroraEditorKeychain()

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
                            loginGitlabSelfHosted(gitAccountName: accountName)
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

    private func loginGitlabSelfHosted(gitAccountName: String) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GitlabTokenConfiguration(accountToken,
                                              url: eneterpriseLink )
        GitlabAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    Log.warning("Account with the username already exists!")
                } else {
                    Log.info(user)
                    prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                        SourceControlAccounts(id: gitAccountName.lowercased(),
                                              gitProvider: "Gitlab",
                                              gitProviderLink: eneterpriseLink,
                                              gitProviderDescription: "Gitlab",
                                              gitAccountName: gitAccountName,
                                              gitAccountEmail: "user.email!",
                                              gitAccountUsername: "user.username",
                                              gitAccountImage: "user.avatarURL?.relativeString!",
                                              gitCloningProtocol: true,
                                              gitSSHKey: "",
                                              isTokenValid: true))
                    keychain.set(accountToken, forKey: "gitlab_\(gitAccountName)_hosted")
                    dismissDialog = false
                }
            case .failure(let error):
                Log.error(error)
            }
        }
    }
}
