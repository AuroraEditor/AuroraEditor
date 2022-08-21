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
    typealias NSViewType = WKWebView

    @Binding
    var pageURL: URL? // Page to load

    func makeNSView(context: Context) -> WKWebView {
        return WKWebView() // Just make a new WKWebView, we don't need to do anything else here.
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: pageURL!)
        nsView.load(request)     // Send the command to WKWebView to load our page
    }
}
