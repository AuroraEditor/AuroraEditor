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
    @State
    private var cloneUsing = false
    @State
    var accountSelection: SourceControlAccounts.ID?

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    public var body: some View {
        PreferencesContent {
            VStack {
                List($prefs.preferences.accounts.sourceControlAccounts.gitAccount) { account in
                    AccountItemView(account: account)
                }
                .padding(.horizontal, -10)
                .listStyle(.plain)

                HStack {
                    Spacer()
                    Button {
                        openAccountDialog.toggle()
                    } label: {
                        Text("Add Account")
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $openAccountDialog) {
                        AccountSelectionDialog()
                    }
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
            .preferredColorScheme(.dark)
    }
}
