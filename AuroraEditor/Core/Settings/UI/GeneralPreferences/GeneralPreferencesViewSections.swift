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
    /// The appearance section
    var appearanceSection: some View {
        HStack {
            Text("settings.general.appearance")
            Spacer()
            Picker("", selection: $prefs.preferences.general.appAppearance) {
                Text("settings.general.appearance.system")
                    .tag(Appearances.system)
                Divider()
                Text("settings.general.appearance.light")
                    .tag(Appearances.light)
                Text("settings.general.appearance.dark")
                    .tag(Appearances.dark)
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
    /// The show issues section
    var showIssuesSection: some View {
        HStack {
            Text("settings.general.issues")

            Spacer()

            VStack {
                Picker("", selection: $prefs.preferences.general.showIssues) {
                    Text("settings.general.issues.inline")
                        .tag(Issues.inline)
                    Text("settings.general.issues.minimized")
                        .tag(Issues.minimized)
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

    /// The file extensions section
    var fileExtensionsSection: some View {
        HStack {
            Text("settings.general.file.extensions")

            Spacer()

            Picker("", selection: $prefs.preferences.general.fileExtensionsVisibility) {
                Text("settings.general.file.extensions.hide")
                    .tag(FileExtensionsVisibility.hideAll)
                Text("settings.general.file.extensions.all")
                    .tag(FileExtensionsVisibility.showAll)
                Divider()
                Text("settings.general.file.extensions.only")
                    .tag(FileExtensionsVisibility.showOnly)
                Text("settings.general.file.extensions.hode")
                    .tag(FileExtensionsVisibility.hideOnly)
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

    /// The file icon style section
    var fileIconStyleSection: some View {
        HStack {
            Text("settings.general.file.icon.style")
            Spacer()
            Picker("", selection: $prefs.preferences.general.fileIconStyle) {
                Text("settings.general.file.icon.style.color")
                    .tag(FileIconStyle.color)
                Text("settings.general.file.icon.style.monochrome")
                    .tag(FileIconStyle.monochrome)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    /// The sidebar style section
    var sidebarStyleSection: some View {
        HStack {
            Text("settings.general.navigator.position")
            Spacer()
            Picker("Tab Bar Style:", selection: $prefs.preferences.general.sidebarStyle) {
                Text("settings.general.navigator.position.top")
                    .tag(SidebarStyle.xcode)
                Text("settings.general.navigator.position.left")
                    .tag(SidebarStyle.vscode)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    /// The menu item mode section
    var menuItemMode: some View {
        HStack {
            Text("settings.general.menu.bar")
            Spacer()
            Picker("", selection: $prefs.preferences.general.menuItemShowMode) {
                Text("settings.general.menu.bar.shown")
                    .tag(MenuBarShow.shown)
                Text("settings.general.menu.bar.hidden")
                    .tag(MenuBarShow.hidden)
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)
        }
        .padding(.horizontal)
    }

    /// The reopen behavior section
    var reopenBehaviorSection: some View {
        HStack {
            Text("settings.general.open")
            Spacer()
            Picker("", selection: $prefs.preferences.general.reopenBehavior) {
                Text("settings.general.open.welcome")
                    .tag(ReopenBehavior.welcome)
                Divider()
                Text("settings.general.open.panel")
                    .tag(ReopenBehavior.openPanel)
                Text("settings.general.open.document")
                    .tag(ReopenBehavior.newDocument)
            }
            .labelsHidden()
            .frame(width: inputWidth)
        }
        .padding(.horizontal)
    }

    /// The project navigator size section
    var projectNavigatorSizeSection: some View {
        HStack {
            Text("settings.general.navigator.size")
            Spacer()
            Picker("", selection: $prefs.preferences.general.projectNavigatorSize) {
                Text("settings.general.navigator.size.small")
                    .tag(ProjectNavigatorSize.small)
                Text("settings.general.navigator.size.medium")
                    .tag(ProjectNavigatorSize.medium)
                Text("settings.general.navigator.size.large")
                    .tag(ProjectNavigatorSize.large)
            }
            .labelsHidden()
            .frame(width: inputWidth)
        }
        .padding(.horizontal)
    }

    /// The navigator detail section
    var findNavigatorDetailSection: some View {
        HStack {
            Text("settings.general.navigator.find")
            Spacer()
            Picker("", selection: $prefs.preferences.general.findNavigatorDetail) {
                ForEach(NavigatorDetail.allCases, id: \.self) { tag in
                    Text(tag.label).tag(tag)
                }
            }
            .labelsHidden()
            .frame(width: inputWidth)
        }
        .padding(.horizontal)
    }

    // TODO: Implement reflecting Issue Navigator Detail preference and remove disabled modifier
    /// The issue navigator detail section
    var issueNavigatorDetailSection: some View {
        HStack {
            Text("settings.general.navigator.issue")
            Spacer()
            Picker("", selection: $prefs.preferences.general.issueNavigatorDetail) {
                ForEach(NavigatorDetail.allCases, id: \.self) { tag in
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
    /// The dialog warnings section
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

    /// The shell command section
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

    /// The open in Aurora Editor toggle
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
                        self.logger.fault("Failed to get/init shared defaults")
                        return
                    }

                    defaults.set(newValue, forKey: "enableOpenInAE")
                }
        }
        .padding(.horizontal)
    }

    /// The preferences location section
    var preferencesLocation: some View {
        HStack {
              Text("Preferences")
              Spacer()
              HStack {
                  Text(FileManager.default.auroraEditorBaseURL.path)
                      .foregroundColor(.secondary)
                  Button {
                      NSWorkspace.shared.selectFile(
                          nil,
                          inFileViewerRootedAtPath: FileManager.default.auroraEditorBaseURL.path
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

    /// The install path section
    var installPath: String {
        let bundleURL = Bundle.main.resourceURL
        guard var bundleURL = bundleURL?.deletingLastPathComponent() else {
            return "No install path found"
        }
        bundleURL = bundleURL.deletingLastPathComponent()
        return bundleURL.path
    }

    /// The install path location section
    var installPathLocation: some View {
        HStack {
              Text("Install Path")
              Spacer()
              HStack {
                  Text(self.installPath)
                      .foregroundColor(.secondary)
                  if let resPath = Bundle.main.resourcePath {
                      Button {
                          NSWorkspace.shared.selectFile(
                            nil,
                            inFileViewerRootedAtPath: resPath
                          )
                      } label: {
                          Image(systemName: "arrow.right.circle.fill")
                      }
                      .buttonStyle(.plain)
                      .foregroundColor(.secondary)
                  }
              }
        }
          .padding(.top, 5)
          .padding(.horizontal)
    }

    /// The reveal file on focus change toggle
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

    /// The keep inspector window open toggle
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
