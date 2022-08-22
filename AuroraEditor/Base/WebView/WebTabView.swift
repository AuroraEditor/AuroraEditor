//
//  WebTabView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import WebKit

struct WebTabView: View {

    @ObservedObject var webTab: WebTab

    var body: some View {
        VStack {
            HStack {
                HStack {
                    refreshButton
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
            .padding(.top, 8)
            .frame(height: 25, alignment: .center)
            .frame(maxWidth: .infinity)

            if webTab.url != nil {
                WebView(pageURL: $webTab.url)
            } else {
                HStack {
                    Spacer()
                    Text("Invalid Web Page")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 0)
                        .clipped()
                    Spacer()
                }
            }
        }
    }

    private var refreshButton: some View {
        Button {
            // refresh the web view
        } label: {
            Image(systemName: "plus")
        }
        .buttonStyle(.borderless)
        .frame(maxWidth: 30)
    }
}

struct WebTabView_Previews: PreviewProvider {
    static var previews: some View {
        WebTabView(webTab: WebTab(
            url: URL(string: "https://auroraeditor.com")))
    }
}
