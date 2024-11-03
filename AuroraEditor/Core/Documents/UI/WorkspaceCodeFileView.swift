//
//  WorkspaceCodeFileEditor.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 20.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers
import OSLog

/// A view that represents the code file editor in the workspace.
struct WorkspaceCodeFileView: View {
    /// The workspace document
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// The preferences model
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// The drop proposal
    @State
    private var dropProposal: SplitViewProposalDropPosition?

    /// The font
    @State
    private var font: NSFont = {
        let size = AppPreferencesModel.shared.preferences.editorFont.size
        let name = AppPreferencesModel.shared.preferences.editorFont.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    /// Logger
    let logger: Logger

    let extensionManager = ExtensionsManager.shared

    init() {
        self.logger = Logger(subsystem: "com.auroraeditor", category: "Workspace Code File View")
    }

    /// The code view
    @ViewBuilder
    var codeView: some View {
        ZStack {
            if let item = workspace.selectionState.openFileItems.first(where: { file in
                if file.tabID == workspace.selectionState.selectedId {
                    self.logger.info("Item loaded is: \(file.url)")
                }

                return file.tabID == workspace.selectionState.selectedId
            }) {
                // openFileItems
                if let fileItem = workspace.selectionState.openedCodeFiles[item] {
                    if fileItem.typeOfFile == .image {
                        imageFileView(fileItem, for: item)
                            .splitView(availablePositions: [.top, .bottom, .center, .leading, .trailing],
                                       proposalPosition: $dropProposal,
                                       margin: 15,
                                       onDrop: { position, _ in
                                switch position {
                                case .top:
                                    self.logger.info("Dropped at the top")
                                case .bottom:
                                    self.logger.info("Dropped at the bottom")
                                case .leading:
                                    self.logger.info("Dropped at the start")
                                case .trailing:
                                    self.logger.info("Dropped at the end")
                                case .center:
                                    self.logger.info("Dropped at the center")
                                }
                            })
                            .log {
                                self.logger.info("Image file view")
                            }
                    } else if let view = extensionManager.canBuildEditor(for: item) {
                        ExtensionCustomView(
                            view: view,
                            sender: "WorkspaceCodeFileView"
                        )
                        .log {
                            self.logger.info("Custom extension view")
                        }
                    } else {
                        CodeEditorViewWrapper(codeFile: fileItem, fileExtension: item.url.pathExtension)
                            .log {
                                self.logger.info("CodeEditorViewWrapper view")
                            }
                            .safeAreaInset(edge: .top, spacing: 0) {
                                VStack(spacing: 0) {
                                    BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                                    Divider()
                                }
                            }
                            .splitView(availablePositions: [.top, .bottom, .center, .leading, .trailing],
                                       proposalPosition: $dropProposal,
                                       margin: 15,
                                       onDrop: { position, _ in
                                switch position {
                                case .top:
                                    self.logger.info("Dropped at the top")
                                case .bottom:
                                    self.logger.info("Dropped at the bottom")
                                case .leading:
                                    self.logger.info("Dropped at the start")
                                case .trailing:
                                    self.logger.info("Dropped at the end")
                                case .center:
                                    self.logger.info("Dropped at the center")
                                }
                            })
                    }
                }
            } else {
                EmptyEditorView()
                    .log {
                        self.logger.info("Empty editor view")
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Image file view
    ///
    /// - Parameter otherFile: The code file document
    /// - Parameter item: The file item
    @ViewBuilder
    private func imageFileView(
        _ otherFile: CodeFileDocument,
        for item: FileSystemClient.FileItem
    ) -> some View {
        ZStack {
            if let url = otherFile.previewItemURL,
               let image = NSImage(contentsOf: url),
               otherFile.typeOfFile == .image {
                GeometryReader { proxy in
                    if image.size.width > proxy.size.width || image.size.height > proxy.size.height {
                        OtherFileView(otherFile)
                    } else {
                        OtherFileView(otherFile)
                            .frame(width: image.size.width, height: image.size.height)
                            .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
                    }
                }
            } else {
                OtherFileView(otherFile)
            }
        }.safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                Divider()
            }
        }
    }

    /// The view body
    var body: some View {
        codeView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
