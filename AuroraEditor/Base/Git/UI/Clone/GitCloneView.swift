//
//  GitCloneView.swift
//  AuroraEditorModules/Git
//
//  Created by Aleksi Puttonen on 23.3.2022.
//

import SwiftUI
import Foundation
import Combine

public struct GitCloneView: View {
    let shellClient: ShellClient
    @Binding var isPresented: Bool
    @Binding var repoPath: String
    @State var showCheckout: Bool = false
    @State var repoUrlStr = ""                      // the repo string that the user inputs
    @State var gitClient: GitClient?
    @State var cloneCancellable: AnyCancellable?    // the publisher for the cloning progress

    // the path that the repo is actually going to be cloned to
    // used if the user presses cancel, to get rid of the half-cloned repo.
    @State var repoPathStr = ""

    @State var isCloning: Bool = false
    @State var cloningStage: Int = 0    // 0 through 4, depending on the stage that cloning is at
    @State var valueCloning: Int = 0    // The percentage of the current stage that is complete

    private var progressLabels = [      // the labels for each cloning stage
        "Counting Progress",
        "Compressing Progress",
        "Receiving Progress",
        "Resolving Progress"
    ]

    @State var allBranches = true
    @State var arrayBranch: [String] = []
    @State var mainBranch: String = ""
    @State var selectedBranch: String = ""

    public init(
        shellClient: ShellClient,
        isPresented: Binding<Bool>,
        repoPath: Binding<String>
    ) {
        self.shellClient = shellClient
        self._isPresented = isPresented
        self._repoPath = repoPath
    }

    public var body: some View {
        if showCheckout {
            CheckoutBranchView(
                isPresented: $showCheckout,
                repoPath: $repoPath,
                shellClient: shellClient
            )
        } else {
            if !isCloning {
                cloneView
            } else {
                progressView
            }
        }
    }

    public var cloneView: some View {
        HStack {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.bottom, 50)
            VStack(alignment: .leading) {
                Text("Clone a repository")
                    .bold()
                    .padding(.bottom, 2)
                Text("Enter a git repository URL:")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .alignmentGuide(.trailing) { context in
                        context[.trailing]
                    }
                TextField("Git Repository URL", text: $repoUrlStr)
                    .lineLimit(1)
                    .padding(.bottom, 5)
                    .frame(width: 300)
                    .onSubmit {
                        cloneRepository()
                    }
                Toggle("Clone all branches", isOn: $allBranches)
                if  allBranches  && !arrayBranch.isEmpty {
                    Picker("Checkout", selection: $selectedBranch) {
                        ForEach(arrayBranch, id: \.self) {
                            Text($0)
                        }
                    }
                }
                if  !allBranches  && !arrayBranch.isEmpty {
                    Picker("Branch", selection: $selectedBranch) {
                        ForEach(arrayBranch, id: \.self) {
                            Text($0)
                        }
                    }
                }
                HStack {
                    Button("Cancel") {
                        cancelClone()
                    }
                    Button("Clone") {
                        cloneRepository()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!isValid(url: repoUrlStr))
                }
                .offset(x: 185)
                .alignmentGuide(.leading) { context in
                    context[.leading]
                }
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .onAppear {
            self.checkClipboard(textFieldText: &repoUrlStr)
            if let url = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string) {
                if isValid(url: url) {
                    getRemoteHead(url: url)
                    getRemoteBranch(url: url)
                }
            }
        }
    }

    func getRemoteHead(url: String) {
        do {
            let branch = try Branches().getRemoteHead(url: url)
            Log.info(branch)
            if branch[0].contains("fatal:") {
                Log.info("Error: getRemoteHead")
            } else {
                self.mainBranch = branch[0]
                self.selectedBranch = branch[0]
            }
        } catch {
            Log.error("Failed to find main branch name.")
        }
    }

    func getRemoteBranch(url: String) {
        do {
            let branches = try Branches().getRemoteBranch(url: url)
            Log.info(branches)
            if branches[0].contains("fatal:") {
                Log.info("Error: getRemoteBranch")
            } else {
                self.arrayBranch = branches
            }
        } catch {
            Log.error("Failed to find branches.")
        }
    }

    public var progressView: some View {
        VStack(alignment: .leading) {
            Text("Cloning \""+repoUrlStr+"\"")
                .bold()
                .padding(.bottom, 2)

            if cloningStage != 4 {
                Text("\(progressLabels[cloningStage]): \(valueCloning)% (\(cloningStage+1)/4)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            } else {
                Text("Finished Cloning")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }

            ProgressView(value: Float(valueCloning)/100.0)
                .progressViewStyle(LinearProgressViewStyle())

            HStack {
                Button("Cancel") {
                    cancelClone(deleteRemains: true)
                }
            }
            .offset(x: 315)
            .alignmentGuide(.leading) { context in
                context[.leading]
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
