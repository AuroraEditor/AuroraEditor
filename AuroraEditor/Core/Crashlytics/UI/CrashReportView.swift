//
//  CrashReportView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

/// A view that represents the crash report view.
public struct CrashReportView: View {
    /// The crash report model
    @StateObject
    private var reportModel: CrashReportModel = .shared

    /// The app preferences model
    private var prefs: AppPreferencesModel = .shared

    /// The error details
    @State
    var errorDetails: String

    /// Hide details
    @State
    private var hideDetails: Bool = false

    /// Hide comment
    @State
    private var hideComment: Bool = false

    /// The crash report view
    /// 
    /// - Parameter errorDetails: The error details
    public init(errorDetails: String) {
        self.errorDetails = errorDetails
    }

    /// The view body
    public var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 50))
                    .accessibilityLabel(Text("Error Icon"))

                Spacer()

                HelpButton {
                    // TODO: Add help content
                }
            }
            VStack(alignment: .leading) {
                Text("AuroraEditor quit unexpectedly.")
                    .font(.headline)
                    .padding(.bottom, 5)

                // swiftlint:disable:next line_length
                Text("Click Reopen to open the application again. This report will be sent automatically to the AuroraEditor team.")
                    .font(.caption)
                    .font(.system(size: 12))

                HStack {
                    Image(systemName: hideComment ? "chevron.up" : "chevron.down")
                        .accessibilityLabel(Text(hideComment ? "Open" : "Close"))

                    Text("Comments")
                        .font(.system(size: 12))
                }
                .onTapGesture {
                    withAnimation {
                        hideComment.toggle()
                    }
                }
                .accessibilityAddTraits(.isButton)
                .padding(.bottom, hideComment ? 5 : 0)
                .padding(.top, 5)

                if !(hideComment) {
                    TextEditor(text: $reportModel.comments)
                        .frame(height: 75, alignment: .leading)
                        .border(Color(NSColor.separatorColor))
                }

                if !(hideDetails) {
                    Text("Problem Details and System Configuration")
                        .font(.system(size: 12))

                    TextEditor(text: $errorDetails)
                        .frame(height: 490, alignment: .leading)
                        .border(Color(NSColor.separatorColor))
                }

                HStack {
                    Button {
                        withAnimation {
                            hideDetails.toggle()
                        }
                    } label: {
                        Text(hideDetails ? "Show Details" : "Hide Details")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button {
                        CrashReportController(view: self).closeAnimated()
                        UserDefaults.standard.removeObject(forKey: "crash")
                        closeApplication()
                    } label: {
                        Text("OK")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding()
                            .padding()
                    }

                    Button {
                        UserDefaults.standard.removeObject(forKey: "crash")
                        if AccountPreferences.doesUserHaveGitAccounts() {
                            restartApplication()
                        } else {
                            reportModel.createIssue(comments: reportModel.comments,
                                                    crashData: errorDetails)
                            restartApplication()
                        }
                    } label: {
                        Text("Reopen")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(20)
        .frame(width: hideDetails ? 470 : 1000,
               height: hideDetails ? 240 : 745,
               alignment: .leading)
    }

    /// Show the crash report window
    public func showWindow() {
        CrashReportController(view: self).showWindow(nil)
    }

    /// Restart the application
    private func restartApplication() {
        if let resourcePath = Bundle.main.resourcePath {
            let url = URL(fileURLWithPath: resourcePath)
            let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = [path]
            task.launch()
            exit(0)
        }
    }

    /// Close the application
    private func closeApplication() {
        NSApplication.shared.terminate(self)
    }
}

struct CrashReportView_Previews: PreviewProvider {
    static var previews: some View {
        CrashReportView(errorDetails: "")
    }
}
