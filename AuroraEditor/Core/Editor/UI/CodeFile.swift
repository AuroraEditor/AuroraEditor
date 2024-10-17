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

/// Error for code file.
public enum CodeFileError: Error {
    /// Failed to decode file.
    case failedToDecode

    /// Failed to encode file.
    case failedToEncode

    /// File type error.
    case fileTypeError
}

/// Code file document.
/// 
/// This is a document that can be opened in the editor.
@objc(CodeFileDocument)
@MainActor
public final class CodeFileDocument: NSDocument, ObservableObject, QLPreviewItem {
    /// File content.
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
    nonisolated(unsafe) public var previewItemURL: URL? {
        fileURL
    }

    // MARK: - NSDocument

    /// Auto save in place. [no]
    override public static var autosavesInPlace: Bool {
        false
    }

    /// Make window controllers.
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

        ExtensionsManager.shared.sendEvent(
            event: "didOpen",
            parameters: [
                "file": self.fileURL?.relativeString ?? "Unknown",
                "contents": self.content.data(using: .utf8) ?? Data()
            ]
        )

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

    /// Read from file.
    /// 
    /// - Parameter typeName: The type of the file.
    /// 
    /// - Returns: Data of the file.
    /// 
    /// - Throws: Error if failed to read.
    override public func data(ofType _: String) throws -> Data {
        guard let data = content.data(using: .utf8) else { throw CodeFileError.failedToEncode }
        return data
    }

    /// This fuction is used for decoding files.
    /// It should not throw error as unsupported files can still be opened by QLPreviewView.
    /// 
    /// - Parameter data: The data of the file.
    /// - Parameter typeName: The type of the file.
    /// 
    /// - Throws: Error if failed to read.
    override public func read(from data: Data, ofType _: String) throws {
        if let contents = String(data: data, encoding: .utf8) {
            Task { @MainActor in
                self.content = contents
            }
        }

        throw NSError(domain: "com.auroraeditor.CodeFileDocumentError", code: 1)
    }

    /// Save document. (custom function)
    /// 
    /// This function will save the file, and check if the file is saved correctly.
    /// If the file is not saved correctly, it will throw an fatal error.
    public func saveFileDocument() {
        // TODO: Make the errors non-fatal so that the user can be notified.
        // And restore their work.

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
