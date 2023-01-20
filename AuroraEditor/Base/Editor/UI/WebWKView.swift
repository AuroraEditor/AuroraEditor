//
//  WebView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

// UIViewRepresentable, wraps UIKit views for use with SwiftUI
struct WebWKView: NSViewRepresentable {
    typealias NSViewType = NSView

    /// Page to load
    @Binding
    var pageURL: URL?

    /// Page title
    @Binding
    var pageTitle: String

    /// The type of update. Used on reload, back and forward navigation
    @Binding
    var updateType: UpdateType

    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool

    @Binding var navigationFailed: Bool
    @Binding var errorMessage: String

    /// The type of update. Used on reload, back and forward navigation
    enum UpdateType {
        case refresh
        case back
        case forward
        case none
    }

    func makeNSView(context: Context) -> NSView {
        let webKitView = WKWebView()
        webKitView.navigationDelegate = context.coordinator

        // Configure the webView
        webKitView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
        "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15"

        // load the initial page
        loadPage(webView: webKitView, url: pageURL)

        return webKitView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // make sure web view and page url exist, and add a delegate
        guard let webView = nsView as? WKWebView, let pageURL = pageURL else { return }
        webView.navigationDelegate = context.coordinator

        // load the new page
        loadPage(webView: webView, url: pageURL)

        // if there was an update (eg. refres, back, forward) then do the relevant action
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

        // set updateType back to none
        if updateType != .none { DispatchQueue.main.async {
            updateType = .none
        }}
    }

    /// Convenience function to load a page
    /// - Parameters:
    ///   - webView: The web view
    ///   - url: The URL to load
    func loadPage(webView: WKWebView, url: URL?) {
        // check that the URL is different
        if webView.url != nil && webView.url?.debugDescription == url?.debugDescription {
            return
        }

        // if the URL is valid (has a protocol), load the page
        if let url = url, url.debugDescription.range(of: "^.+://",
                                                     options: .regularExpression,
                                                     range: nil, locale: nil) != nil {
            let request = URLRequest(url: url)
            // Send the command to WKWebView to load our page
            webView.load(request)
        } else {
            DispatchQueue.main.async {
                self.navigationFailed = true
                self.errorMessage = url == nil ? "No URL" : "Invalid URL"
            }
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebWKView

        init(_ parent: WebWKView) {
            self.parent = parent
        }

        /// On navigation failure, show the error
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.navigationFailed = true
            parent.errorMessage = error.localizedDescription
        }

        /// Update page title, url, and various statuses when web view finished navigation
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.pageTitle = webView.title ?? (webView.url?.relativePath ?? "Unknown")
            parent.pageURL = webView.url
            parent.canGoForward = webView.canGoForward
            parent.canGoBack = webView.canGoBack
            parent.navigationFailed = false
            parent.errorMessage = "No Error"
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
