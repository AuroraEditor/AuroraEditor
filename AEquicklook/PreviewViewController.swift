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

/// The preview view controller
class PreviewViewController: NSViewController, QLPreviewingController {
    /// Initialize the logger
    let logger = Logger(subsystem: "com.auroraeditor.AEquicklook", category: "PreviewViewController")

    /// The web view
    @IBOutlet var webView: WKWebView?

    /// The nib name
    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }

    /// Load the view
    override func loadView() {
        logger.info("Load View")
        webView?.setValue(true, forKey: "drawsTransparentBackground")
        super.loadView()
    }

    /// Prepare the preview of a file
    /// 
    /// - Parameter url: The URL
    /// - Parameter handler: The handler
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        logger.info("Opening \(url.absoluteString)...")

        if let data = try? Data(contentsOf: url) {
            self.webView?.loadHTMLString(
                QLHighlighter(contents: data).build(),
                baseURL: nil
            )

            logger.info("Loaded HTML")
            handler(nil)
        } else {
            logger.error("Failed to load?")
            handler(NSError(domain: "Failed to load contents", code: 99))
        }
    }
}
