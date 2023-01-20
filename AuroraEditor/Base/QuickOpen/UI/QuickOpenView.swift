//
//  QuickOpenView.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

public struct QuickOpenView: View {
    @ObservedObject private var state: QuickOpenState
    private let onClose: () -> Void
    private let openFile: (FileSystemClient.FileItem) -> Void
    @State private var selectedItem: FileSystemClient.FileItem?

    public init(
        state: QuickOpenState,
        onClose: @escaping () -> Void,
        openFile: @escaping (FileSystemClient.FileItem) -> Void
    ) {
        self.state = state
        self.onClose = onClose
        self.openFile = openFile
    }

    func onKeyDown(with event: NSEvent) -> Bool {
        switch event.keyCode {
        case 125: // down arrow
            selectOffset(by: 1)
            return true

        case 126: // up arrow
            selectOffset(by: -1)
            return true

        case 36: // enter key
            if let selectedItem = selectedItem {
                openFile(selectedItem)
            }
            self.onClose()
            return true

        case 53: // esc key
            self.onClose()
            return true

        default:
            return false
        }
    }

    func onQueryChange(text: String) {
        state.fetchOpenQuickly()
        if !state.isShowingOpenQuicklyFiles {
            selectedItem = nil
        }
    }

    func selectOffset(by offset: Int) {
        guard !state.openQuicklyFiles.isEmpty else { return }

        // check if a command has been selected
        if let selectedItem = selectedItem, let currentIndex = state.openQuicklyFiles.firstIndex(of: selectedItem) {
            // select current index + offset, wrapping around if theres underflow or overflow.
            let newIndex = (currentIndex + offset + state.openQuicklyFiles.count) % (state.openQuicklyFiles.count)
            self.selectedItem = state.openQuicklyFiles[newIndex]
        } else {
            // if theres no selected command, just select the first or last item depending on direction
            selectedItem = state.openQuicklyFiles[ offset < 0 ? state.openQuicklyFiles.count - 1 : 0]
        }
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 12)
                        .offset(x: 0, y: 1)
                    ActionAwareInput(onDown: onKeyDown,
                                     onTextChange: onQueryChange,
                                     text: $state.openQuicklyQuery)
                }
                .padding(16)
                .foregroundColor(.primary.opacity(0.85))
                .background(EffectView(.sidebar, blendingMode: .behindWindow))
            }
            .frame(height: 52)
            if state.isShowingOpenQuicklyFiles {
                Divider()
                NavigationView {
                    ZStack {
                        List(state.openQuicklyFiles, id: \.id) { file in
                            NavigationLink(tag: file, selection: $selectedItem) {
                                QuickOpenPreviewView(item: file)
                            } label: {
                                QuickOpenItem(baseDirectory: state.fileURL, fileItem: file)
                            }
                            .onTapGesture(count: 2) {
                                self.openFile(file)
                                self.onClose()
                            }
                            .onTapGesture(count: 1) {
                                self.selectedItem = file
                            }
                        }
                        .frame(minWidth: 250, maxWidth: 250)
                        if state.openQuicklyFiles.isEmpty {
                            EmptyView()
                        } else {
                            Text("Select a file to preview")
                        }

                        Button("") {
                            if let selectedItem = selectedItem {
                                self.openFile(selectedItem)
                                self.onClose()
                            }
                        }
                        .buttonStyle(.borderless)
                        .keyboardShortcut(.defaultAction)
                    }
                }
            }
        }
        .background(EffectView(.sidebar, blendingMode: .behindWindow))
        .edgesIgnoringSafeArea(.vertical)
        .frame(minWidth: 600,
           minHeight: self.state.isShowingOpenQuicklyFiles ? 400 : 28,
           maxHeight: self.state.isShowingOpenQuicklyFiles ? .infinity : 28)
    }
}

struct QuickOpenView_Previews: PreviewProvider {
    static var previews: some View {
        QuickOpenView(
            state: .init(fileURL: .init(fileURLWithPath: "")),
            onClose: {},
            openFile: { _ in }
        )
    }
}
