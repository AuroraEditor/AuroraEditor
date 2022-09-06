//
//  PreferenceAccountsView.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

public struct PreferenceAccountsView: View {

    @State
    private var openAccountDialog = false

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    public var body: some View {
        PreferencesContent {
            if prefs.preferences.accounts.sourceControlAccounts.gitAccount.isEmpty {
                // swiftlint:disable:next line_length
                Text("Doesn't seem like you have a Git Account attached to Aurora Editor, press the \"Add Account\" button to a Git Account.")
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            } else {
                List($prefs.preferences.accounts.sourceControlAccounts.gitAccount) { account in
                    AccountItemView(account: account)
                }
                .frame(minHeight: 435)
                .padding(.horizontal, -10)
                .listStyle(.plain)
            }

            HStack {
                Spacer()
                Button {
                    openAccountDialog.toggle()
                } label: {
                    Text("Add Account")
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $openAccountDialog) {
                    AccountSelectionDialog()
                }
            }
        }
    }

    private func removeSourceControlAccount(selectedAccountId: String) {
        var gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        for account in gitAccounts where account.id == selectedAccountId {
            let index = gitAccounts.firstIndex(of: account)
            gitAccounts.remove(at: index ?? 0)
        }
    }
}

struct PreferenceAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceAccountsView()
    }
}
