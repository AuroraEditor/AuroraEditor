//
//  QuickOpenPreviewView.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 20.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

public struct QuickOpenPreviewView: View, Sendable {
    /// Queue
    private let queue = DispatchQueue(label: "com.auroraeditor.quickOpen.preview")

    /// File item
    private let item: FileSystemClient.FileItem

    /// Initialize a new QuickOpenPreviewView
    @State
    private var content: String = ""

    /// Initialize a new QuickOpenPreviewView
    @State
    private var loaded = false

    /// Initialize a new QuickOpenPreviewView
    @State
    private var error: String?

    /// Initialize a new QuickOpenPreviewView
    /// 
    /// - Parameter item: file item
    /// 
    /// - Returns: a new QuickOpenPreviewView
    public init(item: FileSystemClient.FileItem) {
        self.item = item
    }

    /// The view body.
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
