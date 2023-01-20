//
//  GeneralPreferencesViewSections.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 5/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

extension GeneralPreferencesView {
    var appearanceSection: some View {
        HStack {
            Text("Appearance")
            Spacer()
            Picker("Appearance", selection: $prefs.preferences.general.appAppearance) {
                Text("System")
                    .tag(AppPreferences.Appearances.system)
                Divider()
                Text("Light")
                    .tag(AppPreferences.Appearances.light)
                Text("Dark")
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
            Text("Show Issues")

            Spacer()

            VStack {
                Picker("Show Issues", selection: $prefs.preferences.general.showIssues) {
                    Text("Show Inline")
                        .tag(AppPreferences.Issues.inline)
                    Text("Show Minimized")
                        .tag(AppPreferences.Issues.minimized)
                }
                .labelsHidden()
                .frame(width: inputWidth)

                Toggle("Show Live Issues", isOn: $prefs.preferences.general.showLiveIssues)
                    .toggleStyle(.switch)
            }
            .disabled(true)
        }
        .padding(.horizontal)
    }

    var fileExtensionsSection: some View {
        HStack {
            Text("File Extensions")

            Spacer()

            Picker("File Extensions:", selection: $prefs.preferences.general.fileExtensionsVisibility) {
                Text("Hide all")
                    .tag(AppPreferences.FileExtensionsVisibility.hideAll)
                Text("Show all")
                    .tag(AppPreferences.FileExtensionsVisibility.showAll)
                Divider()
                Text("Show only")
                    .tag(AppPreferences.FileExtensionsVisibility.showOnly)
                Text("Hide only")
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
            Text("File Icon Style")
            Spacer()
            Picker("File Icon Style:", selection: $prefs.preferences.general.fileIconStyle) {
                Text("Color")
                    .tag(AppPreferences.FileIconStyle.color)
                Text("Monochrome")
                    .tag(AppPreferences.FileIconStyle.monochrome)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    var tabBarStyleSection: some View {
        HStack {
            Text("Tab Bar Style")
            Spacer()
            Picker("Tab Bar Style:", selection: $prefs.preferences.general.tabBarStyle) {
                Text("Xcode Style")
                    .tag(AppPreferences.TabBarStyle.xcode)
                Text("Aurora Style")
                    .tag(AppPreferences.TabBarStyle.native)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    var sidebarStyleSection: some View {
        HStack {
            Text("Navigator Mode Position")
            Spacer()
            Picker("Tab Bar Style:", selection: $prefs.preferences.general.sidebarStyle) {
                Text("Top")
                    .tag(AppPreferences.SidebarStyle.xcode)
                Text("Left")
                    .tag(AppPreferences.SidebarStyle.vscode)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    var menuItemMode: some View {
        HStack {
            Text("Menu Bar Accessory (Requires restart to update)")
            Spacer()
            Picker("Shown/Hidden:", selection: $prefs.preferences.general.menuItemShowMode) {
                Text("Shown")
                    .tag(AppPreferences.MenuBarShow.shown)
                Text("Hidden")
                    .tag(AppPreferences.MenuBarShow.hidden)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    var reopenBehaviorSection: some View {
        HStack {
            Text("Reopen Behavior")
            Spacer()
            Picker("Reopen Behavior:", selection: $prefs.preferences.general.reopenBehavior) {
                Text("Welcome Screen")
                    .tag(AppPreferences.ReopenBehavior.welcome)
                Divider()
                Text("Open Panel")
                    .tag(AppPreferences.ReopenBehavior.openPanel)
                Text("New Document")
                    .tag(AppPreferences.ReopenBehavior.newDocument)
            }
            .labelsHidden()
            .frame(width: inputWidth)
        }
        .padding(.horizontal)
    }

    var projectNavigatorSizeSection: some View {
        HStack {
            Text("Project Navigator Size")
            Spacer()
            Picker("Project Navigator Size", selection: $prefs.preferences.general.projectNavigatorSize) {
                Text("Small")
                    .tag(AppPreferences.ProjectNavigatorSize.small)
                Text("Medium")
                    .tag(AppPreferences.ProjectNavigatorSize.medium)
                Text("Large")
                    .tag(AppPreferences.ProjectNavigatorSize.large)
            }
            .labelsHidden()
            .frame(width: inputWidth)
        }
        .padding(.horizontal)
    }

    var findNavigatorDetailSection: some View {
        HStack {
            Text("Find Navigator Detail")
            Spacer()
            Picker("Find Navigator Detail", selection: $prefs.preferences.general.findNavigatorDetail) {
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
            Text("Issue Navigator Detail")
            Spacer()
            Picker("Issue Navigator Detail", selection: $prefs.preferences.general.issueNavigatorDetail) {
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
            Text("Dialog Warnings")
            Spacer()
            Button(action: {
            }, label: {
                Text("Reset \"Don't Ask Me\" Warnings")
                    .padding(.horizontal, 10)
            })
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
        .disabled(true)
    }

    var shellCommandSection: some View {
        HStack {
            Text("Shell Command")
            Spacer()
            Button(action: {
                aeCommandLine()
            }, label: {
                Text("Install 'ae' command")
                    .padding(.horizontal, 10)
            })
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }

    var openInAuroraEditorToggle: some View {
        HStack {
            Text("Show “Open With AuroraEditor” option")
            Spacer()
            Toggle("", isOn: $openInAuroraEditor)
                .labelsHidden()
                .toggleStyle(.switch)
                .onChange(of: openInAuroraEditor) { newValue in
                    guard let defaults = UserDefaults.init(
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
            Text("Automatically Show Active File")
            Spacer()
            Toggle("Automatically Show Active File", isOn: $prefs.preferences.general.revealFileOnFocusChange)
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.horizontal)
    }

    var keepInspectorWindowOpen: some View {
        HStack {
            Text("Keep Inspector Sidebar Open")
            Spacer()
            Toggle("", isOn: $prefs.preferences.general.keepInspectorSidebarOpen)
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.vertical, 7)
        .padding(.horizontal)
    }
}
