//
//  ThemePreferencesView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 30.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that implements the `Theme` preference section
public struct ThemePreferencesView: View {
    /// The color scheme
    @Environment(\.colorScheme)
    var colorScheme

    /// Theme model
    @ObservedObject
    private var themeModel: ThemeModel = .shared

    /// Preferences model
    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    /// List view
    @State
    private var listView: Bool = false

    /// The view body
    public init() {}

    /// The view body
    public var body: some View {
        VStack(spacing: 20) {
            frame
            HStack(alignment: .center) {
                Toggle(
                    "settings.theme.change.based.on.system",
                    isOn: $prefs.preferences.theme.mirrorSystemAppearance
                )
                Spacer()
                Button("settings.theme.get.themes") {}
                    .disabled(true)
                    .help("Not yet implemented")
                HelpButton {}
                    .disabled(true)
                    .help("Not yet implemented")
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.main.async {
                try? themeModel.loadThemes()
            }
        }
    }

    /// The frame
    private var frame: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 1) {
                sidebar
                settingsContent
            }
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
            .frame(height: 468)
        }
    }

    /// The sidebar
    private var sidebar: some View {
        VStack(spacing: 1) {
            PreferencesToolbar {
                let options = [
                    "settings.theme.appearance.dark".localize(),
                    "settings.theme.appearance.light".localize(),
                    "settings.theme.appearance.universal".localize()
                ]
                SegmentedControl($themeModel.selectedAppearance, options: options)
            }
            if listView {
                sidebarListView
            } else {
                sidebarScrollView
            }
            PreferencesToolbar {
                sidebarBottomToolbar
            }
        }
        .frame(width: 320)
    }

    /// The sidebar list view
    private var sidebarListView: some View {
        List(selection: $themeModel.selectedTheme) {
            // 0: Dark
            // 1: Light
            // 2: Universal
            ForEach(themeModel.selectedAppearance == 0 ? themeModel.darkThemes : themeModel.universalThemes) { theme in
                Button(theme.displayName) { themeModel.selectedTheme = theme }
                    .buttonStyle(.plain)
                    .tag(theme)
                    .contextMenu {
                        Button("settings.theme.reset") {
                            themeModel.reset(theme)
                        }
                        Divider()
                        Button("settings.theme.delete", role: .destructive) {
                            themeModel.delete(theme)
                        }
                        .disabled(themeModel.themes.count <= 1)
                    }
            }
        }
    }

    /// The sidebar scroll view
    private var sidebarScrollView: some View {
        ScrollView {
            let grid: [GridItem] = .init(
                repeating: .init(.fixed(130), spacing: 20, alignment: .top),
                count: 2
            )
            LazyVGrid(columns: grid,
                      alignment: .center,
                      spacing: 20) {
                ForEach(themeModel.selectedAppearance == 0 ? themeModel.darkThemes :
                            (themeModel.selectedAppearance == 1 ? themeModel.lightThemes :
                                themeModel.universalThemes)) { theme in
                    ThemePreviewIcon(
                        theme,
                        selection: $themeModel.selectedTheme,
                        // 0: dark
                        // 1: light
                        // 2: depends on if the user is in light/dark mode
                        colorScheme: themeModel.selectedAppearance == 0 ? .dark :
                            (themeModel.selectedAppearance == 1 ? .light :
                            (UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" ? .dark : .light))
                    )
                    .transition(.opacity)
                    .contextMenu {
                        Button("settings.theme.reset") {
                            themeModel.reset(theme)
                        }
                        Divider()
                        Button("settings.theme.delete", role: .destructive) {
                            themeModel.delete(theme)
                        }
                        .disabled(themeModel.themes.count <= 1)
                    }
                }
            }
                      .padding(.vertical, 20)
        }
        .background(EffectView(.contentBackground))
    }

    /// The sidebar bottom toolbar
    private var sidebarBottomToolbar: some View {
        HStack {
            Button {} label: {
                Image(systemName: "plus")
                    .accessibilityLabel(Text("Add"))
            }
            .disabled(true)
            .help("Not yet implemented")
            .buttonStyle(.plain)
            Button {
                if let selectedTheme = themeModel.selectedTheme {
                    themeModel.delete(selectedTheme)
                }
            } label: {
                Image(systemName: "minus")
                    .accessibilityLabel(Text("Delete"))
            }
            .disabled(themeModel.selectedTheme == nil || themeModel.themes.count <= 1)
            .help("settings.theme.delete.selected")
            .buttonStyle(.plain)
            Divider()
            Button { try? themeModel.loadThemes() } label: {
                Image(systemName: "arrow.clockwise")
                    .accessibilityLabel(Text("Reload"))
            }
            .buttonStyle(.plain)
            Spacer()
            Button {
                listView = true
            } label: {
                Image(systemName: "list.dash")
                    .foregroundColor(listView ? .accentColor : .primary)
                    .accessibilityLabel(Text("List View"))
            }
            .buttonStyle(.plain)
            Button {
                listView = false
            } label: {
                Image(systemName: "square.grid.2x2")
                    .symbolVariant(listView ? .none : .fill)
                    .foregroundColor(listView ? .primary : .accentColor)
                    .accessibilityLabel(Text("Grid View"))
            }
            .buttonStyle(.plain)
        }
    }

    /// The settings content
    private var settingsContent: some View {
        VStack(spacing: 1) {
            let options = [
                "settings.theme.preview".localize(),
                "settings.theme.tab.editor".localize(),
                "settings.theme.tab.terminal".localize()
            ]
            PreferencesToolbar {
                SegmentedControl($themeModel.selectedTab, options: options)
            }
            switch themeModel.selectedTab {
            case 1:
                HighlightThemeView()
            case 2:
                TerminalThemeView()
            default:
                PreviewThemeView()
            }
            PreferencesToolbar {
                HStack {
                    if themeModel.selectedTab == 1 {
                        Button {
                            guard let selectedTheme = themeModel.selectedTheme?.editor.highlightTheme else { return }
                            withAnimation {
                                // remove all empty scopes, insert new theme setting at the top
                                selectedTheme.settings.removeAll(where: { $0.scopes.isEmpty })
                                selectedTheme.settings.insert(ThemeSetting(scope: ""), at: 0)
                                selectedTheme.root = HighlightTheme
                                    .createTrie(settings: selectedTheme.settings)
                                themeModel.objectWillChange.send()
                            }
                        } label: {
                            Image(systemName: "plus")
                                .accessibilityLabel(Text("Add"))
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                    Button {} label: {
                        Image(systemName: "info.circle")
                            .accessibilityLabel(Text("Info"))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct PrefsThemes_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreferencesView()
            .preferredColorScheme(.light)
    }
}
