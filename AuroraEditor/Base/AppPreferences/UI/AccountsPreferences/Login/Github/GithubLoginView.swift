//
//  GithubLoginView.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct GithubLoginView: View {

    @State var accountName = ""
    @State var accountToken = ""

    @Environment(\.openURL) var createToken

    private let keychain = AuroraEditorKeychain()

    @Binding var dismissDialog: Bool

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        VStack {
            Text("Sign in to your GitHub account")

            VStack(alignment: .trailing) {
                HStack {
                    Text("Account:")
                    TextField("Enter your username", text: $accountName)
                        .frame(width: 300)
                }
                HStack {
                    Text("Token:")
                    SecureField("Enter your Personal Access Token",
                                text: $accountToken)
                    .frame(width: 300)
                }
            }

            GroupBox {
                VStack {
                    Text("GitHub personal access tokens must have these scopes set:")
                        .fontWeight(.bold)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.secondary)
                            Text("admin:public_key")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.secondary)
                            Text("write:discussion")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.secondary)
                            Text("repo")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.secondary)
                            Text("user")
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
                        Text("Create a Token on GitHub")
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

                    if accountToken.isEmpty {
                        Button("Sign In") {}
                        .disabled(true)
                    } else {
                        Button {
                            loginGithub(gitAccountName: accountName)
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
        .frame(width: 485, height: 280)
    }

    private func loginGithub(gitAccountName: String) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GithubTokenConfiguration(accountToken)
        GithubAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    Log.warning("Account with the username already exists!")
                } else {
                    Log.info(user)
                    DispatchQueue.main.async {
                        prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                            SourceControlAccounts(id: gitAccountName.lowercased(),
                                                  gitProvider: "GitHub",
                                                  gitProviderLink: "https://github.com",
                                                  gitProviderDescription: "GitHub",
                                                  gitAccountName: gitAccountName,
                                                  gitAccountEmail: user.email ?? "Not Found",
                                                  gitAccountUsername: user.login!,
                                                  gitAccountImage: user.avatarURL!,
                                                  gitCloningProtocol: true,
                                                  gitSSHKey: "",
                                                  isTokenValid: true))
                        keychain.set(accountToken, forKey: "github_\(accountName)")
                    }
                    dismissDialog.toggle()
                }
            case .failure(let error):
                Log.error(error)
            }
        }
    }
}
