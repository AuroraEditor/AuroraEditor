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

    @State var updateType: WebView.UpdateType = .none

    var body: some View {
        VStack {
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
            .padding(.top, 8)
            .frame(height: 25, alignment: .center)
            .frame(maxWidth: .infinity)

            ZStack {
                HStack {
                    Spacer()
                    Text("Invalid Web Page")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 0)
                        .clipped()
                    Spacer()
                }
                if webTab.url != nil {
                    WebView(pageURL: $webTab.url, updateType: $updateType)
                }
            }
        }
    }

    private var refreshButton: some View {
        Button {
            updateType = .refresh
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .buttonStyle(.borderless)
        .frame(maxWidth: 10)
    }

    private var navigationButtonBack: some View {
        Button {
            updateType = .back
        } label: {
            Image(systemName: "chevron.left")
        }
        .buttonStyle(.borderless)
        .frame(maxWidth: 10)
    }
    private var navigationButtonForward: some View {
        Button {
            updateType = .forward
        } label: {
            Image(systemName: "chevron.right")
        }
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
