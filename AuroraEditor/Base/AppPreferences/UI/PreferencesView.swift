//
//  PreferencesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/18.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {

    @StateObject
    var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.setting) { item in
                    NavigationLink(destination: settingContentView,
                                   tag: item.id,
                                   selection: $viewModel.selectedId) {
                        HStack {
                            ZStack(alignment: .center) {
                                item.colour
                                Image(nsImage: item.image)
                                    .imageScale(.small)
                                    .scaledToFit()
                            }
                            .cornerRadius(5)
                            .frame(width: 23, height: 23)
                            Text(item.name)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            Text("No selection")
        }
        .frame(width: 760, height: 500)
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
                LocationsPreferencesView()      // Locations
            } else if viewModel.selectedId == viewModel.setting[11].id {
                PreferencesPlaceholderView()    // Advanced
            }
        }
    }

    public func showWindow() {
        PreferencesWindowController(view: self, size: NSSize(width: 760, height: 500)).showWindow(nil)
    }
}

struct SettingItem: Identifiable {
    let id = UUID().uuidString
    let name: String
    let image: NSImage
    let colour: Color
}

final class ViewModel: ObservableObject {

    init(setting: [SettingItem] = ViewModel.settingItems) {
        self.setting = setting
        self.selectedId = setting[0].id
    }

    @Published
    var setting: [SettingItem]
    @Published
    var selectedId: String?

    static let settingItems = [
        SettingItem(name: "General",
                    image: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!,
                    colour: .gray),
        SettingItem(name: "Accounts",
                    image: NSImage(systemSymbolName: "at", accessibilityDescription: nil)!,
                    colour: .purple),
        SettingItem(name: "Behaviors",
                    image: NSImage(systemSymbolName: "flowchart", accessibilityDescription: nil)!,
                    colour: .blue),
        SettingItem(name: "Navigation",
                    image: NSImage(systemSymbolName: "arrow.triangle.turn.up.right.diamond",
                                   accessibilityDescription: nil)!,
                    colour: .gray),
        SettingItem(name: "Themes",
                    image: NSImage(systemSymbolName: "paintbrush", accessibilityDescription: nil)!,
                    colour: .cyan),
        SettingItem(name: "Text Editing",
                    image: NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)!,
                    colour: .green),
        SettingItem(name: "Terminal",
                    image: NSImage(systemSymbolName: "terminal", accessibilityDescription: nil)!,
                    colour: .red),
        SettingItem(name: "Key Bindings",
                    image: NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)!,
                    colour: .gray),
        SettingItem(name: "Source Control",
                    image: NSImage.vault,
                    colour: .purple),
        SettingItem(name: "Components",
                    image: NSImage(systemSymbolName: "puzzlepiece", accessibilityDescription: nil)!,
                    colour: .green),
        SettingItem(name: "Locations",
                    image: NSImage(systemSymbolName: "externaldrive", accessibilityDescription: nil)!,
                    colour: .purple),
        SettingItem(name: "Advanced",
                    image: NSImage(systemSymbolName: "gearshape.2", accessibilityDescription: nil)!,
                    colour: .pink)
    ]
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
