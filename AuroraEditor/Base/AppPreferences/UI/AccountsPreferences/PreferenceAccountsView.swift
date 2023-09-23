//
//  PreferenceAccountsView.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/04/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
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
                Text("settings.account.no.account")
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            } else {
                List($prefs.preferences.accounts.sourceControlAccounts.gitAccount) { account in
                    AccountItemView(account: account, onDeleteCallback: removeSourceControlAccount)
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
                    Text("settings.account.add")
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $openAccountDialog) {
                    AccountSelectionDialog()
                }
            }
        }
    }

    func removeSourceControlAccount(selectedAccountId: String) {
        var gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        for account in gitAccounts where account.id == selectedAccountId {
            let index = gitAccounts.firstIndex(of: account)
            gitAccounts.remove(at: index ?? 0)
        }
        
        prefs.preferences.accounts.sourceControlAccounts.gitAccount = gitAccounts
    }
}

struct PreferenceAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceAccountsView()
    }
}
