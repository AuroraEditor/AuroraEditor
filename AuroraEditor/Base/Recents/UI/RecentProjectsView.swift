//
//  RecentProjectsView.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// This view creates a list of recent projects that have been
public struct RecentProjectsView: View {
    /// The recent projects store
    @ObservedObject
    private var recentsStore: RecentProjectsStore = .shared

    /// The selected project path
    @State
    private var selectedProjectPath: String? = ""

    /// Open document closure
    private let openDocument: (URL?, @escaping () -> Void) -> Void

    /// Dismiss window closure
    private let dismissWindow: () -> Void

    /// Initialize a new RecentProjectsView
    /// 
    /// - Parameter openDocument: open document closure
    /// - Parameter dismissWindow: dismiss window closure
    /// 
    /// - Returns: a new RecentProjectsView
    public init(
        openDocument: @escaping (URL?, @escaping () -> Void) -> Void,
        dismissWindow: @escaping () -> Void
    ) {
        self.openDocument = openDocument
        self.dismissWindow = dismissWindow
    }

    // If there is a no recent projects opened we
    // will show this view.
    private var emptyView: some View {
        VStack {
            Spacer()
            Text("No Recent Projects")
                .font(.system(size: 20))
            Spacer()
        }
    }

    // MARK: Context Menu Items
    /// Context menu item to show the project in Finder
    /// 
    /// - Parameter projectPath: the path of the project
    /// 
    /// - Returns: a new view
    func contextMenuShowInFinder(projectPath: String) -> some View {
        Group {
            Button("Show in Finder") {
                guard let url = URL(string: "file://\(projectPath)") else {
                    return
                }

                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        }
    }

    /// Context menu item to copy the path of the project
    /// 
    /// - Parameter path: the path of the project
    /// 
    /// - Returns: a new view
    func contextMenuCopy(path: String) -> some View {
        Group {
            Button("Copy Path") {
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(path, forType: .string)
            }
        }
    }

    /// Context menu item to delete the project from the recent projects
    /// 
    /// - Parameter projectPath: the path of the project
    /// 
    /// - Returns: a new view
    func contextMenuDelete(projectPath: String) -> some View {
        Group {
            Button("Remove from Recent Projects") {
                withAnimation { recentsStore.remove(path: projectPath) }
            }
        }
    }

    /// Open the document
    /// 
    /// - Parameter url: the url of the document
    func openDocument(for url: String) {
        Log.info("Opening document: \(url)")
        openDocument(URL(fileURLWithPath: url), dismissWindow)
        withAnimation { recentsStore.record(path: url) }
    }

    /// The view body.
    public var body: some View {
        VStack(alignment: !recentsStore.paths.isEmpty ? .leading : .center, spacing: 10) {
            if !recentsStore.paths.isEmpty {
                List(recentsStore.paths, id: \.self, selection: $selectedProjectPath) { projectPath in
                    ZStack {
                        RecentProjectItem(projectPath: projectPath)
                            .frame(width: 300)
                            .gesture(TapGesture(count: 2).onEnded {
                                openDocument(for: projectPath)
                            })
                            .simultaneousGesture(TapGesture().onEnded {
                                selectedProjectPath = projectPath
                            })
                            .contextMenu {
                                contextMenuShowInFinder(projectPath: projectPath)
                                contextMenuCopy(path: projectPath)
                                    .keyboardShortcut(.init("C", modifiers: [.command]))

                                Divider()
                                contextMenuDelete(projectPath: projectPath)
                                    .keyboardShortcut(.init(.delete))
                            }

                        if selectedProjectPath == projectPath {
                            Button("") {
                                recentsStore.remove(path: projectPath)
                            }
                            .buttonStyle(.borderless)
                            .keyboardShortcut(.init(.delete))

                            Button("") {
                                let pasteboard = NSPasteboard.general
                                pasteboard.declareTypes([.string], owner: nil)
                                pasteboard.setString(projectPath, forType: .string)
                            }
                            .buttonStyle(.borderless)
                            .keyboardShortcut(.init("C", modifiers: [.command]))
                        }

                        Button("") {
                            if let selectedProjectPath = selectedProjectPath {
                                openDocument(for: selectedProjectPath)
                            }
                        }
                        .buttonStyle(.borderless)
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .listStyle(.sidebar)
            } else {
                emptyView
            }
        }
        .frame(width: 300)
        .background(
            EffectView(
                NSVisualEffectView.Material.underWindowBackground,
                blendingMode: NSVisualEffectView.BlendingMode.behindWindow
            )
        )
    }
}

struct RecentProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentProjectsView(openDocument: { _, _ in }, dismissWindow: {})
    }
}
