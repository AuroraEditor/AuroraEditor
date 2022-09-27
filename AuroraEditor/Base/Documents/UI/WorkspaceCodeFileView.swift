//
//  WorkspaceCodeFileEditor.swift
//  AuroraEditor
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI
import UniformTypeIdentifiers

struct WorkspaceCodeFileView: View {
    var windowController: NSWindowController

    @ObservedObject
    var workspace: WorkspaceDocument

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var dropProposal: SplitViewProposalDropPosition?

    @State
    private var font: NSFont = {
        let size = AppPreferencesModel.shared.preferences.textEditing.font.size
        let name = AppPreferencesModel.shared.preferences.textEditing.font.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    @ViewBuilder
    var codeView: some View {
        ZStack {
            if let item = workspace.selectionState.openFileItems.first(where: { file in
                if file.tabID == workspace.selectionState.selectedId {
                    Log.info("Item loaded is: \(file.url)")
                }

                return file.tabID == workspace.selectionState.selectedId
            }) {
                if let fileItem = workspace.selectionState.openedCodeFiles[item] {
                    if fileItem.typeOfFile == .image {
                        imageFileView(fileItem, for: item)
                            .splitView(availablePositions: [.top, .bottom, .center, .leading, .trailing],
                                       proposalPosition: $dropProposal,
                                       margin: 15,
                                       onDrop: { position in
                                switch position {
                                case .top:
                                    Log.info("Dropped at the top")
                                case .bottom:
                                    Log.info("Dropped at the bottom")
                                case .leading:
                                    Log.info("Dropped at the start")
                                case .trailing:
                                    Log.info("Dropped at the end")
                                case .center:
                                    Log.info("Dropped at the center")
                                }
                            })
                    } else {
                        codeEditorView(fileItem, for: item)
                            .splitView(availablePositions: [.top, .bottom, .center, .leading, .trailing],
                                       proposalPosition: $dropProposal,
                                       margin: 15,
                                       onDrop: { position in
                                switch position {
                                case .top:
                                    Log.info("Dropped at the top")
                                case .bottom:
                                    Log.info("Dropped at the bottom")
                                case .leading:
                                    Log.info("Dropped at the start")
                                case .trailing:
                                    Log.info("Dropped at the end")
                                case .center:
                                    Log.info("Dropped at the center")
                                }
                            })
                    }
                }
            } else {
                EmptyEditorView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func codeEditorView(
        _ codeFile: CodeFileDocument,
        for item: FileSystemClient.FileItem
    ) -> some View {
        CodeEditorViewWrapper(codeFile: codeFile)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                    Divider()
                }
            }
    }

    @ViewBuilder
    private func editorView(
        _ codeFile: CodeFileDocument,
        for item: FileSystemClient.FileItem
    ) -> some View {
        EditorViewWrapper(codeFile: codeFile)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                    Divider()
                }
            }
    }

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

    var body: some View {
        codeView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
