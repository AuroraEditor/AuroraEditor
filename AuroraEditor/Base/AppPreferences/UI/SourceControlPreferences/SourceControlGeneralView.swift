//
//  SourceControlGeneralView.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct SourceControlGeneralView: View {

    private let inputWidth: Double = 200

    @State var isChecked: Bool
    @State var branchName: String

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        VStack(alignment: .leading) {
            GroupBox {
                HStack(alignment: .top) {
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Enable Source Control")
                            Spacer()
                            Toggle("Enable Source Control",
                                   isOn: $prefs.preferences.sourceControl.general.enableSourceControl)
                            .labelsHidden()
                            .toggleStyle(.switch)
                        }

                        Divider()

                        HStack {
                            Text("Refresh local status automatically")
                            Spacer()
                            Toggle("Refresh local status automatically",
                                   isOn: $prefs.preferences.sourceControl.general.refreshStatusLocaly)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .disabled(!prefs.sourceControlActive())
                        }

                        Divider()

                        HStack {
                            Text("Fetch and refresh server status automatically")
                            Spacer()
                            Toggle("Fetch and refresh server status automatically",
                                   isOn: $prefs.preferences.sourceControl.general.fetchRefreshServerStatus)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .disabled(!prefs.sourceControlActive())
                        }

                        Divider()

                        HStack {
                            Text("Add and remove files automatically")
                            Spacer()
                            Toggle("Add and remove files automatically",
                                   isOn: $prefs.preferences.sourceControl.general.addRemoveAutomatically)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .disabled(!prefs.sourceControlActive())
                        }

                        Divider()

                        HStack {
                            Text("Select files to commit automatically")
                            Spacer()
                            Toggle("Select files to commit automatically",
                                   isOn: $prefs.preferences.sourceControl.general.selectFilesToCommit)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .disabled(!prefs.sourceControlActive())
                        }
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
            }

            Text("Text Editing")
                .fontWeight(.medium)
                .font(.system(size: 12))
                .padding(.horizontal)
                .padding(.top, 5)

            GroupBox {
                VStack {
                    HStack {
                        Text("Show Source Control changes")
                        Spacer()
                        Toggle("Show Source Control changes",
                               isOn: $prefs.preferences.sourceControl.general.showSourceControlChanges)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .disabled(!prefs.sourceControlActive())
                    }

                    Divider()

                    HStack {
                        Text("Include upstream changes")
                        Spacer()
                        Toggle("Include upstream changes",
                               isOn: $prefs.preferences.sourceControl.general.includeUpstreamChanges)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .disabled(!prefs.sourceControlActive())
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
            }

            Text("Reporting")
                .fontWeight(.medium)
                .font(.system(size: 12))
                .padding(.horizontal)
                .padding(.top, 5)

            GroupBox {
                HStack(alignment: .center) {
                    Text("Open created issue in the browser")
                    Spacer()
                    Toggle("Open created issue in the browser",
                           isOn: $prefs.preferences.sourceControl.general.openFeedbackInBrowser)
                    .labelsHidden()
                    .toggleStyle(.switch)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
            }

            GroupBox {
                HStack(alignment: .top) {
                    Text("Comparison View")
                    Spacer()
                    Picker("Comparison View",
                           selection: $prefs.preferences.sourceControl.general.revisionComparisonLayout) {
                        Text("Local Revision on Left Side")
                            .tag(AppPreferences.RevisionComparisonLayout.localLeft)
                        Text("Local Revision on Right Side")
                            .tag(AppPreferences.RevisionComparisonLayout.localRight)
                    }
                    .labelsHidden()
                    .frame(width: inputWidth)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
            }

            GroupBox {
                HStack(alignment: .top) {
                    Text("Source Control Navigator")
                    Spacer()
                    Picker("Source Control Navigator",
                           selection: $prefs.preferences.sourceControl.general.controlNavigatorOrder) {
                        Text("Sort by Name")
                            .tag(AppPreferences.ControlNavigatorOrder.sortByName)
                        Text("Sort by Date")
                            .tag(AppPreferences.ControlNavigatorOrder.sortByDate)
                    }
                    .labelsHidden()
                    .frame(width: inputWidth)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
            }

            GroupBox {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("Default Branch Name")
                        Spacer()
                        VStack(alignment: .trailing) {
                            TextField("main", text: $branchName)
                                .frame(width: inputWidth)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    Divider()

                    Text("Branch names cannot contain spaces, backslashes, or other symbols")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
            }
        }
    }
}

struct SourceControlGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlGeneralView(isChecked: true, branchName: "main")
    }
}
