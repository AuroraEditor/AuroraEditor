//
//  WebTab.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

final class WebTab: Equatable, Identifiable, TabBarItemRepresentable, ObservableObject {
    static func == (lhs: WebTab, rhs: WebTab) -> Bool {
        guard lhs.url == rhs.url else { return false }
        guard lhs.tabID == rhs.tabID else { return false }
        guard lhs.title == rhs.title else { return false }
        return true
    }

    var id = UUID()

    @Published public var url: URL? {
        didSet {
            self.address = url?.absoluteString ?? ""
        }
    }
    @Published public var address: String

    public var tabID: TabBarItemID {
        .webTab(id.debugDescription)
    }

    public var title: String {
        guard var initialText = self.url?.debugDescription else { return "No URL" }
        if let slashRange = initialText.range(of: "://") {
            initialText.removeSubrange(initialText.startIndex..<slashRange.upperBound)
        }
        if let slashRange = initialText.firstIndex(of: "/") {
            initialText.removeSubrange(slashRange..<initialText.endIndex)
        }
        return initialText
    }

    public var icon: Image {
        Image(systemName: "globe")
    }

    public var iconColor: Color {
        return .accentColor
    }

    init(url: URL?) {
        self.url = url
        self.address = url?.path ?? ""
        Log.info(self.url?.debugDescription ?? "no url for web view")
    }

    func updateURL(to newAddress: String = "") {
        url = URL(string: newAddress.isEmpty ? address : newAddress)
    }
}