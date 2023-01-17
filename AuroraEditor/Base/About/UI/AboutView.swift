//
//  AboutView.swift
//  AuroraEditorModules/About
//
//  Created by Andrei Vidrasco on 02.04.2022
//

import SwiftUI

public struct AboutView: View {
    @Environment(\.openURL) private var openURL

    @State
    private var hoveringOnCommitHash = false

    public init() {}

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

    public var body: some View {
        HStack(spacing: 0) {
            logo
            VStack(alignment: .leading, spacing: 0) {
                topMetaData
                Spacer()
                bottomMetaData
                actionButtons
            }
            .padding([.trailing, .bottom])
        }
    }

    // MARK: Sub-Views

    private var logo: some View {
        Image(nsImage: NSApp.applicationIconImage)
            .resizable()
            .frame(width: 128, height: 128)
            .padding(32)
    }

    private var topMetaData: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Aurora Editor").font(.system(size: 38, weight: .regular))
            Text("Version \(appVersion) (\(appBuild))")
                .textSelection(.enabled)
                .foregroundColor(.secondary)
                .font(.system(size: 13, weight: .light))
            HStack(spacing: 2.0) {
                Text("Commit:")
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
    }

    private var bottomMetaData: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Copyright © 2022 Aurora Editor")
            Text("MIT License")
            Text("Based on CodeEdit, forked on the 4th of July 2022.")
        }
        .foregroundColor(.secondary)
        .font(.system(size: 9, weight: .light))
        .padding(.bottom, 10)
    }

    private var actionButtons: some View {
        HStack {
            Button {
                AcknowledgementsView()
                    .showWindow(
                        width: 600,
                        height: 600
                    )
            } label: {
                Text("Acknowledgments")
                    .frame(maxWidth: .infinity)
            }
            Button {
                guard let url = URL(string: "https://github.com/AuroraEditor/AuroraEditor/blob/main/LICENSE")
                else { return }
                openURL(url)
            } label: {
                Text("License Agreement")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    public func showWindow(width: CGFloat, height: CGFloat) {
        AboutWindowHostingController(view: self,
                                    size: NSSize(width: width,
                                                 height: height))
        .showWindow(nil)
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .frame(width: 530, height: 260)
    }
}
