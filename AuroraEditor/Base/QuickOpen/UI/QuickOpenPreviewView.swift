//
//  QuickOpenPreviewView.swift
//  AuroraEditorModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

public struct QuickOpenPreviewView: View {
    private let queue = DispatchQueue(label: "com.auroraeditor.quickOpen.preview")
    private let item: FileSystemClient.FileItem
    @State private var content: String = ""
    @State private var loaded = false
    @State private var error: String?

    public init(
        item: FileSystemClient.FileItem
    ) {
        self.item = item
    }

    public var body: some View {
        VStack {
            if let codeFile = try? CodeFileDocument(
                for: item.url,
                withContentsOf: item.url,
                ofType: "public.source-code"
            ), loaded {
                // "Quick Look" function, need to pass a empty env here as well.
                CodeEditorViewWrapper(
                    codeFile: codeFile,
                    editable: false,
                    fileExtension: item.url.pathExtension
                ).environmentObject(WorkspaceDocument())
            } else if let error = error {
                Text(error)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loaded = false
            error = nil
            queue.async {
                do {
                    let data = try String(contentsOf: item.url)
                    DispatchQueue.main.async {
                        self.content = data
                        self.loaded = true
                    }
                } catch let error {
                    self.error = error.localizedDescription
                }
            }
        }
    }
}
