//
//  AuroraEditorSymbols.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 18.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Image extension
public extension Image {

    /// Creates an Image representing a custom SF Symbol
    /// - Parameter symbol: The name of the symbol in `Symbols.xcassets`
    init(symbol: String) {
        self.init(symbol, bundle: Bundle.module)
    }

    // MARK: - Symbols

    /// Image of a vault
    static let vault: Image = .init(symbol: "vault")

    /// Image of a vault (filled)
    static let vaultFill: Image = .init(symbol: "vault.fill")

    /// Image for commit
    static let commit: Image = .init(symbol: "commit")

    /// Image for checkout
    static let checkout: Image = .init(symbol: "checkout")

    /// Image for an breakpoint
    static let breakpoint: Image = .init(symbol: "breakpoint")

    /// Image for an breakpoint (filled)
    static let breakpointFill: Image = .init(symbol: "breakpoint.fill")

    /// Image for ChevronUpChevronDown
    static let customChevronUpChevronDown: Image = .init(symbol: "custom.chevron.up.chevron.down")

    // Add static properties for your symbols above this line
}

public extension NSImage {

    /// Returns a NSImage representing a custom SF Symbol
    /// 
    /// - Parameter named: The name of the symbol in `Symbols.xcassets`
    /// 
    /// - Returns: a NSImage
    static func symbol(named: String) -> NSImage {
        Bundle.module.image(forResource: named) ?? .init()
    }

    // MARK: - Symbols

    /// Image of a vault
    @MainActor
    static let vault: NSImage = .symbol(named: "vault")

    /// Image of a vault (filled)
    @MainActor
    static let vaultFill: NSImage = .symbol(named: "vault.fill")

    /// Image for commit
    @MainActor
    static let commit: NSImage = .symbol(named: "commit")

    /// Image for checkout
    @MainActor
    static let checkout: NSImage = .symbol(named: "checkout")

    /// Image for an breakpoint
    @MainActor
    static let breakpoint: NSImage = .symbol(named: "breakpoint")

    /// Image for an breakpoint (filled)
    @MainActor
    static let breakpointFill: NSImage = .symbol(named: "breakpoint.fill")

    /// Image for ChevronUpChevronDown
    @MainActor
    static let customChevronUpChevronDown: NSImage = .symbol(named: "custom.chevron.up.chevron.down")

    // Add static properties for your symbols above this line
}
