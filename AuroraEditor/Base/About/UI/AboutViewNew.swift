//
//  AboutViewNew.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct AboutViewNew: View {

    @Environment(\.openURL)
    private var openURL

    @State
    private var hoveringOnCommitHash = false

    var body: some View {
        HStack {
            applicationDetails()
            Spacer()
            contributerDetails()

        }
        .frame(width: 640, height: 370)
    }

    private func applicationDetails() -> some View {
        VStack {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 75, height: 75)
                .padding(15)

            Text("Aurora Editor")
                .font(.system(size: 24, weight: .regular))

            Text("Version \(appVersion) (\(appBuild))")
                .textSelection(.enabled)
                .foregroundColor(.secondary)
                .font(.system(size: 12, weight: .light))
                .padding(5)

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

            Spacer()

            Button {

            } label: {
                Text("License")
            }
            .buttonStyle(.plain)

            Button {

            } label: {
                Text("Contributers")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func contributerDetails() -> some View {
        Text("Test")
    }

    private var appVersion: String {
        Bundle.versionString ?? "No Version"
    }

    private var appBuild: String {
        Bundle.buildString ?? "No Build"
    }

    private var commitHash: String {
        Bundle.commitHash ?? "No Hash"
    }

    private var shortCommitHash: String {
        if commitHash.count > 7 {
            return String(commitHash[...commitHash.index(commitHash.startIndex, offsetBy: 7)])
        }
        return commitHash
    }
}

struct AboutViewNew_Previews: PreviewProvider {
    static var previews: some View {
        AboutViewNew()
    }
}
