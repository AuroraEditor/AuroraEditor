//
//  RecentProjectsView.swift
//  AuroraEditorModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//
import SwiftUI

public struct RecentProjectsView: View {

    @ObservedObject private var recentsStore: RecentProjectsStore = .shared
    @State private var selectedProjectPath: String? = ""

    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let dismissWindow: () -> Void

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

    func contextMenuCopy(path: String) -> some View {
        Group {
            Button("Copy Path") {
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(path, forType: .string)
            }
        }
    }

    func contextMenuDelete(projectPath: String) -> some View {
        Group {
            Button("Remove from Recent Projects") {
                withAnimation { recentsStore.remove(path: projectPath) }
            }
        }
    }

    func openDocument(for url: String) {
        Log.info("Opening document: \(url)")
        openDocument(URL(fileURLWithPath: url), dismissWindow)
        withAnimation { recentsStore.record(path: url) }
    }

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
