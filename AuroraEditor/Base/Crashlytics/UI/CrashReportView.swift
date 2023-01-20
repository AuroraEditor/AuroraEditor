//
//  CrashReportView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/31.
//

import SwiftUI

public struct CrashReportView: View {

    @StateObject
    private var reportModel: CrashReportModel = .shared

    private var prefs: AppPreferencesModel = .shared

    @State
    var errorDetails: String

    @State
    private var hideDetails: Bool = false

    @State
    private var hideComment: Bool = false

    public init(errorDetails: String) {
        self.errorDetails = errorDetails
    }

    public var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 50))

                Spacer()

                HelpButton {
                    Log.info("Help")
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

                    Text("Comments")
                        .font(.system(size: 12))
                }
                .onTapGesture {
                    withAnimation {
                        hideComment.toggle()
                    }
                }
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
                        if prefs.preferences.accounts.sourceControlAccounts.gitAccount.isEmpty {
                            Log.info("Failed to find a github account")
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

    public func showWindow() {
        CrashReportController(view: self).showWindow(nil)
    }

    private func restartApplication() {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }

    private func closeApplication() {
        NSApplication.shared.terminate(self)
    }
}

struct CrashReportView_Previews: PreviewProvider {
    static var previews: some View {
        CrashReportView(errorDetails: "")
    }
}
