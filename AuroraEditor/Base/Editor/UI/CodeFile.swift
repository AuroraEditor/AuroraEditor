//
//  CodeFile.swift
//  Aurora Editor
//
//  Created by Rehatbir Singh on 12/03/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers
import QuickLookUI

public enum CodeFileError: Error {
    case failedToDecode
    case failedToEncode
    case fileTypeError
}

@objc(CodeFileDocument)
public final class CodeFileDocument: NSDocument, ObservableObject, QLPreviewItem {

    @Published
    var content = ""

    /// This is the main type of the document.
    /// For example, if the file is end with '.png', it will be an image,
    /// if the file is end with '.py', it will be a text file.
    /// If text content is not empty, return text
    /// If its neither image or text, this could be nil.
    public var typeOfFile: UTType? {
        if !self.content.isEmpty {
            return UTType.text
        }
        guard let fileType = fileType, let type = UTType(filenameExtension: fileType) else {
            return nil
        }
        if type.conforms(to: UTType.image) {
            return UTType.image
        }
        if type.conforms(to: UTType.text) {
            return UTType.text
        }
        return nil
    }

    /// This is the QLPreviewItemURL
    public var previewItemURL: URL? {
        fileURL
    }

    // MARK: - NSDocument

    override public class var autosavesInPlace: Bool {
        false
    }

    override public func makeWindowControllers() {
        // [SwiftUI] Add a "hidden" button to be able to close it with `⌘W`
        var view: some View {
            ZStack {
                Button(
                    action: { self.close() },
                    label: { EmptyView() }
                )
                .frame(width: 0, height: 0)
                .padding(0)
                .opacity(0)
                .keyboardShortcut("w", modifiers: [.command])

                // SINGLE FILE OPEN
                // Pass empty env to prevent crash
                CodeEditorViewWrapper(codeFile: self, editable: true)
                    .environmentObject(WorkspaceDocument())
            }
        }

        for (id, AEExt) in ExtensionsManager.shared.loadedExtensions {
            Log.info(id, "didOpen")
            AEExt.respond(
                action: "didOpen",
                parameters: [
                    "file": self.fileURL?.relativeString ?? "Unknown",
                    "contents": self.content.data(using: .utf8) ?? Data()
                ]
            )
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1400, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.center()
        window.contentView = NSHostingView(rootView: view)
        let windowController = NSWindowController(window: window)
        addWindowController(windowController)
    }

    override public func data(ofType _: String) throws -> Data {
        guard let data = content.data(using: .utf8) else { throw CodeFileError.failedToEncode }
        return data
    }

    /// This fuction is used for decoding files.
    /// It should not throw error as unsupported files can still be opened by QLPreviewView.
    override public func read(from data: Data, ofType _: String) throws {
        guard let content = String(data: data, encoding: .utf8) else { return }
        self.content = content
    }

    /// Save document. (custom function)
    public func saveFileDocument() {
        guard let url = self.fileURL,
              let contents = content.data(using: .utf8) else {
            fatalError("\(#function): Failed to get URL and file type.")
        }

        do {
            try contents.write(to: url, options: .atomic)

            let newContents = try? Data(contentsOf: url)
            if newContents != contents {
                fatalError("Saving did not update the file.")
            }
        } catch {
            fatalError("\(#function): Failed to save, \(error.localizedDescription)")
        }
    }
}
