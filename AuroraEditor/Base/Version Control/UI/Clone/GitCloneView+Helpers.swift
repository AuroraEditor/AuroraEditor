//
//  GitCloneView+Helpers.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 6/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension GitCloneView {
    func getPath(modifiable: inout String, saveName: String) -> String? {
        let dialog = NSSavePanel()
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.showsTagField = false
        dialog.prompt = "Clone"
        dialog.nameFieldStringValue = saveName
        dialog.nameFieldLabel = "Clone as"
        dialog.title = "Clone"

        if dialog.runModal() ==  NSApplication.ModalResponse.OK {
            let result = dialog.url

            if result != nil {
                let path: String = result!.path
                // path contains the directory path e.g
                // /Users/ourcodeworld/Desktop/folder
                modifiable = path
                return path
            }
        } else {
            // User clicked on "Cancel"
            return nil
        }
        return nil
    }

    func showAlert(alertMsg: String, infoText: String) {
        let alert = NSAlert()
        alert.messageText = alertMsg
        alert.informativeText = infoText
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning
        alert.runModal()
    }

    func isValid(url: String) -> Bool {
        // Doing the same kind of check that Xcode does when cloning
        let url = url.lowercased()
        if url.starts(with: "http://") && url.count > 7 {
            return true
        } else if url.starts(with: "https://") && url.count > 8 {
            return true
        } else if url.starts(with: "git@") && url.count > 4 {
            return true
        }
        return false
    }

    func checkClipboard(textFieldText: inout String) {
        if let url = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string) {
            if isValid(url: url) {
                textFieldText = url
            }
        }
    }

    func cancelClone(deleteRemains: Bool = false) {
        isPresented = false
        cloneCancellable?.cancel()
        NSApplication.shared.removeDockProgress()

        guard deleteRemains && FileManager.default.fileExists(atPath: repoPathStr) else { return }
        do {
            try FileManager.default.removeItem(atPath: repoPathStr)
        } catch {
            showAlert(alertMsg: "Error", infoText: error.localizedDescription)
        }
    }

    // MARK: Clone repo
    func cloneRepository() { // swiftlint:disable:this function_body_length
        do {
            if repoUrlStr.isEmpty {
                showAlert(alertMsg: "Url cannot be empty",
                          infoText: "You must specify a repository to clone")
                return
            }
            // Parsing repo name
            let repoURL = URL(string: repoUrlStr)
            if var repoName = repoURL?.lastPathComponent {
                // Strip .git from name if it has it.
                // Cloning repository without .git also works
                if repoName.contains(".git") {
                    repoName.removeLast(4)
                }
                guard getPath(modifiable: &repoPath, saveName: repoName) != nil else {
                    return
                }
            } else {
                return
            }
            guard let dirUrl = URL(string: repoPath) else {
                return
            }
            var isDir: ObjCBool = true
            // if the file exists, the user would already have said they were okay with
            // getting rid of it, so just remove it and overwrite it.
            if FileManager.default.fileExists(atPath: repoPath, isDirectory: &isDir) {
                try? FileManager.default.removeItem(atPath: repoPath)
            }
            repoPathStr = repoPath
            try FileManager.default.createDirectory(atPath: repoPath,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            gitClient = GitClient.init(
                directoryURL: dirUrl,
                shellClient: shellClient
            )

            cloneCancellable = gitClient?.cloneRepository(
                path: repoUrlStr,
                branch: selectedBranch,
                allBranches: allBranches
            ).sink(receiveCompletion: { result in
                    switch result {
                    case let .failure(error):
                        switch error {
                        case .notGitRepository:
                            showAlert(alertMsg: "Error", infoText: "Not a git repository")
                        case let .outputError(error):
                            showAlert(alertMsg: "Error", infoText: error)
                        default:
                            showAlert(alertMsg: "Error", infoText: "Failed to decode URL")
                        }
                    case .finished: break
                    }
                }, receiveValue: { result in
                    switch result {
                    case .cloningInto:
                        isCloning = true
                    case let .countingProgress(progress):
                        cloningStage = 0
                        valueCloning = progress
                        NSApplication.shared.setDockProgress(progress: 0.10 * Double(progress) / 100 + 0.0)
                    case let .compressingProgress(progress):
                        cloningStage = 1
                        valueCloning = progress
                        NSApplication.shared.setDockProgress(progress: 0.10 * Double(progress) / 100 + 0.10)
                    case let .receivingProgress(progress):
                        cloningStage = 2
                        valueCloning = progress
                        NSApplication.shared.setDockProgress(progress: 0.30 * Double(progress) / 100 + 0.20)
                    case let .resolvingProgress(progress):
                        cloningStage = 3
                        valueCloning = progress
                        NSApplication.shared.setDockProgress(progress: 0.50 * Double(progress) / 100 + 0.50)
                        if progress >= 100 {
                            cloningStage = 4
                            cloneCancellable?.cancel()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                NSApplication.shared.removeDockProgress()
                                isPresented = false
                                // open the document
                                let repoFileURL = URL(fileURLWithPath: repoPath)
                                Log.info("Opening \(repoFileURL)")
                                AuroraEditorDocumentController.shared.openDocument(
                                    withContentsOf: repoFileURL,
                                    display: true,
                                    completionHandler: { _, _, _ in }
                                )
                                // add to recent projects
                                var recentProjectPaths = (
                                    UserDefaults.standard.array(forKey: "recentProjectPaths") as? [String] ?? []
                                ).filter { FileManager.default.fileExists(atPath: $0) }
                                if let urlLocation = recentProjectPaths.firstIndex(of: repoPath) {
                                    recentProjectPaths.remove(at: urlLocation)
                                }
                                recentProjectPaths.insert(repoPath, at: 0)

                                UserDefaults.standard.set(
                                    recentProjectPaths,
                                    forKey: "recentProjectPaths"
                                )
                            })
                        }
                    case .other: break
                    }
                })
            checkBranches(dirUrl: dirUrl)
        } catch {
            showAlert(alertMsg: "Error", infoText: error.localizedDescription)
        }
    }

    @discardableResult
    private func checkBranches(dirUrl: URL) -> Bool {
        // Check if repo has only one branch, and if so, don't show the checkout page
        do {
            let branches = try GitClient.init(directoryURL: dirUrl,
                                              shellClient: shellClient).getGitBranches(allBranches: true)
            let filtered = branches.filter { !$0.contains("HEAD") }
            if filtered.count > 1 {
                return true
            }

            return false
        } catch {
            return false
        }
    }
}
