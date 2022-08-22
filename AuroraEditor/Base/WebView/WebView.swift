//
//  WebView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

// UIViewRepresentable, wraps UIKit views for use with SwiftUI
struct WebView: NSViewRepresentable {
    typealias NSViewType = NSView

    @Binding
    var pageURL: URL? // Page to load

    @Binding
    var updateType: UpdateType

    enum UpdateType {
        case refresh
        case back
        case forward
        case none
    }

    func makeNSView(context: Context) -> NSView {
        let webKitView = WKWebView()

        if let pageURL = pageURL {
            let request = URLRequest(url: pageURL)
            webKitView.load(request)
        }

        return webKitView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let webView = nsView as? WKWebView, let pageURL = pageURL else { return }
        if let currentURL = webView.url, currentURL != pageURL {
            Log.info("Reloading page")
            let request = URLRequest(url: pageURL)
            webView.load(request)     // Send the command to WKWebView to load our page
        }
        Log.info("Update type: \(updateType)")
        switch updateType {
        case .refresh:
            webView.reload()
        case .back:
            webView.goBack()
        case .forward:
            webView.goForward()
        case .none:
            break // nothing to do on none
        }
        if updateType != .none { DispatchQueue.main.async {
            updateType = .none
        }}
    }
}
