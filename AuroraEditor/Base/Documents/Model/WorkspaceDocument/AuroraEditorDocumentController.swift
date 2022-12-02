//
//  AuroraEditorDocumentController.swift
//  AuroraEditor
//
//  Created by Pavel Kasila on 17.03.22.
//

import Cocoa

final class AuroraEditorDocumentController: NSDocumentController {
    override func openDocument(_ sender: Any?) {
        self.openDocument(onCompletion: { document, documentWasAlreadyOpen in
            guard let document = document else {
                Log.error("Failed to unwrap document")
                return
            }

            Log.info(document, documentWasAlreadyOpen)
        }, onCancel: {})
    }

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

    override func removeDocument(_ document: NSDocument) {
        super.removeDocument(document)
    }

    override func clearRecentDocuments(_ sender: Any?) {
        super.clearRecentDocuments(sender)
        RecentProjectsStore.shared.clearAll()
    }
}

extension NSDocumentController {
    final func openDocument(onCompletion: @escaping (NSDocument?, Bool) -> Void, onCancel: @escaping () -> Void) {
        let dialog = NSOpenPanel()

        dialog.title = "Open Workspace or File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true

        dialog.begin { result in
            if result ==  NSApplication.ModalResponse.OK, let url = dialog.url {
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
                    Log.info("Document:", document)
                    Log.info("Was already open?", documentWasAlreadyOpen)
                }
            } else if result == NSApplication.ModalResponse.cancel {
                onCancel()
            }
        }
    }
}
