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
        Providers(name: "Bitbucket Cloud", icon: "bitbucket", id: "bitbucketCloud"),
        Providers(name: "Bitbucket Server", icon: "bitbucket", id: "bitbucketServer"),
        Providers(name: "GitHub", icon: "github", id: "github"),
        Providers(name: "GitHub Enterprise", icon: "github", id: "githubEnterprise"),
        Providers(name: "GitLab", icon: "gitlab", id: "gitlab"),
        Providers(name: "GitLab Self-Hosted", icon: "gitlab", id: "gitlabSelfHosted")
    ]

    @State var providerSelection: Providers.ID? = "github"

    @State
    var openGitLogin = false

    var body: some View {
        VStack {
            Text("Select the type of account you would like to add:")
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
                    Text("Cancel")
                        .foregroundColor(.primary)
                }

                Button {
                    openGitLogin.toggle()
                } label: {
                    Text("Continue")
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
            AuroraEditorLoginView(dismissDialog: $openGitLogin)
        case "bitbucketCloud":
            implementationNeeded
        case "bitbucketServer":
            implementationNeeded
        case "github":
            GithubLoginView(dismissDialog: $openGitLogin)
        case "githubEnterprise":
            GithubEnterpriseLoginView(dismissDialog: $openGitLogin)
        case "gitlab":
            GitlabLoginView(dismissDialog: $openGitLogin)
        case "gitlabSelfHosted":
            GitlabHostedLoginView(dismissDialog: $openGitLogin)
        default:
            implementationNeeded
        }
    }

    private var implementationNeeded: some View {
        VStack {
            Text("This git client is currently not supported yet!")
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
