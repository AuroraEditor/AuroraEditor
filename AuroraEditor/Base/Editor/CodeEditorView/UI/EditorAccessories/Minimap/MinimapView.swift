//
//  MinimapView.swift
//  
//
//  Created by Manuel M T Chakravarty on 05/05/2021.
//
//  TextKit subclasses to implement minimap functionality. This is currently only supported for macOS as iOS lacks
//  support for configuring the type setter.

import SwiftUI

/// Customised text view for the minimap.
class MinimapView: NSTextView {
    weak var codeView: CodeView?

    // Highlight the current line.
    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)

        guard let layoutManager = layoutManager else { return }

        // Highlight the current line
        codeView?.theme.currentLineColour.setFill()
        if let location = insertionPoint {
            layoutManager.enumerateFragmentRects(forLineContaining: location) { rect in
                NSBezierPath(rect: rect).fill()
            }
        }
    }
}

/// Compute the size of the code view in number of characters such that we can still accommodate the minimap.
///
/// - Parameters:
///   - width: Overall width available for main and minimap code view *without* gutter and padding.
///   - font: The fixed pitch font of the main text view.
///   - withMinimap: Determines whether to include the presence of a minimap into the calculation.
/// - Returns: The width of the code view in number of characters.
func codeWidthInCharacters(for width: CGFloat, with font: NSFont, withMinimap: Bool) -> CGFloat {
    let minimapCharWidth = withMinimap ? minimapFontSize(for: font.pointSize) / 2 : 0
    return floor(width / (font.maximumAdvancement.width + minimapCharWidth))
}

/// Compute the font size for the minimap from the font size of the main text view.
///
/// - Parameter fontSize: The font size of the main text view
/// - Returns: The font size for the minimap
///
/// The result is always divisible by two, to enable the use of full pixels for the font width while avoiding aspect
/// ratios that are too unbalanced.
func minimapFontSize(for fontSize: CGFloat) -> CGFloat {
    return max(1, ceil(fontSize / 20)) * 2
}
