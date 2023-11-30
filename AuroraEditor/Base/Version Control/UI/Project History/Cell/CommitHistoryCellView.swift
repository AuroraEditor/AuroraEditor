//
//  CommitHistoryCellView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct CommitHistoryCellView: View {

    @State
    var commit: Commit

    var body: some View {
        HStack {
            Avatar().gitAvatar(authorEmail: commit.author.email)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(commit.author.name)
                        .font(.system(size: 11))
                        .fontWeight(.bold)

                    if commit.isMergeCommit {
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

                Text(commit.summary)
                    .font(.system(size: 11))
                    .lineLimit(1)
            }

            Spacer()

            VStack {
                VStack(alignment: .trailing, spacing: 3) {
                    Text(commit.sha)
                        .font(.system(size: 10))
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .padding(.trailing, -5)
                                .padding(.leading, -5)
                                .foregroundColor(Color(nsColor: .quaternaryLabelColor))
                        )
                        .padding(.trailing, 5)

//                    Text(commit..relativeStringToNow())
//                        .font(.system(size: 11))
//                        .foregroundColor(.secondary)
                }
                .padding(.top, 1)
            }
        }
        .padding(.horizontal, 10)
    }
}
