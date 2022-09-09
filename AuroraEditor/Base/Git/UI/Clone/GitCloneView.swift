//
//  GitCloneView.swift
//  AuroraEditorModules/Git
//
//  Created by Aleksi Puttonen on 23.3.2022.
//

import SwiftUI
import Foundation
import Combine

// swiftlint:disable:next type_body_length
public struct GitCloneView: View {
    let shellClient: ShellClient
    @Binding var isPresented: Bool
    @Binding var repoPath: String
    @State var showCheckout: Bool = false
    @State var repoUrlStr: String = ""                      // the repo string that the user inputs
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
    @State private var showingSheetVerify = false
    @State private var showingSheetSettings = false
    @State private var showingSheetError = false
    @State private var check = 0

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

                HStack {
                    Button("Cancel") {
                        cancelClone()
                    }
                    Button("Clone") {
                        check = 0
                        showingSheetError = false
                        showingSheetVerify = true
                    }
                    .sheet(isPresented: $showingSheetVerify) {
                        progressVerifyView
                    }
                    .sheet(isPresented: $showingSheetSettings) {
                        selectView
                    }
                    .sheet(isPresented: $showingSheetError) {
                        errorView
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
        }
    }

    func getRemoteHead(url: String) {
        do {
            let branch = try Remote().getRemoteHEAD(url: url)
            Log.info(branch)
            if branch[0].contains("fatal:") {
                Log.info("Error: getRemoteHead")
                showingSheetError = true
            } else {
                self.mainBranch = branch[0]
                self.selectedBranch = branch[0]
                self.check += 1
                Log.info(check)
                if check == 2 {
                    showingSheetVerify = false
                    showingSheetSettings = true
                }
            }
        } catch {
            Log.error("Failed to find main branch name.")
        }
    }

    func getRemoteBranch(url: String) {
        do {
            let branches = try Remote().getRemoteBranch(url: url)
            Log.info(branches)
            if branches[0].contains("fatal:") {
                Log.info("Error: getRemoteBranch")
                showingSheetError = true
            } else {
                self.arrayBranch = branches
                self.check += 1
                Log.info(check)
                if check == 2 {
                    showingSheetVerify = false
                    showingSheetSettings = true
                }
            }
        } catch {
            Log.error("Failed to find branches.")
        }
    }

    public var selectView: some View {
        HStack {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.bottom, 50)
            VStack(alignment: .leading) {
                Text("Clone a repository")
                    .bold()
                    .padding(.bottom, 2)

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
                        showingSheetSettings = false
                        self.check = 0
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
        .frame(width: 400, height: 180)
    }

    public var progressVerifyView: some View {
        HStack {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.bottom, 50)
            VStack(alignment: .leading) {
                Text("Verifying \""+repoUrlStr+"\"")
                    .bold()
                    .padding(.bottom, 2)

                Text("Preparing to clone...")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle())

                HStack {
                    Button("Cancel") {
                        showingSheetVerify = false
                    }
                }
                .offset(x: 315)
                .alignmentGuide(.leading) { context in
                    context[.leading]
                }
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .frame(width: 500, height: 150)
        .onAppear {
            getRemoteHead(url: repoUrlStr)
            getRemoteBranch(url: repoUrlStr)
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

    public var errorView: some View {
        HStack {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.bottom, 50)
            VStack(alignment: .leading) {
                Text("Error")
                    .bold()
                    .padding(.bottom, 2)

                HStack {
                    Button("Cancel") {
                        showingSheetVerify = false
                        showingSheetSettings = false
                        showingSheetError = false
                        check = 0
                    }.keyboardShortcut(.defaultAction)
                }.alignmentGuide(.leading) { context in
                    context[.leading]
                }
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
