//
//  AutomaticallyUpdateSheet.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/23.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct AutomaticallyUpdateSheet: View {

    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject
    var prefs: AppPreferencesModel = .shared

    var body: some View {
        VStack(alignment: .leading) {
            Text("Automatically")
                .font(.system(size: 11, weight: .bold))

            GroupBox {
                HStack {
                    Text("Check for updates")
                        .font(.system(size: 11))
                    Spacer()
                    Toggle("", isOn: $prefs.preferences.updates.checkForUpdates)
                        .onChange(of: prefs.preferences.updates.checkForUpdates, perform: { _ in
                            prefs.preferences.updates.downloadUpdatesWhenAvailable = false
                        })
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
                .padding(.horizontal, 5)

                Divider()

                HStack {
                    Text("Download new updates when available")
                        .font(.system(size: 11))
                    Spacer()
                    Toggle("", isOn: $prefs.preferences.updates.downloadUpdatesWhenAvailable)
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
                .padding(.horizontal, 5)
                .disabled(!prefs.preferences.updates.checkForUpdates)

                Divider()

                HStack {
                    Text("Update Channel")
                        .font(.system(size: 11))
                    Spacer()
                    Picker("", selection: $prefs.preferences.updates.updateChannel) {
                        Text("Release")
                            .font(.system(size: 11))
                            .tag(AppPreferences.UpdateChannel.release)
                        Text("Beta")
                            .font(.system(size: 11))
                            .tag(AppPreferences.UpdateChannel.beta)
                        Text("Nightly")
                            .font(.system(size: 11))
                            .tag(AppPreferences.UpdateChannel.nightly)
                    }
                    .labelsHidden()
                    .frame(width: 80)
                }
                .padding(.bottom, 5)
                .padding(.horizontal, 5)
                .disabled(!prefs.preferences.updates.checkForUpdates)

            }

            Divider()
                .padding(.top)
                .padding(.bottom, 10)
                .padding(.horizontal, -15)

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 415)
    }
}

struct AutomaticallyUpdateSheet_Previews: PreviewProvider {
    static var previews: some View {
        AutomaticallyUpdateSheet()
    }
}
