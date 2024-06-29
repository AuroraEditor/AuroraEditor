//
//  WebTab.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// Represents a web tab.
/// 
/// Webtab is a tab that contains a web view.
final class WebTab: Codable, Equatable, Identifiable, TabBarItemRepresentable, ObservableObject {
    /// Equatable
    /// 
    /// - Parameter lhs: left hand side
    /// - Parameter rhs: right hand side
    /// 
    /// - Returns: true if equal
    static func == (lhs: WebTab, rhs: WebTab) -> Bool {
        guard lhs.url == rhs.url else { return false }
        guard lhs.tabID == rhs.tabID else { return false }
        guard lhs.title == rhs.title else { return false }
        return true
    }

    /// Unoque identifier of the web tab.
    var id = UUID()

    /// URL of the web tab.
    @Published
    public var url: URL? {
        didSet {
            self.address = url?.absoluteString ?? ""
        }
    }

    /// Address of the web tab.
    @Published
    public var address: String

    /// Title of the web tab.
    @Published
    public var title: String

    /// Tab ID
    public var tabID: TabBarItemID {
        .webTab(id.debugDescription)
    }

    /// Tab Icon
    public var icon: Image {
        Image(systemName: "globe")
    }

    /// Tab Icon Color
    public var iconColor: Color {
        return .accentColor
    }

    /// Initialize a web tab.
    /// 
    /// - Parameter url: URL
    init(url: URL?) {
        self.url = url
        self.address = url?.path ?? ""
        self.title = NSLocalizedString("Loading", comment: "Loading")
    }

    /// Update the URL of the web tab.
    /// 
    /// - Parameter newAddress: new address
    func updateURL(to newAddress: String = "") {
        url = URL(string: newAddress.isEmpty ? address : newAddress)
    }

    /// Coding keys
    enum WebTabKey: CodingKey {
        /// Identifier
        case id

        /// URL
        case url
    }

    /// Initialize from decoder
    /// 
    /// - Parameter decoder: decoder
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WebTabKey.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.url = try container.decode(URL?.self, forKey: .url)
        self.title = "Loading"
        self.address = ""
        self.address = url?.path ?? ""
    }

    /// Encode web tab
    /// 
    /// - Parameter encoder: encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WebTabKey.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.url, forKey: .url)
    }
}
