//
//  GeneralPreferencesViewSections.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 5/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

extension GeneralPreferencesView {
    var appearanceSection: some View {
        HStack {
            Text("settings.general.appearance")
            Spacer()
            Picker("", selection: $prefs.preferences.general.appAppearance) {
                Text("settings.general.appearance.system")
                    .tag(AppPreferences.Appearances.system)
                Divider()
                Text("settings.general.appearance.light")
                    .tag(AppPreferences.Appearances.light)
                Text("settings.general.appearance.dark")
                    .tag(AppPreferences.Appearances.dark)
            }
            .pickerStyle(.automatic)
            .labelsHidden()
            .onChange(of: prefs.preferences.general.appAppearance) { tag in
                tag.applyAppearance()
            }
            .frame(width: inputWidth)
        }
        .padding(.horizontal)
    }

    // TODO: Implement reflecting Show Issues preference and remove disabled modifier
    var showIssuesSection: some View {
        HStack {
            Text("settings.general.issues")

            Spacer()

            VStack {
                Picker("", selection: $prefs.preferences.general.showIssues) {
                    Text("settings.general.issues.inline")
                        .tag(AppPreferences.Issues.inline)
                    Text("settings.general.issues.minimized")
                        .tag(AppPreferences.Issues.minimized)
                }
                .labelsHidden()
                .frame(width: inputWidth)

                Toggle("settings.general.issues.live", isOn: $prefs.preferences.general.showLiveIssues)
                    .toggleStyle(.switch)
            }
            .disabled(true)
        }
        .padding(.horizontal)
    }

    var fileExtensionsSection: some View {
        HStack {
            Text("settings.general.file.extensions")

            Spacer()

            Picker("", selection: $prefs.preferences.general.fileExtensionsVisibility) {
                Text("settings.general.file.extensions.hide")
                    .tag(AppPreferences.FileExtensionsVisibility.hideAll)
                Text("settings.general.file.extensions.all")
                    .tag(AppPreferences.FileExtensionsVisibility.showAll)
                Divider()
                Text("settings.general.file.extensions.only")
                    .tag(AppPreferences.FileExtensionsVisibility.showOnly)
                Text("settings.general.file.extensions.hode")
                    .tag(AppPreferences.FileExtensionsVisibility.hideOnly)
            }
            .labelsHidden()
            .frame(width: inputWidth)
            if case .showOnly = prefs.preferences.general.fileExtensionsVisibility {
                SettingsTextEditor(text: $prefs.preferences.general.shownFileExtensions.string)
                    .frame(width: textEditorWidth)
                    .frame(height: textEditorHeight)
            }
            if case .hideOnly = prefs.preferences.general.fileExtensionsVisibility {
                SettingsTextEditor(text: $prefs.preferences.general.hiddenFileExtensions.string)
                .frame(width: textEditorWidth)
                .frame(height: textEditorHeight)
            }
        }
        .padding(.horizontal)
    }

    var fileIconStyleSection: some View {
        HStack {
            Text("settings.general.file.icon.style")
            Spacer()
            Picker("", selection: $prefs.preferences.general.fileIconStyle) {
                Text("settings.general.file.icon.style.color")
                    .tag(AppPreferences.FileIconStyle.color)
                Text("settings.general.file.icon.style.monochrome")
                    .tag(AppPreferences.FileIconStyle.monochrome)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    var tabBarStyleSection: some View {
        HStack {
            Text("settings.general.tabs.style")
            Spacer()
            Picker("", selection: $prefs.preferences.general.tabBarStyle) {
                Text("settings.general.tabs.style.xcode")
                    .tag(AppPreferences.TabBarStyle.xcode)
                Text("settings.general.tabs.style.aurora")
                    .tag(AppPreferences.TabBarStyle.native)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    var sidebarStyleSection: some View {
        HStack {
            Text("settings.general.navigator.position")
            Spacer()
            Picker("Tab Bar Style:", selection: $prefs.preferences.general.sidebarStyle) {
                Text("settings.general.navigator.position.top")
                    .tag(AppPreferences.SidebarStyle.xcode)
                Text("settings.general.navigator.position.left")
                    .tag(AppPreferences.SidebarStyle.vscode)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    var menuItemMode: some View {
        HStack {
            Text("settings.general.menu.bar")
            Spacer()
            Picker("", selection: $prefs.preferences.general.menuItemShowMode) {
                Text("settings.general.menu.bar.shown")
                    .tag(AppPreferences.MenuBarShow.shown)
                Text("settings.general.menu.bar.hidden")
                    .tag(AppPreferences.MenuBarShow.hidden)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    var reopenBehaviorSection: some View {
        HStack {
            Text("settings.general.open")
            Spacer()
            Picker("", selection: $prefs.preferences.general.reopenBehavior) {
                Text("settings.general.open.welcome")
                    .tag(AppPreferences.ReopenBehavior.welcome)
                Divider()
                Text("settings.general.open.panel")
                    .tag(AppPreferences.ReopenBehavior.openPanel)
                Text("settings.general.open.document")
                    .tag(AppPreferences.ReopenBehavior.newDocument)
            }
            .labelsHidden()
            .frame(width: inputWidth)
        }
        .padding(.horizontal)
    }

    var projectNavigatorSizeSection: some View {
        HStack {
            Text("settings.general.navigator.size")
            Spacer()
            Picker("", selection: $prefs.preferences.general.projectNavigatorSize) {
                Text("settings.general.navigator.size.small")
                    .tag(AppPreferences.ProjectNavigatorSize.small)
                Text("settings.general.navigator.size.medium")
                    .tag(AppPreferences.ProjectNavigatorSize.medium)
                Text("settings.general.navigator.size.large")
                    .tag(AppPreferences.ProjectNavigatorSize.large)
            }
            .labelsHidden()
            .frame(width: inputWidth)
        }
        .padding(.horizontal)
    }

    var findNavigatorDetailSection: some View {
        HStack {
            Text("settings.general.navigator.find")
            Spacer()
            Picker("", selection: $prefs.preferences.general.findNavigatorDetail) {
                ForEach(AppPreferences.NavigatorDetail.allCases, id: \.self) { tag in
                    Text(tag.label).tag(tag)
                }
            }
            .labelsHidden()
            .frame(width: inputWidth)
        }
        .padding(.horizontal)
    }

    // TODO: Implement reflecting Issue Navigator Detail preference and remove disabled modifier
    var issueNavigatorDetailSection: some View {
        HStack {
            Text("settings.general.navigator.issue")
            Spacer()
            Picker("", selection: $prefs.preferences.general.issueNavigatorDetail) {
                ForEach(AppPreferences.NavigatorDetail.allCases, id: \.self) { tag in
                    Text(tag.label).tag(tag)
                }
            }
            .labelsHidden()
            .frame(width: inputWidth)
        }
        .padding(.horizontal)
        .disabled(true)
    }

    // TODO: Implement reset for Don't Ask Me warnings Button and remove disabled modifier
    var dialogWarningsSection: some View {
        HStack {
            Text("settings.general.dialog.warnings")
            Spacer()
            Button(action: {
            }, label: {
                Text("settings.general.dialog.warnings.reset")
                    .padding(.horizontal, 10)
            })
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
        .disabled(true)
    }

    var shellCommandSection: some View {
        HStack {
            Text("settings.general.shell")
            Spacer()
            Button(action: {
                aeCommandLine()
            }, label: {
                Text("settings.general.shell.command")
                    .padding(.horizontal, 10)
            })
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }

    var openInAuroraEditorToggle: some View {
        HStack {
            Text("settings.general.extension.open.with")
            Spacer()
            Toggle("", isOn: $openInAuroraEditor)
                .labelsHidden()
                .toggleStyle(.switch)
                .onChange(of: openInAuroraEditor) { newValue in
                    guard let defaults = UserDefaults(
                        suiteName: "com.auroraeditor.shared"
                    ) else {
                        Log.error("Failed to get/init shared defaults")
                        return
                    }

                    defaults.set(newValue, forKey: "enableOpenInAE")
                }
        }
        .padding(.horizontal)
    }

    var preferencesLocation: some View {
        HStack {
              Text("Preferences")
              Spacer()
              HStack {
                  Text(AppPreferencesModel.shared.baseURL.path)
                      .foregroundColor(.secondary)
                  Button {
                      NSWorkspace.shared.selectFile(
                          nil,
                          inFileViewerRootedAtPath: AppPreferencesModel.shared.baseURL.path
                      )
                  } label: {
                      Image(systemName: "arrow.right.circle.fill")
                  }
                  .buttonStyle(.plain)
                  .foregroundColor(.secondary)
              }
        }
          .padding(.top, 5)
          .padding(.horizontal)
    }

    var revealFileOnFocusChangeToggle: some View {
        HStack {
            Text("settings.general.show.active.file")
            Spacer()
            Toggle("", isOn: $prefs.preferences.general.revealFileOnFocusChange)
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.horizontal)
    }

    var keepInspectorWindowOpen: some View {
        HStack {
            Text("settings.general.inspector.keep.open")
            Spacer()
            Toggle("", isOn: $prefs.preferences.general.keepInspectorSidebarOpen)
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.vertical, 7)
        .padding(.horizontal)
    }
}
