//
//  ExtensionOrWebView.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 11/04/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import WebKit
import OSLog
import DynamicUI

/// Should we use a extension View or a WebView.
struct ExtensionCustomView: View {
    let logger = Logger(
        subsystem: "com.auroraeditor.extensions",
        category: "ExtensionCustomView"
    )

    /// The view to show
    let view: Any?

    /// The sender of the view
    let sender: String

    @State
    var didLoadPage = false

    @State
    var didFailToLoadPage = false

    /// Initialize the view
    var body: some View {
        if let swiftUIView = view as? any View {
            // Check if the provided view conforms to any View
            // This means this is a usable view for us.

            AnyView(swiftUIView)
                .onAppear {
                    ExtensionsManager.shared.sendEvent(
                        event: "didOpenExtensionView",
                        parameters: [
                            "type": "SwiftUI",
                            "extension": sender,
                            "view": swiftUIView
                        ]
                    )
                }
        } else if let viewArray = view as? NSArray,
                  let json = try? JSONSerialization.data(withJSONObject: viewArray, options: .prettyPrinted) {
            // If a extension developer used view: [ ... components ... ] it will be casted as __NSArrayM
            // Which is an Mutable NSArray, which we cast to NSArray (Since we don't need to change it)
            // And then convert it to JSON Data.

            dynamicJSONView(json: json)
        } else if let string = view as? String,
                  let json = string.data(using: .utf8),
                  (
                    try? JSONDecoder().decode([DynamicUIComponent].self, from: json)
                  ) != nil {
            // If the extension developer used view: " ... viewdata " (AKA String), we change the string to data
            // And do a pre-check if it conforms to ``DynamicUIComponent``

            dynamicJSONView(json: json)
        } else if let webViewContents = view as? String,
                  webViewContents.contains("<"),
                  webViewContents.contains(">") {
            // The view is a String, this can only means that
            // the view is written in HTML/CSS/Javascript.

            ZStack {
                ExtensionWKWebView(
                    pageHTML: webViewContents,
                    sender: sender,
                    didLoadPage: $didLoadPage,
                    didFailToLoadPage: $didFailToLoadPage
                )
                .opacity(didLoadPage ? 1 : 0)
                .onAppear {
                    ExtensionsManager.shared.sendEvent(
                        event: "didOpenExtensionView",
                        parameters: [
                            "type": "WebView",
                            "extension": sender,
                            "view": webViewContents
                        ]
                    )
                }

                VStack {
                    ProgressView()
                        .frame(width: 150, height: 150)
                        .controlSize(.large)
                        .padding()

                    Text("Generating interface...")
                }
                .opacity(
                    didFailToLoadPage
                    // did fail to load
                    ? 1 : (
                        // did we load?
                        didLoadPage ? 0 : 1
                    )
                )

                if #available(macOS 14.0, *) {
                    ContentUnavailableView(
                        "Failed to load view",
                        systemImage: "exclamationmark.arrow.triangle.2.circlepath",
                        description: Text("Please try to load this window again.")
                    )
                    .opacity(didFailToLoadPage ? 1 : 0)
                }
            }
        } else {
            // This type, we cannot cast,
            // Either it's empty, or unsupported.

            Text("Failed to cast to view")
                .onAppear {
                    ExtensionsManager.shared.sendEvent(
                        event: "didFailToOpenExtensionView",
                        parameters: [
                            "type": "Unknown",
                            "extension": sender,
                            "view": view ?? ("" as Any)
                        ]
                    )
                }
        }
    }

    /// call `DynamicUI` with all required parameters
    ///
    /// - Parameter json: JSON input data
    ///
    /// - Returns: DynamicUI view
    func dynamicJSONView(json: Data) -> some View {
        DynamicUI(
            json: json,
            callback: { component in
                let eventHandler = component.eventHandler ?? "uiElementChanged"

                guard let data = try? JSONEncoder().encode(component),
                      let view = String(data: json, encoding: .utf8) else {
                    ExtensionsManager.shared.sendEvent(
                        event: eventHandler,
                        parameters: [
                            "extension": sender,
                            "view": view
                        ]
                    )

                    return
                }

                ExtensionsManager.shared.sendEvent(
                    event: eventHandler,
                    parameters: [
                        "extension": sender,
                        "view": String(data: json, encoding: .utf8) ?? "Unknown view",
                        "component": String(data: data, encoding: .utf8) ?? "Unknown component"
                    ]
                )
            }
        )
        .onAppear {
            ExtensionsManager.shared.sendEvent(
                event: "didOpenExtensionView",
                parameters: [
                    "type": "DynamicUI",
                    "extension": sender,
                    "view": String(data: json, encoding: .utf8) ?? "Unknown view"
                ]
            )
        }
    }
}

/// WKWebView for extensions
struct ExtensionWKWebView: NSViewRepresentable {
    typealias NSViewType = NSView

    /// Page to load
    var pageHTML: String?

    /// Sender of the view
    var sender: String

    @Binding
    var didLoadPage: Bool

    @Binding
    var didFailToLoadPage: Bool

    /// Logger
    let logger = Logger(
        subsystem: "com.auroraeditor.extensions",
        category: "Extension WKWebView"
    )

    /// Create the NSView
    ///
    /// - Parameter context: Context
    ///
    /// - Returns: The NSView
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

    /// Update the NSView
    ///
    /// - Parameter nsView: The NSView
    /// - Parameter context: The context
    func updateNSView(_ nsView: NSView, context: Context) {
        // make sure web view and page url exist, and add a delegate
        guard let webView = nsView as? WKWebView else { return }
        webView.navigationDelegate = context.coordinator

        // load the new page
        loadPage(webView: webView, pageHTML: pageHTML)
    }

    /// Convenience function to load a page
    ///
    /// - Parameters:
    ///   - webView: The web view
    ///   - url: The URL to load
    func loadPage(webView: WKWebView, pageHTML: String?) {
        // We start a new request, we did not load or fail the page (yet)
        self.didLoadPage = false
        self.didFailToLoadPage = false

        // Get the Base URL for the extension
        let baseURL = ExtensionsManager.shared.extensionsFolder.appendingPathComponent(
            sender + ".JSext",
            isDirectory: true
        )

        // if the URL is valid (has a protocol), load the page
        if let html = pageHTML {
            // Allow access to the extension directory.
            webView.loadFileURL(baseURL, allowingReadAccessTo: baseURL)

            // Load the HTML String.
            webView.loadHTMLString(html, baseURL: baseURL)
        } else {
            // We did fail to load.
            self.didFailToLoadPage = true
        }
    }

    /// Coordinator
    class Coordinator: NSObject, WKNavigationDelegate {
        /// Parent
        var parent: ExtensionWKWebView

        /// Initialize the coordinator
        ///
        /// - Parameter parent: Parent
        init(_ parent: ExtensionWKWebView) {
            self.parent = parent
        }

        deinit {
            Task { @MainActor in
                // We unload the extension view.
                ExtensionsManager.shared.sendEvent(
                    event: "didCloseExtensionView",
                    parameters: [
                        "type": "WebView",
                        "extension": parent.sender,
                        "view": parent.pageHTML ?? ""
                    ]
                )
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
            // We did load the page without error.
            self.parent.didLoadPage = true
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: any Error) {
            // We did fail to load the page.
            self.parent.didFailToLoadPage = true
        }
    }

    /// Make coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
