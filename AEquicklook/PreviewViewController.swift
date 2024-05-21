//
//  PreviewViewController.swift
//  AEquicklook
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
        super.loadView()
    }


    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        logger.info("Opening \(url.absoluteString)...")

        if let data = try? Data.init(contentsOf: url) {
            var html = "<html><style>"
            html += "html,head,body{padding:0;margin:0}pre{width:100vw;height:100vh}"
            html += QLHighlighter().css
            html += "</style><pre><code>"
            html += "/// AURORA EDITOR QUICK LOOK\r\n"
            html += "/// - BETA -\r\n"
            html += String(data: data, encoding: .utf8) ?? "Failed to load"
            html += "</code></pre>"
            html += "<script>" + QLHighlighter().javaScript + ";hljs.highlightAll();</script>"
            html += "</html>"

            self.webView?.loadHTMLString(
                html,
                baseURL: nil
            )

            logger.info("Loaded WV")
            handler(nil)
        } else {
            logger.error("Failed to load?")
            handler(NSError(domain: "Failed to load contents", code: 99))
        }
    }
}
