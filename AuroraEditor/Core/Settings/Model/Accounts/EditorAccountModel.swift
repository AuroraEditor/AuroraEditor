//
//  EditorAccountModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/28.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import OSLog

/// A model to handle the editor account
@MainActor
class EditorAccountModel: ObservableObject {
    // swiftlint:disable:previous type_body_length
    /// The callback for a successful login
    typealias LoginSuccessfulCallback = () -> Void

    /// The preferences model
    private var prefs: AppPreferencesModel = .shared

    /// The keychain
    private let keychain = AuroraEditorKeychain()

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Editor Account Model")

    @Published
    /// A boolean to dismiss the dialog
    var dismissDialog: Bool

    /// Initializes a new editor account model
    init(dismissDialog: Bool) {
        self.dismissDialog = dismissDialog
    }

    /// Logs in to your Aurora Editor account
    /// 
    /// - Parameter email: email address
    /// - Parameter password: password
    /// - Parameter successCallback: the callback for a successful login
    func loginAuroraEditor(
        email: String,
        password: String,
        successCallback: @escaping LoginSuccessfulCallback
    ) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]

        AuroraNetworking().request(
            baseURL: Constants.auroraEditorBaseURL,
            path: Constants.login,
            useAuthType: .none,
            method: .POST,
            parameters: parameters,
            completionHandler: { completion in
                switch completion {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let login = try decoder.decode(AELogin.self, from: data)

                        DispatchQueue.main.async {
                            do {
                                try AccountPreferences.create(
                                    account: AccountPreferences(
                                        provider: "Aurora Editor",
                                        providerLink: "https://auroraeditor.com",
                                        providerDescription: "Official Aurora Editor Account",
                                        accountName: "\(login.user.firstName) \(login.user.lastName)",
                                        accountEmail: login.user.email,
                                        accountUsername: "",
                                        accountImage: login.user.profileImage,
                                        gitCloningProtocol: false,
                                        gitSSHKey: "",
                                        isTokenValid: true
                                    )
                                )

                                self.dismissDialog.toggle()
                                successCallback()
                            } catch {
                                self.logger.fault("Failed to add account")
                            }
                        }
                        self.keychain.set(login.accessToken, forKey: "auroraeditor_access_\(email)")
                        self.keychain.set(login.refreshToken, forKey: "auroraeditor_refresh_\(email)")
                    } catch {

                    }
                case .failure(let failure):
                    self.logger.fault("\(failure)")
                }
            })
    }

    /// Logs in to your Gitlab account
    /// 
    /// - Parameter gitAccountName: the name of the git account
    /// - Parameter accountToken: the token of the account
    /// - Parameter accountName: the name of the account
    /// - Parameter successCallback: the callback for a successful login
    func loginGitlab(gitAccountName: String,
                     accountToken: String,
                     accountName: String,
                     successCallback: @escaping LoginSuccessfulCallback) {
        var gitAccounts: [AccountPreferences] = []

        do {
            gitAccounts = try AccountPreferences.fetchAll()
        } catch {
            self.logger.fault("Failed to fetch accounts")
        }

        let config = GitlabTokenConfiguration(accountToken)
        GitlabAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.accountEmail == gitAccountName.lowercased() }) {
                    self.logger.warning("Account with the username already exists!")
                } else {
                    do {
                        try AccountPreferences.create(
                            account: AccountPreferences(
                                provider: "Gitlab",
                                providerLink: "https://gitlab.com",
                                providerDescription: "Gitlab",
                                accountName: gitAccountName,
                                accountEmail: "user.email",
                                accountUsername: "user.username",
                                accountImage: "user.avatarURL?.absoluteString!",
                                gitCloningProtocol: true,
                                gitSSHKey: "",
                                isTokenValid: true
                            )
                        )

                        self.keychain.set(accountToken, forKey: "gitlab_\(accountName)")
                        self.dismissDialog.toggle()
                        successCallback()
                    } catch {
                        self.logger.fault("Failed to add account")
                    }
                }
            case .failure(let error):
                self.logger.fault("\(error)")
            }
        }
    }

    /// Logs in to your self hosted Gitlab account
    ///
    /// - Parameter gitAccountName: the name of the git account
    /// - Parameter accountToken: the token of the account
    /// - Parameter enterpriseLink: the link to the enterprise
    /// - Parameter successCallback: the callback for a successful login
    func loginGitlabSelfHosted(
        gitAccountName: String,
        accountToken: String,
        enterpriseLink: String,
        successCallback: @escaping LoginSuccessfulCallback
    ) {
        var gitAccounts: [AccountPreferences] = []

        do {
            gitAccounts = try AccountPreferences.fetchAll()
        } catch {
            self.logger.fault("Failed to fetch accounts")
        }

        let config = GitlabTokenConfiguration(accountToken,
                                              url: enterpriseLink )
        GitlabAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.accountEmail == gitAccountName.lowercased() }) {
                    self.logger.warning("Account with the username already exists!")
                } else {
                    do {
                        try AccountPreferences.create(
                            account: AccountPreferences(
                                provider: "Gitlab",
                                providerLink: enterpriseLink,
                                providerDescription: "Gitlab",
                                accountName: gitAccountName,
                                accountEmail: "user.email",
                                accountUsername: "user.username",
                                accountImage: "user.avatarURL?.absoluteString!",
                                gitCloningProtocol: true,
                                gitSSHKey: "",
                                isTokenValid: true
                            )
                        )
                        self.keychain.set(accountToken, forKey: "gitlab_\(gitAccountName)_hosted")
                        self.dismissDialog.toggle()
                        successCallback()
                    } catch {
                        self.logger.fault("Failed to add account")
                    }
                }
            case .failure(let error):
                self.logger.fault("\(error)")
            }
        }
    }

    /// Logs in to your Github account
    /// 
    /// - Parameter gitAccountName: the name of the git account
    /// - Parameter accountToken: the token of the account
    /// - Parameter successCallback: the callback for a successful login
    func loginGithub(
        gitAccountName: String,
        accountToken: String,
        successCallback: @escaping LoginSuccessfulCallback
    ) {
        var gitAccounts: [AccountPreferences] = []

        do {
            gitAccounts = try AccountPreferences.fetchAll()
        } catch {
            self.logger.fault("Failed to fetch accounts")
        }

        let config = GithubTokenConfiguration(accountToken)
        GithubAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.accountEmail == gitAccountName.lowercased() }) {
                    self.logger.warning("Account with the username already exists!")
                } else {
                    DispatchQueue.main.async {
                        do {
                            guard let userLogin = user.login,
                                  let userAvatar = user.avatarURL else {
                                return
                            }

                            try AccountPreferences.create(
                                account: AccountPreferences(
                                    provider: "GitHub",
                                    providerLink: "https://github.com",
                                    providerDescription: "GitHub",
                                    accountName: gitAccountName,
                                    accountEmail: user.email ?? "Not Found",
                                    accountUsername: userLogin,
                                    accountImage: userAvatar,
                                    gitCloningProtocol: true,
                                    gitSSHKey: "",
                                    isTokenValid: true
                                )
                            )
                            self.keychain.set(accountToken, forKey: "gitlab_\(gitAccountName)_hosted")
                            self.dismissDialog.toggle()
                            successCallback()
                        } catch {
                            self.logger.fault("Failed to add account")
                        }
                    }
                }
            case .failure(let error):
                self.logger.fault("\(error)")
            }
        }
    }

    /// Logs in to your self hosted Github account
    /// 
    /// - Parameter gitAccountName: the name of the git account
    /// - Parameter accountToken: the token of the account
    /// - Parameter accountName: the name of the account
    /// - Parameter enterpriseLink: the link to the enterprise
    /// - Parameter successCallback: the callback for a successful login
    func loginGithubEnterprise(
        gitAccountName: String,
        accountToken: String,
        accountName: String,
        enterpriseLink: String,
        successCallback: @escaping LoginSuccessfulCallback
    ) {
        var gitAccounts: [AccountPreferences] = []

        do {
            gitAccounts = try AccountPreferences.fetchAll()
        } catch {
            self.logger.fault("Failed to fetch accounts")
        }

        let config = GithubTokenConfiguration(accountToken,
                                              url: enterpriseLink )
        GithubAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.accountEmail == gitAccountName.lowercased() }) {
                    self.logger.warning("Account with the username already exists!")
                } else {
                    do {
                        guard let userLogin = user.login,
                              let userAvatar = user.avatarURL else {
                            return
                        }

                        try AccountPreferences.create(
                            account: AccountPreferences(
                                provider: "GitHub",
                                providerLink: enterpriseLink,
                                providerDescription: "GitHub",
                                accountName: gitAccountName,
                                accountEmail: user.email ?? "Not Found",
                                accountUsername: userLogin,
                                accountImage: userAvatar,
                                gitCloningProtocol: true,
                                gitSSHKey: "",
                                isTokenValid: true
                            )
                        )
                        self.keychain.set(accountToken, forKey: "gitlab_\(gitAccountName)_hosted")
                        self.dismissDialog.toggle()
                        successCallback()
                    } catch {
                        self.logger.fault("Failed to add account")
                    }
                }
            case .failure(let error):
                self.logger.fault("\(error)")
            }
        }
    }
}
