//
//  Aurora EditorDocumentController.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 17.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Cocoa
import OSLog

/// A class that manages the document controller.
final class AuroraEditorDocumentController: NSDocumentController {
    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Aurora Editor Document Controller")

    /// Opens a document.
    /// 
    /// - Parameter sender: The sender.
    override func openDocument(_ sender: Any?) {
        self.openDocument(onCompletion: { document, documentWasAlreadyOpen in
            guard let document = document else {
                self.logger.fault("Failed to unwrap document")
                return
            }

            self.logger.info("\(document), \(documentWasAlreadyOpen)")
        }, onCancel: {})
    }

    /// Opens a document.
    /// 
    /// - Parameter withContentsOf: The URL to open.
    /// - Parameter display: Whether to display the document.
    /// - Parameter completionHandler: The completion handler.
    override func openDocument(withContentsOf url: URL,
                               display displayDocument: Bool,
                               completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
        super.openDocument(withContentsOf: url, display: displayDocument) { document, documentWasAlreadyOpen, error in

            if let document = document {
                self.addDocument(document)
            }
            RecentProjectsStore.shared.record(path: url.path)
            completionHandler(document, documentWasAlreadyOpen, error)
        }
    }

    /// Clears the recent documents.
    override func clearRecentDocuments(_ sender: Any?) {
        super.clearRecentDocuments(sender)
        RecentProjectsStore.shared.clearAll()
    }
}

extension NSDocumentController {
    /// Opens a document.
    /// 
    /// - Parameter onCompletion: The completion handler.
    final func openDocument(onCompletion: @escaping (NSDocument?, Bool) -> Void, onCancel: @escaping () -> Void) {
        let logger = Logger(subsystem: "com.auroraeditor", category: "NSDocumentController")

        let dialog = NSOpenPanel()

        dialog.title = "Open Workspace or File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true

        dialog.begin { result in
            if result == NSApplication.ModalResponse.OK, let url = dialog.url {
                self.openDocument(withContentsOf: url, display: true) { document, documentWasAlreadyOpen, error in
                    if let error = error {
                        NSAlert(error: error).runModal()
                        return
                    }

                    guard let document = document else {
                        let alert = NSAlert()
                        alert.messageText = NSLocalizedString("Failed to get document",
                                                              comment: "Failed to get document")
                        alert.runModal()
                        return
                    }
                    RecentProjectsStore.shared.record(path: url.path)
                    onCompletion(document, documentWasAlreadyOpen)
                    logger.info("Document: \(document)")
                    logger.info("Was already open? \(documentWasAlreadyOpen)")
                }
            } else if result == NSApplication.ModalResponse.cancel {
                onCancel()
            }
        }
    }
}
