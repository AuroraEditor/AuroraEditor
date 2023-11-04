//
//  AccountSelectionDialog.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/04/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct AccountSelectionDialog: View {

    @Environment(\.dismiss)
    private var dismiss

    var gitProviders = [
        Providers(name: "Aurora Editor", icon: "person.crop.circle", id: "auroraEditor"),
        Providers(name: "settings.account.bitbucket.cloud".localize(),
                  icon: "bitbucket",
                  id: "bitbucketCloud"),
        Providers(name: "settings.account.bitbucket.server".localize(),
                  icon: "bitbucket",
                  id: "bitbucketServer"),
        Providers(name: "settings.account.github".localize(),
                  icon: "github",
                  id: "github"),
        Providers(name: "settings.account.github.enterprise".localize(),
                  icon: "github",
                  id: "githubEnterprise"),
        Providers(name: "settings.account.gitlab".localize(),
                  icon: "gitlab",
                  id: "gitlab"),
        Providers(name: "settings.account.gitlab.hosted".localize(),
                  icon: "gitlab",
                  id: "gitlabSelfHosted")
    ]

    @State var providerSelection: Providers.ID? = "github"

    @State
    var openGitLogin = false

    var body: some View {
        VStack {
            Text("settings.account.account.type")
                .font(.system(size: 12))

            List(gitProviders, selection: $providerSelection) {
                AccountListItem(gitClientName: $0.name,
                                gitClientSymbol: $0.icon,
                                clientId: $0.id)
            }
            .background(Color(NSColor.controlBackgroundColor))
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))

            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("global.cancel")
                        .foregroundColor(.primary)
                }

                Button {
                    openGitLogin.toggle()
                } label: {
                    Text("global.continue")
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $openGitLogin, content: {
                    openAccountLoginDialog
                })
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .frame(width: 400, height: 285)
    }

    @ViewBuilder
    private var openAccountLoginDialog: some View {
        switch providerSelection {
        case "auroraEditor":
            AuroraEditorLoginView(dismissDialog: $openGitLogin, loginSuccessfulCallback: dismissView)
        case "bitbucketCloud":
            implementationNeeded
        case "bitbucketServer":
            implementationNeeded
        case "github":
            GithubLoginView(dismissDialog: $openGitLogin, loginSuccessfulCallback: dismissView)
        case "githubEnterprise":
            GithubEnterpriseLoginView(dismissDialog: $openGitLogin, loginSuccessfulCallback: dismissView)
        case "gitlab":
            GitlabLoginView(dismissDialog: $openGitLogin, loginSuccessfulCallback: dismissView)
        case "gitlabSelfHosted":
            GitlabHostedLoginView(dismissDialog: $openGitLogin, loginSuccessfulCallback: dismissView)
        default:
            implementationNeeded
        }
    }

    private func dismissView() {
        self.dismiss()
    }

    private var implementationNeeded: some View {
        VStack {
            Text("settings.account.client.not.supported")
                .font(.system(size: 12))
            HStack {
                Button("Close") {
                    openGitLogin.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 20)
        }
        .padding(20)
        .frame(width: 300, height: 120)
    }

}
