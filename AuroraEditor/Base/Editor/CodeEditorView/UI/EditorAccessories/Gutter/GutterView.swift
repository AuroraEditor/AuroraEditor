//
//  GutterView.swift
//  
//
//  Created by Manuel M T Chakravarty on 23/09/2020.
//

// MARK: - AppKit version

import AppKit

private typealias FontDescriptor = NSFontDescriptor

private let fontDescriptorFeatureIdentifier = FontDescriptor.FeatureKey.typeIdentifier
private let fontDescriptorTypeIdentifier = FontDescriptor.FeatureKey.selectorIdentifier

private let lineNumberColour = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

class GutterView: NSView {

    /// The text view that this gutter belongs to.
    let textView: NSTextView

    /// The current code editor theme
    var theme: Theme

    /// Accessor for the associated text view's message views.
    let getMessageViews: () -> MessageViews

    /// Determines whether this gutter is for a main code view or for the minimap of a code view.
    let isMinimapGutter: Bool

    /// Text attributes for selection
    let textAttributesDefault, textAttributesSelected: [NSAttributedString.Key: NSObject]

    /// Create and configure a gutter view for the given text view. This will also set the appropiate exclusion path for
    /// text container.
    init(frame: CGRect,
         textView: NSTextView,
         theme: Theme,
         getMessageViews: @escaping () -> MessageViews,
         isMinimapGutter: Bool) {
        self.textView = textView
        self.theme = theme
        self.getMessageViews = getMessageViews
        self.isMinimapGutter = isMinimapGutter
        // NB: If were decide to use layer backing,
        // we need to set the `layerContentsRedrawPolicy` to redraw on resizing

        theme.backgroundColour.setFill()

        NSBezierPath(rect: frame).fill()

        let font = NSFont(name: "SF Mono Medium", size: 11) ?? NSFont.systemFont(ofSize: 0)

        // Text attributes for the line numbers
        let lineNumberStyle = NSMutableParagraphStyle()
        lineNumberStyle.alignment = .right

        self.textAttributesDefault = [NSAttributedString.Key.font: font,
                                     .foregroundColor: lineNumberColour,
                                     .paragraphStyle: lineNumberStyle,
                                     .kern: NSNumber(value: Float(-theme.fontSize / 11))]

        self.textAttributesSelected = [NSAttributedString.Key.font: font,
                                      .foregroundColor: theme.textColour,
                                      .paragraphStyle: lineNumberStyle,
                                      .kern: NSNumber(value: Float(-theme.fontSize / 11))]

        super.init(frame: frame)
    }

    required init(coder: NSCoder) {
        fatalError("CodeEditorView.GutterView.init(coder:) not implemented")
    }

    // Imitate the coordinate system of the associated text view.
    override var isFlipped: Bool { textView.isFlipped }

    var lastRefreshedFrame: CGRect = .zero
    var lines: [NSString] = []
    var gutterRects: [CGRect] = []
    var lineAttributes: [[NSAttributedString.Key: NSObject]] = []
}
