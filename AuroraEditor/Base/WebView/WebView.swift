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

    func makeNSView(context: Context) -> NSView {
        let webKitView = WKWebView()

        if let pageURL = pageURL {
            let request = URLRequest(url: pageURL)
            webKitView.load(request)
        }

        return webKitView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let nsView = nsView as? WKWebView, let pageURL = pageURL else { return }
        let request = URLRequest(url: pageURL)
        nsView.load(request)     // Send the command to WKWebView to load our page
    }
}
