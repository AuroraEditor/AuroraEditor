//
//  PreferenceAccountsView.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/04/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The preference accounts view
public struct PreferenceAccountsView: View {
    /// The open account dialog
    @State
    private var openAccountDialog = false

    /// The preferences model
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var accounts: [AccountPreferences] = []

    /// Initializes the preference accounts view
    public init() {
        _accounts = State(initialValue: AccountPreferences.fetchAll())
    }

    /// The view body
    public var body: some View {
        PreferencesContent {
            if accounts.isEmpty {
                Text("settings.account.no.account")
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach($accounts) { account in
                        AccountItemView(account: account, onDeleteCallback: removeAccount)
                    }
                    .onDelete(perform: deleteAccount)
                }
                .frame(minHeight: 435)
                .padding(.horizontal, -10)
                .listStyle(PlainListStyle())
            }

            HStack {
                Spacer()
                Button {
                    openAccountDialog.toggle()
                } label: {
                    Text("settings.account.add")
                        .foregroundColor(.white)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .sheet(isPresented: $openAccountDialog) {
                    AccountSelectionDialog()
                }
            }
        }
    }

    /// Deletes the selected account
    ///
    /// - Parameter indexSet: The index set of the account to remove
    private func deleteAccount(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let account = accounts[index]
            AccountPreferences.delete(account)
            accounts.remove(at: index)
        }
    }

    /// Removes the source control account
    ///
    /// - Parameter selectedAccountId: The selected account ID
    private func removeAccount(selectedAccountId: String) {
        accounts.removeAll { $0.id == selectedAccountId }
    }
}

struct PreferenceAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceAccountsView()
    }
}
