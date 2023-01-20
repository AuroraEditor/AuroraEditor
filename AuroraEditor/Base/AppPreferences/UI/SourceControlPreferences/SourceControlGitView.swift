//
//  SourceControlGitView.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/04/01.
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
                    Text("Author Name")
                    Spacer()
                    TextField("Git Author Name", text: $prefs.preferences.sourceControl.git.authorName)
                        .frame(width: inputWidth)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)

                Divider()

                HStack {
                    Text("Author Email")
                    Spacer()
                    TextField("Git Email", text: $prefs.preferences.sourceControl.git.authorEmail)
                        .frame(width: inputWidth)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)

                Divider()

                HStack(alignment: .top) {
                    Text("Ignored Files")
                    Spacer()
                    VStack(spacing: 1) {
                        List($prefs.preferences.sourceControl.git.ignoredFiles,
                             selection: $ignoredFileSelection) { ignoredFile in
                            IgnoredFileView(ignoredFile: ignoredFile)
                        }
                        .overlay(Group {
                            if prefs.preferences.sourceControl.git.ignoredFiles.isEmpty {
                                Text("No Ignored Files")
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

            Text("Options")
                .fontWeight(.medium)
                .font(.system(size: 12))
                .padding(.horizontal)
                .padding(.top, 5)

            GroupBox {
                HStack {
                    Text("Prefer to rebase when pulling")
                    Spacer()
                    Toggle("Prefer to rebase when pulling",
                           isOn: $prefs.preferences.sourceControl.git.preferRebaseWhenPulling)
                    .labelsHidden()
                    .toggleStyle(.switch)
                }
                .padding(.top, 5)
                .padding(.horizontal)

                Divider()

                HStack {
                    Text("Show merge commits in per-file log")
                    Spacer()
                    Toggle("Show merge commits in per-file log",
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
