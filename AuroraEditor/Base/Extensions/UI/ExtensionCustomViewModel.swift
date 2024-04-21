//
//  ExtensionCustomViewModel.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 11/04/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

final class ExtensionCustomViewModel: Codable, Equatable, Identifiable, TabBarItemRepresentable, ObservableObject {
    static func == (lhs: ExtensionCustomViewModel, rhs: ExtensionCustomViewModel) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.name == rhs.name else { return false }
        return true
    }

    var id = UUID()
    @Published public var name: String
    @Published public var title: String
    var sender: String

    public var tabID: TabBarItemID {
        .extensionCustomView(id.debugDescription)
    }

    public var icon: Image {
        Image(systemName: "globe")
    }

    public var iconColor: Color {
        return .accentColor
    }

    private let viewStorage = ExtensionViewStorage.shared

    init(name: String, view: Any?, sender: String) {
        self.name = name
        self.title = name
        self.sender = sender

        if let view = view {
            viewStorage.storage[id] = view
        }
    }

    enum ExtensionCustomViewModelKey: CodingKey {
        case id
        case name
        case sender
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ExtensionCustomViewModelKey.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.title = try container.decode(String.self, forKey: .name)
        self.sender = try container.decode(String.self, forKey: .sender)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ExtensionCustomViewModelKey.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.sender, forKey: .sender)
    }
}
