//
//  SourceControlGitView.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/04/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct SourceControlGitView: View {

    private let inputWidth: Double = 280

    @State var ignoredFileSelection: IgnoredFiles.ID?

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        VStack(alignment: .leading) {
            GroupBox {
                HStack {
                    Text("settings.source.control.git.author.name")
                    Spacer()
                    TextField("settings.source.control.git.author",
                              text: $prefs.preferences.sourceControl.git.authorName)
                        .frame(width: inputWidth)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)

                Divider()

                HStack {
                    Text("settings.source.control.git.author.email")
                    Spacer()
                    TextField("settings.source.control.git.email",
                              text: $prefs.preferences.sourceControl.git.authorEmail)
                        .frame(width: inputWidth)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)

                Divider()

                HStack(alignment: .top) {
                    Text("settings.source.control.git.ignored.files")
                    Spacer()
                    VStack(spacing: 1) {
                        List($prefs.preferences.sourceControl.git.ignoredFiles,
                             selection: $ignoredFileSelection) { ignoredFile in
                            IgnoredFileView(ignoredFile: ignoredFile)
                        }
                        .overlay(Group {
                            if prefs.preferences.sourceControl.git.ignoredFiles.isEmpty {
                                Text("settings.source.control.git.ignored.files.none")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 11))
                            }
                        })
                        .frame(height: 150)
                        PreferencesToolbar(height: 22) {
                            bottomToolbar
                        }
                    }
                    .frame(width: inputWidth)
                    .padding(1)
                    .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
            }

            Text("settings.source.control.git.options")
                .fontWeight(.medium)
                .font(.system(size: 12))
                .padding(.horizontal)
                .padding(.top, 5)

            GroupBox {
                HStack {
                    Text("settings.source.control.git.prefer.rebase")
                    Spacer()
                    Toggle("",
                           isOn: $prefs.preferences.sourceControl.git.preferRebaseWhenPulling)
                    .labelsHidden()
                    .toggleStyle(.switch)
                }
                .padding(.top, 5)
                .padding(.horizontal)

                Divider()

                HStack {
                    Text("settings.source.control.git.show.commits")
                    Spacer()
                    Toggle("",
                           isOn: $prefs.preferences.sourceControl.git.showMergeCommitsPerFileLog)
                    .labelsHidden()
                    .toggleStyle(.switch)
                }
                .padding(.bottom, 5)
                .padding(.horizontal)
            }
        }
    }

    private var bottomToolbar: some View {
        HStack(spacing: 12) {
            Button {} label: {
                Image(systemName: "plus")
                    .foregroundColor(Color.secondary)
            }
            .buttonStyle(.plain)
            Button {} label: {
                Image(systemName: "minus")
            }
            .disabled(true)
            .buttonStyle(.plain)
            Spacer()
        }
    }
}

struct SourceControlGitView_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlGitView().preferredColorScheme(.dark)
    }
}
