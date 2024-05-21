//
//  PreviewViewController.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 21/05/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Cocoa
import Quartz
import WebKit
import OSLog

class PreviewViewController: NSViewController, QLPreviewingController {
    let logger = Logger(subsystem: "com.auroraeditor.AEquicklook", category: "PreviewViewController")

    @IBOutlet var webView: WKWebView?

    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }

    override func loadView() {
        logger.info("Load View")
        webView?.setValue(true, forKey: "drawsTransparentBackground")
        super.loadView()
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        logger.info("Opening \(url.absoluteString)...")

        if let data = try? Data(contentsOf: url) {
            self.webView?.loadHTMLString(
                QLHighlighter(contents: data).build(),
                baseURL: nil
            )

            logger.info("Loaded HTML")
            dump(QLHighlighter(contents: data).build())
            handler(nil)
        } else {
            logger.error("Failed to load?")
            handler(NSError(domain: "Failed to load contents", code: 99))
        }
    }
}
