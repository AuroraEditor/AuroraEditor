//
//  PreferencesView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents the preferences view.
struct PreferencesView: View {
    /// The view model
    @StateObject
    var viewModel = SettingsModel()

    /// The view body
    var body: some View {
        ZStack {
            Button("CLOSE WINDOW") {
                closeWindow()
            }
            .frame(width: 0, height: 0)
            .padding(0)
            .opacity(0)
            .keyboardShortcut("w", modifiers: [.command])
            NavigationView {
                List {
                    ForEach(viewModel.setting) { item in
                        NavigationLink(destination: settingContentView,
                                       tag: item.id,
                                       selection: $viewModel.selectedId) {
                            HStack {
                                if let image = item.image {
                                    Image(nsImage: image)
                                        .imageScale(.small)
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 23, height: 23)
                                        .accessibilityLabel(Text("Setting Icon"))
                                        .background {
                                            LinearGradient(gradient: Gradient(colors: [item.colorStart, item.colorEnd]),
                                                           startPoint: .top,
                                                           endPoint: .bottom)
                                            .opacity(0.85)
                                        }
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 5
                                            )
                                        )
                                }

                                Text(item.name)
                            }
                        }
                    }
                }
                .frame(minWidth: 160, idealWidth: 170, maxWidth: 180)
                .listStyle(.sidebar)

                Text("No selection")
            }
            .frame(
                minWidth: 760,
                maxWidth: .infinity,
                minHeight: 500,
                maxHeight: .infinity
            )
        }
    }

    /// The setting content view
    var settingContentView: some View {
        ScrollView {
            if viewModel.selectedId == viewModel.setting[0].id {
                // General
                GeneralPreferencesView()
            } else if viewModel.selectedId == viewModel.setting[1].id {
                // Accounts
                PreferenceAccountsView()
            } else if viewModel.selectedId == viewModel.setting[2].id {
                // Notifications
                NotificationPreferencesView()
            } else if viewModel.selectedId == viewModel.setting[3].id {
                // Behaviors
                PreferencesPlaceholderView()
            } else if viewModel.selectedId == viewModel.setting[4].id {
                // Navigation
                PreferencesPlaceholderView()
            } else if viewModel.selectedId == viewModel.setting[5].id {
                // Themes
                ThemePreferencesView()
            } else if viewModel.selectedId == viewModel.setting[6].id {
                // Text Editing
                TextEditingPreferencesView()
            } else if viewModel.selectedId == viewModel.setting[7].id {
                // Terminal
                TerminalPreferencesView()
            } else if viewModel.selectedId == viewModel.setting[8].id {
                // Key Bindings
                PreferencesPlaceholderView()
            } else if viewModel.selectedId == viewModel.setting[9].id {
                // Source Control
                PreferenceSourceControlView()
            } else if viewModel.selectedId == viewModel.setting[10].id {
                // Components
                PreferencesPlaceholderView()
            } else if viewModel.selectedId == viewModel.setting[11].id {
                // Advanced
                PreferencesPlaceholderView()
            } else if viewModel.selectedId == viewModel.setting[12].id {
                // Update
                UpdatePreferencesView()
            }
        }
        .frame(minWidth: 560, idealWidth: 580, maxWidth: 600)
    }

    /// Close the preferences window
    public func closeWindow() {
        PreferencesWindowController(view: self).closeWindow()
    }

    /// Show the preferences window
    public func showWindow() {
        PreferencesWindowController(view: self).showWindow(nil)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
