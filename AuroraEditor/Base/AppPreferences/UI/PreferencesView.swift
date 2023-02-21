//
//  PreferencesView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {

    @StateObject
    var viewModel = SettingsModel()

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
                                Image(nsImage: item.image)
                                    .imageScale(.small)
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 23, height: 23)
                                    .background {
                                        LinearGradient(gradient: Gradient(colors: [item.colorStart, item.colorEnd]),
                                                       startPoint: .top,
                                                       endPoint: .bottom)
                                        .opacity(0.85)
                                    }
                                    .cornerRadius(5)
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

    var settingContentView: some View {
            ScrollView {
                if viewModel.selectedId == viewModel.setting[0].id {
                    GeneralPreferencesView()        // General
                } else if viewModel.selectedId == viewModel.setting[1].id {
                    PreferenceAccountsView()        // Accounts
                } else if viewModel.selectedId == viewModel.setting[2].id {
                    PreferencesPlaceholderView()    // Behaviors
                } else if viewModel.selectedId == viewModel.setting[3].id {
                    PreferencesPlaceholderView()    // Navigation
                } else if viewModel.selectedId == viewModel.setting[4].id {
                    ThemePreferencesView()          // Themes
                } else if viewModel.selectedId == viewModel.setting[5].id {
                    TextEditingPreferencesView()    // Text Editing
                } else if viewModel.selectedId == viewModel.setting[6].id {
                    TerminalPreferencesView()       // Terminal
                } else if viewModel.selectedId == viewModel.setting[7].id {
                    PreferencesPlaceholderView()    // Key Bindings
                } else if viewModel.selectedId == viewModel.setting[8].id {
                    PreferenceSourceControlView()   // Source Control
                } else if viewModel.selectedId == viewModel.setting[9].id {
                    PreferencesPlaceholderView()    // Components
                } else if viewModel.selectedId == viewModel.setting[10].id {
                    PreferencesPlaceholderView()    // Advanced
                } else if viewModel.selectedId == viewModel.setting[11].id {
                    UpdatePreferencesView()
                }
            }
            .frame(minWidth: 560, idealWidth: 580, maxWidth: 600)
    }

    public func closeWindow() {
        PreferencesWindowController(view: self).closeWindow()
    }

    public func showWindow() {
        PreferencesWindowController(view: self).showWindow(nil)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
