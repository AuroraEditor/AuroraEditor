//
//  ExtensionOrWebView.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 11/04/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import WebKit

/// Should we use a extension View or a WebView.
struct ExtensionOrWebView: View {
    let view: Any?

    var body: some View {
        if let swiftUIView = view as? any View {
            // Check if the provided view conforms to any View
            // This means this is a usable view for us.

            AnyView(swiftUIView)
        } else if let webViewContents = view as? String {
            // The view is a String, this can only means that
            // the view is written in HTML/CSS/Javascript.

            ExtensionWKWebView(pageHTML: webViewContents)
        } else {
            // This type, we cannot cast,
            // Either it's empty, or unsupported.

            Text("Failed to cast to view")
        }
    }
}

struct ExtensionWKWebView: NSViewRepresentable {
    typealias NSViewType = NSView

    /// Page to load
    var pageHTML: String?

    func makeNSView(context: Context) -> NSView {
        let webKitView = WKWebView()

        webKitView.navigationDelegate = context.coordinator

        // Configure the webView
        webKitView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
        "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15"

        webKitView.setValue(true, forKey: "drawsTransparentBackground")

        // load the initial page
        loadPage(webView: webKitView, pageHTML: pageHTML)

        return webKitView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // make sure web view and page url exist, and add a delegate
        guard let webView = nsView as? WKWebView else { return }
        webView.navigationDelegate = context.coordinator

        // load the new page
        loadPage(webView: webView, pageHTML: pageHTML)
    }

    /// Convenience function to load a page
    /// - Parameters:
    ///   - webView: The web view
    ///   - url: The URL to load
    func loadPage(webView: WKWebView, pageHTML: String?) {
        // check that the URL is different

        // if the URL is valid (has a protocol), load the page
        if let html = pageHTML {
            // TODO: pass baseURL to support importing of CSS/JS/Images and so on.
            webView.loadHTMLString(html, baseURL: nil)
        } else {
            webView.loadHTMLString("No HTML passed to the view", baseURL: nil)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ExtensionWKWebView

        init(_ parent: ExtensionWKWebView) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
