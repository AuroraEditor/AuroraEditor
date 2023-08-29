//
//  ApplicationsDetailsView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct ApplicationsDetailsView: View {

    @Binding
    var aboutDetailState: AboutDetailState

    @State
    private var hoveringOnCommitHash = false

    private var appVersion: String {
        Bundle.versionString ?? "about.no.version".localize()
    }

    private var appBuild: String {
        Bundle.buildString ?? "about.no.build".localize()
    }

    private var commitHash: String {
        Bundle.commitHash ?? "about.no.hash".localize()
    }

    private var shortCommitHash: String {
        if commitHash.count > 7 {
            return String(commitHash[...commitHash.index(commitHash.startIndex, offsetBy: 7)])
        }
        return commitHash
    }

    var body: some View {
        VStack {
            VStack {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 75, height: 75)

                Text("Aurora Editor")
                    .font(.system(size: 24, weight: .regular))

                Text("about.version \(appVersion) (\(appBuild))")
                    .textSelection(.enabled)
                    .foregroundColor(.secondary)
                    .font(.system(size: 12, weight: .light))
                    .padding(.top, -10)
                    .padding(.bottom, 5)

                HStack(spacing: 2.0) {
                    Text("")
                    Text(self.hoveringOnCommitHash ?
                         commitHash : shortCommitHash)
                    .textSelection(.enabled)
                    .onHover { hovering in
                        self.hoveringOnCommitHash = hovering
                    }
                    .animation(.easeInOut, value: self.hoveringOnCommitHash)
                }
                .foregroundColor(.secondary)
                .font(.system(size: 10, weight: .light))
            }
            .frame(height: 210)

            Spacer()

            VStack(spacing: 10) {
                Text("about.license")
                    .onTapGesture {
                        aboutDetailState = .license
                    }
                    .foregroundColor(aboutDetailState == .license ? .white : .secondary)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background(aboutDetailState == .license ? Color(nsColor: NSColor(.accentColor)) : .clear)
                    .cornerRadius(20)

                Text("about.contributers")
                    .onTapGesture {
                        aboutDetailState = .contributers
                    }
                    .foregroundColor(aboutDetailState == .contributers ? .white : .secondary)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background(aboutDetailState == .contributers ? Color(nsColor: NSColor(.accentColor)) : .clear)
                    .cornerRadius(20)

                Text("about.credits")
                    .onTapGesture {
                        aboutDetailState = .credits
                    }
                    .foregroundColor(aboutDetailState == .credits ? .white : .secondary)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background(aboutDetailState == .credits ? Color(nsColor: NSColor(.accentColor)) : .clear)
                    .cornerRadius(20)
            }

            Spacer()
        }
        .frame(height: 370)
    }
}

struct ApplicationsDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationsDetailsView(aboutDetailState: .constant(.license))
    }
}
