//
//  UpdatePreferencesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/23.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct UpdatePreferencesView: View {

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @ObservedObject
    private var updateModel: UpdateObservedModel = .shared

    @State
    private var openUpdateSettings: Bool = false

    private var appVersion: String {
        Bundle.versionString ?? "No Version"
    }

    private var commitHash: String {
        Bundle.commitHash ?? "No Hash"
    }

    private var shortCommitHash: String {
        if commitHash.count > 7 {
            return String(commitHash[...commitHash.index(commitHash.startIndex, offsetBy: 7)])
        }
        return commitHash
    }

    var body: some View {
        PreferencesContent {
            VStack {
                GroupBox {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Automatic Updates")
                                .font(.system(size: 12, weight: .medium))
                            Spacer()
                            Text(automaticUpdates())
                                .foregroundColor(.secondary)
                                .font(.system(size: 12, weight: .medium))
                            Button {
                                openUpdateSettings.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .buttonStyle(.plain)
                            .sheet(isPresented: $openUpdateSettings) {
                                AutomaticallyUpdateSheet()
                            }
                        }
                        Text("This IDE is currently enrolled in the \(updateChannelDescription()) Build Programme")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.vertical, -4)

                        Link("Learn more...",
                             destination: URL(string: "https://auroraeditor.com")!)
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                    }
                    .padding(5)
                }
                .padding(5)

                switch updateModel.updateState {
                case .loading:
                    checkingForUpdates()
                case .success:
                    checkForUpdates()
                case .updateFound:
                    updateAvailable()
                case .error:
                    updateError()
                }

                // swiftlint:disable:next line_length
                Text("Use of this software is subject to the original license agreement that accompanied the software being updated.")
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(5)
            }
        }
        .onAppear {
            // We disable checking for updates in debug builds as to not
            // annoy our fellow contributers
            #if !DEBUG
            updateModel.checkForUpdates()
            #endif
        }
    }

    func checkForUpdates() -> some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    Text("Check for Updates")
                        .font(.system(size: 12, weight: .medium))
                    Spacer()
                    Button {
                        prefs.preferences.updates.lastChecked = Date()
                        updateModel.checkForUpdates()
                    } label: {
                        Text("Check Now")
                    }
                }

                Text("Aurora Editor \(appVersion) (\(shortCommitHash))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
                    .padding(.bottom, -2)

                // swiftlint:disable:next line_length
                Text("Last Checked: \(prefs.preferences.updates.lastChecked.formatted(date: .complete, time: .standard)) ")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.bottom, -2)

                Text("Aurora Editor is up to date")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 5)

            }
            .padding(5)
        }
        .padding(5)
    }

    func checkingForUpdates() -> some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    Text("Checking for Updates...")
                        .font(.system(size: 12, weight: .medium))
                    Spacer()

                    ProgressView()
                        .progressViewStyle(.linear)
                        .frame(width: 100)

                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
        }
        .padding(5)
    }

    func updateAvailable() -> some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Update Available")
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                        Button {

                        } label: {
                            Text("Update Now")
                        }
                    }

                    HStack {
                        Text("* Aurora Editor Nightly Build")
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("10MB")
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    Text("More Info...")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                        .padding(.vertical, 5)

                }
                .padding(5)
            }
            .padding(5)
        }
    }

    func updateError() -> some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Failure checking for Updates...")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.red)
                        Spacer()
                        Button {
                            prefs.preferences.updates.lastChecked = Date()
                            updateModel.checkForUpdates()
                        } label: {
                            Text("Retry Again")
                        }
                    }

                }
                .padding(5)
            }
            .padding(5)
        }
    }

    func updateChannelDescription() -> String {
        switch prefs.preferences.updates.updateChannel {
        case .release:
            return "Release"
        case .beta:
            return "Beta"
        case .nightly:
            return "Nightly"
        }
    }

    func automaticUpdates() -> String {
        if prefs.preferences.updates.checkForUpdates {
            return "On"
        } else {
            return "Off"
        }
    }
}

struct UpdatePreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatePreferencesView()
    }
}
