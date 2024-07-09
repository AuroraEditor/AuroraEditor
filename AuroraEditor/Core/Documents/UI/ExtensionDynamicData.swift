//
//  ExtensionDynamicData.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 09/07/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

/// Dynamic data for extensions.
class ExtensionDynamicData: ObservableObject {
    /// The name of the extension.
    @Published
    public var name: String

    /// The title of the window.
    @Published
    public var title: String = ""

    /// The view to display.
    @Published
    public var view: AnyView = AnyView(EmptyView())

    /// Creates a new instance of the dynamic data.
    init() {
        self.name = ""
        self.title = ""
        self.view = AnyView(EmptyView())
    }
}
