//
//  SourceControlGeneralView.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/04/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
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
                            Text("settings.source.control.general.enable")
                            Spacer()
                            Toggle("",
                                   isOn: $prefs.preferences.sourceControl.general.enableSourceControl)
                            .labelsHidden()
                            .toggleStyle(.switch)
                        }

                        Divider()

                        HStack {
                            Text("settings.source.control.general.refresh")
                            Spacer()
                            Toggle("",
                                   isOn: $prefs.preferences.sourceControl.general.refreshStatusLocaly)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .disabled(!prefs.sourceControlActive())
                        }

                        Divider()

                        HStack {
                            Text("settings.source.control.general.fetch")
                            Spacer()
                            Toggle("",
                                   isOn: $prefs.preferences.sourceControl.general.fetchRefreshServerStatus)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .disabled(!prefs.sourceControlActive())
                        }

                        Divider()

                        HStack {
                            Text("settings.source.control.general.add.remove")
                            Spacer()
                            Toggle("",
                                   isOn: $prefs.preferences.sourceControl.general.addRemoveAutomatically)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .disabled(!prefs.sourceControlActive())
                        }

                        Divider()

                        HStack {
                            Text("settings.source.control.general.select.files")
                            Spacer()
                            Toggle("",
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

            Text("settings.source.control.general.text.editing")
                .fontWeight(.medium)
                .font(.system(size: 12))
                .padding(.horizontal)
                .padding(.top, 5)

            GroupBox {
                VStack {
                    HStack {
                        Text("settings.source.control.general.show.changes")
                        Spacer()
                        Toggle("",
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

            Text("settings.source.control.general.reporting")
                .fontWeight(.medium)
                .font(.system(size: 12))
                .padding(.horizontal)
                .padding(.top, 5)

            GroupBox {
                HStack(alignment: .center) {
                    Text("settings.source.control.general.open.issues.browser")
                    Spacer()
                    Toggle("",
                           isOn: $prefs.preferences.sourceControl.general.openFeedbackInBrowser)
                    .labelsHidden()
                    .toggleStyle(.switch)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
                Divider()

                HStack(alignment: .top) {
                    Text("settings.source.control.general.comparison")
                    Spacer()
                    Picker("",
                           selection: $prefs.preferences.sourceControl.general.revisionComparisonLayout) {
                        Text("settings.source.control.general.comparison.revision.lect")
                            .tag(AppPreferences.RevisionComparisonLayout.localLeft)
                        Text("settings.source.control.general.comparison.revision.right")
                            .tag(AppPreferences.RevisionComparisonLayout.localRight)
                    }
                    .labelsHidden()
                    .frame(width: inputWidth)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
                Divider()

                HStack(alignment: .top) {
                    Text("settings.source.control.general.navigator")
                    Spacer()
                    Picker("",
                           selection: $prefs.preferences.sourceControl.general.controlNavigatorOrder) {
                        Text("settings.source.control.general.navigator.sort.name")
                            .tag(AppPreferences.ControlNavigatorOrder.sortByName)
                        Text("settings.source.control.general.navigator.sort.date")
                            .tag(AppPreferences.ControlNavigatorOrder.sortByDate)
                    }
                    .labelsHidden()
                    .frame(width: inputWidth)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
                Divider()

                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("settings.source.control.general.branch name")
                        Spacer()
                        VStack(alignment: .trailing) {
                            TextField("main", text: $branchName)
                                .frame(width: inputWidth)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    Divider()

                    Text("settings.source.control.general.branch.error")
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
