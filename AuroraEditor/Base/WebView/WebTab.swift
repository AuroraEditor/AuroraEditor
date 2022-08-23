//
//  WebTab.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

final class WebTab: Codable, Equatable, Identifiable, TabBarItemRepresentable, ObservableObject {
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
    }

    func updateURL(to newAddress: String = "") {
        url = URL(string: newAddress.isEmpty ? address : newAddress)
    }

    enum WebTabKey: CodingKey {
        case id
        case url
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WebTabKey.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.url = try container.decode(URL?.self, forKey: .url)
        self.address = ""
        self.address = url?.path ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WebTabKey.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.url, forKey: .url)
    }
}
