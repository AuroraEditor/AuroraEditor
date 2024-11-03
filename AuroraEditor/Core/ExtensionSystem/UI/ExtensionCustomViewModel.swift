//
//  ExtensionCustomViewModel.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 11/04/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// Extension Custom View Model
final class ExtensionCustomViewModel: Codable, Equatable, Identifiable, TabBarItemRepresentable, ObservableObject {
    /// Equate two `ExtensionCustomViewModel` instances.
    ///
    /// - Parameter lhs: First ExtensionCustomViewModel
    /// - Parameter rhs: Second ExtensionCustomViewModel
    ///
    /// - Returns: True if equal
    static func == (lhs: ExtensionCustomViewModel, rhs: ExtensionCustomViewModel) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.name == rhs.name else { return false }
        return true
    }

    /// Unique identifier of the extension custom view model.
    var id = UUID()

    /// Name of the extension custom view model.
    @Published
    public var name: String

    /// Title of the extension custom view model.
    @Published
    public var title: String

    /// Sender of the extension custom view model.
    var sender: String

    /// Tab ID
    public var tabID: TabBarItemID {
        .extensionCustomView(id.debugDescription)
    }

    /// Tab Icon
    public var icon: Image {
        Image(systemName: "globe")
    }

    /// Tab Icon Color
    public var iconColor: Color {
        return .accentColor
    }

    /// View storage
    private let viewStorage = ExtensionViewStorage.shared

    /// Initialize custom view model for an extension.
    ///
    /// - Parameter name: Name
    /// - Parameter view: View
    /// - Parameter sender: Sender
    init(name: String, view: Any?, sender: String) {
        self.name = name
        self.title = name
        self.sender = sender

        if let view = view {
            viewStorage.storage[id] = view
        }
    }

    /// View model keys
    enum ExtensionCustomViewModelKey: CodingKey {
        /// Identifier
        case id

        /// Name
        case name

        /// Sender
        case sender
    }

    /// Initialize extension custom view model from decoder.
    ///
    /// - Parameter decoder: Decoder
    ///
    /// - Throws: Decoding error
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ExtensionCustomViewModelKey.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.title = try container.decode(String.self, forKey: .name)
        self.sender = try container.decode(String.self, forKey: .sender)
    }

    /// Encode extension custom view model.
    ///
    /// - Parameter encoder: Encoder
    ///
    /// - Throws: Encoding error
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ExtensionCustomViewModelKey.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.sender, forKey: .sender)
    }
}
