//
//  CommitHistoryCellView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/08.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct CommitHistoryCellView: View {

    @State
    var commit: CommitHistory

    var body: some View {
        HStack {
            Avatar().gitAvatar(authorEmail: commit.authorEmail)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(commit.author)
                        .font(.system(size: 11))
                        .fontWeight(.bold)

                    if commit.isMerge ?? false {
                        HStack {
                            Image("git.merge")
                                .foregroundColor(.secondary)

                            Text("Merged")
                                .foregroundColor(.secondary)
                                .padding(.leading, -3)
                        }
                        .font(.system(size: 10))
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .padding(.trailing, -5)
                                .padding(.leading, -5)
                                .foregroundColor(Color(nsColor: .quaternaryLabelColor))
                        )
                        .padding(.trailing, 5)
                    }
                }

                Text(commit.message)
                    .font(.system(size: 11))
                    .lineLimit(1)
            }

            Spacer()

            VStack {
                VStack(alignment: .trailing, spacing: 3) {
                    Text(commit.hash)
                        .font(.system(size: 10))
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .padding(.trailing, -5)
                                .padding(.leading, -5)
                                .foregroundColor(Color(nsColor: .quaternaryLabelColor))
                        )
                        .padding(.trailing, 5)

                    Text(commit.date.relativeStringToNow())
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 1)
            }
        }
        .padding(.horizontal, 10)
    }
}

struct CommitHistoryCellView_Previews: PreviewProvider {
    static var previews: some View {
        CommitHistoryCellView(commit: CommitHistory(hash: "",
                                                    commitHash: "",
                                                    message: "",
                                                    author: "Tihan-Nico Paxton",
                                                    authorEmail: "",
                                                    commiter: "",
                                                    commiterEmail: "",
                                                    remoteURL: URL(string: "github.com"),
                                                    date: Date(),
                                                    isMerge: true))
    }
}
