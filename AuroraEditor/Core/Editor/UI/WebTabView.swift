//
//  WebTabView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import WebKit

/// Represents a web tab view.
struct WebTabView: View {
    /// Web tab
    @ObservedObject
    var webTab: WebTab

    /// Update type
    @State
    var updateType: WebWKView.UpdateType = .none

    /// Can go back
    @State
    var canGoBack: Bool = false

    /// Can go forward
    @State
    var canGoForward: Bool = false

    /// Navigation failed
    @State
    var navigationFailed: Bool = false

    /// Error message
    @State
    var errorMessage: String = ""

    /// The view body
    var body: some View {
        VStack {
            if #available(macOS 13, *) {
                urlBar
                    .frame(height: 34, alignment: .center)
            } else {
                urlBar
                    .padding(.top, 7)
                    .frame(height: 30, alignment: .center)
            }

            ZStack {
                VStack {
                    Spacer()
                    Text("Web Page Error: \n\"\(errorMessage)\"")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 0)
                        .clipped()
                    Spacer()
                }
                WebWKView(pageURL: $webTab.url,
                          pageTitle: $webTab.title,
                          updateType: $updateType,
                          canGoBack: $canGoBack,
                          canGoForward: $canGoForward,
                          navigationFailed: $navigationFailed,
                          errorMessage: $errorMessage)
                .opacity(navigationFailed ? 0 : 1)
            }
        }
    }

    /// The URL bar
    private var urlBar: some View {
        HStack {
            HStack {
                refreshButton
                    .padding(.leading, 8)
                navigationButtonBack
                navigationButtonForward
                TextField("URL", text: $webTab.address)
                    .onSubmit {
                        webTab.updateURL()
                    }
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
            }
            .padding(.vertical, 3)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5).cornerRadius(6))
            .padding(.trailing, 5)
            .padding(.leading, 5)
        }
        .frame(maxWidth: .infinity)
    }

    /// The refresh button
    private var refreshButton: some View {
        Button {
            updateType = .refresh
        } label: {
            Image(systemName: "arrow.clockwise")
                .accessibilityLabel("Refresh")
        }
        .buttonStyle(.borderless)
        .frame(maxWidth: 10)
    }

    /// The navigation back button
    private var navigationButtonBack: some View {
        Button {
            updateType = .back
        } label: {
            Image(systemName: "chevron.left")
                .accessibilityLabel("Navigate Back")
        }
        .disabled(!canGoBack)
        .buttonStyle(.borderless)
        .frame(maxWidth: 10)
    }

    /// The navigation forward button
    private var navigationButtonForward: some View {
        Button {
            updateType = .forward
        } label: {
            Image(systemName: "chevron.right")
                .accessibilityLabel("Navigate Forward")
        }
        .disabled(!canGoForward)
        .buttonStyle(.borderless)
        .frame(maxWidth: 10)
    }
}

struct WebTabView_Previews: PreviewProvider {
    static var previews: some View {
        WebTabView(webTab: WebTab(
            url: URL(string: "https://auroraeditor.com")))
    }
}
