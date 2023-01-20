//
//  CodeView.swift
//  Aurora Editor
//
//  Created by Manuel M T Chakravarty on 05/05/2021.
//
//  This file contains both the macOS and iOS versions of the subclass for `NSTextView` and `UITextView`, respectively,
//  which forms the heart of the code editor.

import SwiftUI

// MARK: - Message info

/// Information required to layout message views.
///
/// NB: This information is computed incrementally. We get the `lineFragementRect` from the text container during the
///    type setting processes. This indicates that the message layout may have to change (if it was already
///    computed), but at this point, we cannot determine the new geometry yet; hence, `geometry` will be `nil`.
///    The `geomtry` will be determined after text layout is complete.
struct MessageInfo {
    let view: StatefulMessageView.HostingView
    var lineFragementRect: CGRect                            // The *full* line fragement rectangle (incl. message)
    var geometry: MessageView.Geometry?
    var colour: NSColor                           // The category colour of the most severe category

    var topAnchorConstraint: NSLayoutConstraint?
    var rightAnchorConstraint: NSLayoutConstraint?
}

/// Dictionary of message views.
typealias MessageViews = [LineInfo.MessageBundle.ID: MessageInfo]

/// `NSTextView` with a gutter
class CodeView: NSTextView { // swiftlint:disable:this type_body_length

    // Delegates
    let codeViewDelegate = CodeViewDelegate()
    let codeLayoutManagerDelegate = CodeLayoutManagerDelegate()
    var codeStorageDelegate: CodeStorageDelegate

    // Subviews
    var gutterView: GutterView?
    var minimapView: NSTextView?
    var minimapGutterView: GutterView?
    var documentVisibleBox: NSBox?
    var minimapDividerView: NSBox?

    /// Contains the line on which the insertion point was located, the last time the selection range got set (if the
    /// selection was an insetion point at all; i.e., it's length was 0).
    var oldLastLineOfInsertionPoint: Int? = 1

    /// The current highlighting theme
    var theme: AuroraTheme {
        didSet {
            font = theme.font
            backgroundColor = theme.editor.background.nsColor
            insertionPointColor = theme.editor.insertionPoint.nsColor
            selectedTextAttributes = [.backgroundColor: theme.editor.selection.nsColor]
            (textStorage as? CodeStorage)?.theme = theme
            minimapView?.backgroundColor = theme.editor.background.nsColor
            documentVisibleBox?.fillColor = theme.editor.text.nsColor.withAlphaComponent(0.1)
            tile()
            setNeedsDisplay(visibleRect)
        }
    }

    /// The current view layout.
    var viewLayout: CodeEditor.LayoutConfiguration {
        didSet { tile() }
    }

    /// Keeps track of the set of message views.
    var messageViews: MessageViews = [:]

    private(set) var parser: Parser
    private(set) var grammar: Grammar
    private(set) var highlightTheme: HighlightTheme = .default

    /// Designated initialiser for code views with a gutter.
    init(frame: CGRect, // swiftlint:disable:this function_body_length
         viewLayout: CodeEditor.LayoutConfiguration,
         theme: AuroraTheme,
         grammars: [Grammar] = [],
         mainGrammar: Grammar,
         highlightTheme: HighlightTheme = .default
    ) {
        self.theme = theme
        self.highlightTheme = highlightTheme
        self.viewLayout = viewLayout
        self.grammar = mainGrammar

        // as the Parser must contain mainGrammar in one of its grammars, this
        // code ensures that grammars contains the mainGrammar
        var grammars = grammars
        if !grammars.contains(where: { $0.scopeName == mainGrammar.scopeName }) {
            grammars.append(mainGrammar)
        }
        self.parser = Parser(grammars: grammars)

        // Use custom components that are gutter-aware and support code-specific editing actions and highlighting.
        let codeLayoutManager = CodeLayoutManager(),
            codeContainer = CodeContainer(),
            codeStorage = CodeStorage(parser: parser,
                                      baseGrammar: grammar,
                                      theme: theme)
        codeStorage.addLayoutManager(codeLayoutManager)
        codeContainer.layoutManager = codeLayoutManager
        codeLayoutManager.addTextContainer(codeContainer)
        codeLayoutManager.delegate = codeLayoutManagerDelegate

        codeStorageDelegate = CodeStorageDelegate()

        super.init(frame: frame, textContainer: codeContainer)

        // Set basic display and input properties
        font = theme.font
        backgroundColor = theme.editor.background.nsColor
        insertionPointColor = theme.editor.insertionPoint.nsColor
        selectedTextAttributes = [.backgroundColor: theme.editor.selection.nsColor]
        isRichText = false
        isAutomaticQuoteSubstitutionEnabled = false
        isAutomaticLinkDetectionEnabled = false
        smartInsertDeleteEnabled = false
        isContinuousSpellCheckingEnabled = false
        isGrammarCheckingEnabled = false
        isAutomaticDashSubstitutionEnabled = false
        isAutomaticDataDetectionEnabled = false
        isAutomaticSpellingCorrectionEnabled = false
        isAutomaticTextReplacementEnabled = false
        usesFontPanel = false

        // Line wrapping
        isHorizontallyResizable = false
        isVerticallyResizable = true
        textContainerInset = CGSize(width: 0, height: 0)
        textContainer?.widthTracksTextView = false   // we need to be able to control the size (see `tile()`)
        textContainer?.heightTracksTextView = false
        textContainer?.lineBreakMode = .byWordWrapping

        // Enable undo support
        allowsUndo = true

        // Add the view delegate
        delegate = codeViewDelegate

        // Add a text storage delegate that maintains a line map
        codeStorage.delegate = codeStorageDelegate

        // Add a gutter view
        let gutterView = GutterView(frame: CGRect.zero,
                                    textView: self,
                                    theme: theme,
                                    getMessageViews: { self.messageViews },
                                    isMinimapGutter: false)
        gutterView.autoresizingMask = .none
        addSubview(gutterView)
        self.gutterView = gutterView
        codeLayoutManager.gutterView = gutterView

        // Add the minimap with its own gutter, but sharing the code storage with the code view
        let minimapLayoutManager = MinimapLayoutManager(),
            minimapView = MinimapView(),
            minimapGutterView = GutterView(frame: CGRect.zero,
                                           textView: minimapView,
                                           theme: theme,
                                           getMessageViews: { self.messageViews },
                                           isMinimapGutter: true),
            minimapDividerView = NSBox()
        minimapView.codeView = self

        minimapDividerView.boxType = .separator
        addSubview(minimapDividerView)
        self.minimapDividerView = minimapDividerView

        // Note: TextContainer passes the text from the file into the minimap to
        // be converted to glyphs
        minimapView.textContainer?.replaceLayoutManager(minimapLayoutManager)
        codeStorage.addLayoutManager(minimapLayoutManager)
        minimapView.backgroundColor = backgroundColor
        minimapView.autoresizingMask = .width
        minimapView.isEditable = false
        minimapView.isSelectable = false
        minimapView.isHorizontallyResizable = false
        minimapView.isVerticallyResizable = true
        minimapView.textContainerInset = CGSize(width: 0, height: 0)
        addSubview(minimapView)
        self.minimapView = minimapView

        minimapView.addSubview(minimapGutterView)
        self.minimapGutterView = minimapGutterView

        minimapView.layoutManager?.typesetter = MinimapTypeSetter()

        // This handles the minimap box color, the one that moves as you scroll the document
        let documentVisibleBox = NSBox()
        documentVisibleBox.boxType = .custom
        documentVisibleBox.fillColor = theme.editor.text.nsColor.withAlphaComponent(0.1)
        documentVisibleBox.borderWidth = 0
        minimapView.addSubview(documentVisibleBox)
        self.documentVisibleBox = documentVisibleBox

        tile()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        // Lay out the various subviews and text containers
        tile()

        // Redraw the visible part of the gutter
        gutterView?.setNeedsDisplay(documentVisibleRect)
    }

    override func setSelectedRanges(_ ranges: [NSValue],
                                    affinity: NSSelectionAffinity,
                                    stillSelecting stillSelectingFlag: Bool) {
        let oldSelectedRanges = selectedRanges
        super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelectingFlag)
        minimapView?.selectedRanges = selectedRanges    // minimap mirrors the selection of the main code view

        let lineOfInsertionPoint = insertionPoint.flatMap { optLineMap?.lineOf(index: $0) }

        // If the insertion point changed lines, we need to redraw at the\
        // old and new location to fix the line highlighting.
        // NB: We retain the last line and not the character index as the
        // latter may be inaccurate due to editing that let
        // to the selected range change.
        if lineOfInsertionPoint != oldLastLineOfInsertionPoint, let codeStorage = optCodeStorage {

            if let oldLine = oldLastLineOfInsertionPoint,
               let oldLineRange = codeStorage.getLineRange(oldLine) {

                // We need to invalidate the whole background (incl message views); hence, we need to employ
                // `lineBackgroundRect(_:)`, which is why `NSLayoutManager.invalidateDisplay(forCharacterRange:)` is not
                // sufficient.
                layoutManager?.enumerateFragmentRects(forLineContaining: oldLineRange.location) { fragmentRect in

                    self.setNeedsDisplay(self.lineBackgroundRect(fragmentRect))
                }
            }
            if let newLine = lineOfInsertionPoint,
               let newLineRange = codeStorage.getLineRange(newLine) {

                // We need to invalidate the whole background (incl message views); hence, we need to employ
                // `lineBackgroundRect(_:)`, which is why `NSLayoutManager.invalidateDisplay(forCharacterRange:)` is not
                // sufficient.
                layoutManager?.enumerateFragmentRects(forLineContaining: newLineRange.location) { fragmentRect in

                    self.setNeedsDisplay(self.lineBackgroundRect(fragmentRect))
                }
            }
        }
        oldLastLineOfInsertionPoint = lineOfInsertionPoint

        // NB: This needs to happen after calling `super`, as it depends on the correctly set new set of ranges.
        DispatchQueue.main.async {
            // Needed as the selection affects line number highlighting.
            // NB: Invalidation of the old and new ranges needs to happen separately.
            // If we were to union them, an insertion
            // point (range length = 0) at the start of a line would be absorbed \
            // into the previous line, which results in
            // a lack of invalidation of the line on which the insertion point is located.
            self.gutterView?.invalidateGutter(forCharRange: combinedRanges(ranges: oldSelectedRanges))
            self.gutterView?.invalidateGutter(forCharRange: combinedRanges(ranges: ranges))
//            self.minimapGutterView?.invalidateGutter(forCharRange: combinedRanges(ranges: oldSelectedRanges))
//            self.minimapGutterView?.invalidateGutter(forCharRange: combinedRanges(ranges: ranges))
        }

        collapseMessageViews()
    }

    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)

        guard let layoutManager = layoutManager,
              let textContainer = textContainer
        else { return }

        let glyphRange = layoutManager.glyphRange(forBoundingRectWithoutAdditionalLayout: rect, in: textContainer),
            charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        // If the selection is an insertion point, highlight the corresponding line
        if let location = insertionPoint, charRange.contains(location) || location == NSMaxRange(charRange) {

            drawBackgroundHighlight(in: rect, forLineContaining: location,
                                    withColour: theme.editor.lineHighlight.nsColor)

        }

        // Highlight each line that has a message view
        for messageView in messageViews {
            let glyphRange = layoutManager.glyphRange(
                forBoundingRect: messageView.value.lineFragementRect,
                in: textContainer),
                index = layoutManager.characterIndexForGlyph(at: glyphRange.location)

            // This seems like a worthwhile optimisation,
            // but sometimes we are called in a situation, where `charRange` computes
            // to be the empty range although the whole visible area is being redrawn.
            // if charRange.contains(index) {

            drawBackgroundHighlight(in: rect,
                                    forLineContaining: index,
                                    withColour: messageView.value.colour.withAlphaComponent(0.1))

            //      }
        }
    }

    /// Draw the background of an entire line of text with a highlight colour, including below any messages views.
    private func drawBackgroundHighlight(
        in rect: NSRect,
        forLineContaining charIndex: Int,
        withColour colour: NSColor) {
            guard let layoutManager = layoutManager else { return }

            colour.setFill()
            layoutManager.enumerateFragmentRects(forLineContaining: charIndex) { fragmentRect in

                let drawRect = self.lineBackgroundRect(fragmentRect).intersection(rect)
                if !drawRect.isNull { NSBezierPath(rect: drawRect).fill() }
            }
        }

    /// Compute the background rect from a line's fragement rect. On lines that contain a message view, the fragement
    /// rect doesn't cover the entire background.
    private func lineBackgroundRect(_ lineFragementRect: CGRect) -> CGRect {

        if let textContainerWidth = textContainer?.size.width {

            return CGRect(
                origin: lineFragementRect.origin,
                size: CGSize(
                    width: textContainerWidth - lineFragementRect.minX,
                    height: lineFragementRect.height
                )
            )

        } else {

            return lineFragementRect

        }
    }

    /// Position and size the gutter and minimap and set the text container sizes and exclusion paths. Take the current
    /// view layout in `viewLayout` into account.
    ///
    /// * The main text view contains three subviews: (1) the main gutter on its left side, (2) the minimap on its right
    ///   side, and (3) a divide in between the code view and the minimap gutter.
    /// * Both the main text view and the minimap text view (or rather their text container) uses an exclusion path to
    ///   keep text out of the gutter view. The main text view is sized to avoid overlap with the minimap even
    ///   without an exclusion path.
    /// * The main text view and the minimap text view need to be able to accomodate exactly the same number of
    ///   characters, so that line breaking procceds in the exact same way.
    ///
    /// NB: We don't use a ruler view for the gutter on macOS to be able to use the same setup on macOS and iOS.
    private func tile() {
        // Compute size of the main view gutter (Line Numbers)
        let theFont = font ?? NSFont.systemFont(ofSize: 0),
            fontSize = theFont.pointSize,
            fontWidth = theFont.maximumAdvancement.width,
            // NB: we deal only with fixed width fonts
            gutterWithInCharacters = CGFloat(6),
            gutterWidth = ceil(fontWidth * gutterWithInCharacters),
            gutterRect = CGRect(
                origin: CGPoint.zero,
                size: CGSize(width: gutterWidth, height: frame.height)
            ),
            gutterExclusionPath = NSBezierPath(rect: gutterRect),
            minLineFragmentPadding = CGFloat(6)

        gutterView?.frame = gutterRect

        // Compute sizes of the minimap text view and gutter
        let minimapFontWidth = minimapFontSize(for: fontSize) / 2,
            minimapGutterWidth = minimapFontWidth * gutterWithInCharacters,
            dividerWidth = CGFloat(1),
            minimapGutterRect = CGRect(origin: CGPoint.zero,
                                          size: CGSize(width: minimapGutterWidth, height: frame.height)),
            widthWithoutGutters = frame.width - gutterWidth - minimapGutterWidth
        - minLineFragmentPadding * 2 + minimapFontWidth * 2 - dividerWidth,
        numberOfCharacters = codeWidthInCharacters(for: widthWithoutGutters,
                                                     with: theFont,
                                                     withMinimap: viewLayout.showMinimap),
        minimapWidth = minimapGutterWidth + minimapFontWidth * 2 + numberOfCharacters * minimapFontWidth,
        codeViewWidth = viewLayout.showMinimap ? frame.width - minimapWidth - dividerWidth : frame.width,
        padding = codeViewWidth - (gutterWidth + ceil(numberOfCharacters * fontWidth)),
        minimapX = floor(frame.width - minimapWidth),
        minimapRect = CGRect(x: minimapX, y: 0, width: minimapWidth, height: frame.height),
        minimapExclusionPath = NSBezierPath(rect: minimapGutterRect),
        minimapDividerRect = CGRect(x: minimapX - dividerWidth, y: 0, width: dividerWidth, height: frame.height)

        minimapDividerView?.isHidden = !viewLayout.showMinimap
        minimapView?.isHidden = !viewLayout.showMinimap
        if viewLayout.showMinimap {
            minimapDividerView?.frame = minimapDividerRect
            minimapView?.frame = minimapRect
            minimapGutterView?.frame = minimapGutterRect
        }

        minSize = CGSize(width: 0, height: documentVisibleRect.height)
        maxSize = CGSize(width: codeViewWidth, height: CGFloat.greatestFiniteMagnitude)

        // Set the text container area of the main text view to reach up to the minimap
        // NB: We use the `lineFragmentPadding` to capture the slack that arises
        //     when the window width admits a fractional number of characters.
        //     Adding the slack to the code view's text container doesn't work
        //     as the line breaks of the minimap and main code view are then
        //     sometimes not entirely in sync.
        textContainerInset = NSSize(width: 0, height: 0)
        textContainer?.size = NSSize(width: codeViewWidth, height: CGFloat.greatestFiniteMagnitude)
        textContainer?.lineFragmentPadding = padding / 2
        textContainer?.exclusionPaths = [gutterExclusionPath]

        // Set the text container area of the minimap text view
        minimapView?.textContainer?.exclusionPaths = [minimapExclusionPath]
        minimapView?.textContainer?.size = CGSize(width: minimapWidth,
                                                                 height: CGFloat.greatestFiniteMagnitude)
        minimapView?.textContainer?.lineFragmentPadding = minimapFontWidth

        // NB: We can't set the height of the box highlighting the document visible\
        // area here as it depends on the document and minimap height, which requires\
        // document layout to be completed. Hence, we delay that.
        DispatchQueue.main.async { self.adjustScrollPositionOfMinimap() }
    }

    /// Sets the scrolling position of the minimap in dependence of the scroll position of the main code view.
    func adjustScrollPositionOfMinimap() {
        guard viewLayout.showMinimap else { return }

        let codeViewHeight = frame.size.height,
            minimapHeight = minimapView?.frame.size.height ?? 0,
            visibleHeight = documentVisibleRect.size.height

        let scrollFactor: CGFloat
        if minimapHeight < visibleHeight { scrollFactor = 1 } else {

            scrollFactor = 1 - (minimapHeight - visibleHeight) / (codeViewHeight - visibleHeight)

        }

        // We box the positioning of the minimap at the top and the bottom of the code view (with the `max` and `min`
        // expessions. This is necessary as the minimap will otherwise be partially
        // cut off by the enclosing clip view.
        // If we want an Xcode-like behaviour, where the minimap sticks to the top,
        // it probably would need to be a floating
        // view outside of the clip view.
        let newOriginY = floor(min(max(documentVisibleRect.origin.y * scrollFactor, 0),
                                   frame.size.height - (minimapView?.frame.size.height ?? 0)))
        if minimapView?.frame.origin.y != newOriginY {
            minimapView?.frame.origin.y = newOriginY
        }  // don't update frames in vain

        let minimapVisibleY = (visibleRect.origin.y / frame.size.height) * minimapHeight,
            minimapVisibleHeight = documentVisibleRect.size.height * minimapHeight / frame.size.height,
            documentVisibleFrame = CGRect(x: 0,
                                          y: minimapVisibleY,
                                          width: minimapView?.bounds.size.width ?? 0,
                                          height: minimapVisibleHeight).integral
        if documentVisibleBox?.frame != documentVisibleFrame { documentVisibleBox?.frame = documentVisibleFrame }
    }
}

/// Common code view actions triggered on a selection change.
func selectionDidChange<TV: TextView>(_ textView: TV) {
//    guard let layoutManager = textView.optLayoutManager,
//          let textContainer = textView.optTextContainer,
//          let codeStorage = textView.optCodeStorage
//    else { return }
//
//    let visibleRect = textView.documentVisibleRect,
//        glyphRange = layoutManager.glyphRange(forBoundingRectWithoutAdditionalLayout: visibleRect,
//                                              in: textContainer),
//        charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
}

/// Combine selection ranges into the smallest ranges encompassing them all.
private func combinedRanges(ranges: [NSValue]) -> NSRange {
    let actualranges = ranges.compactMap { $0 as? NSRange }
    return actualranges.dropFirst().reduce(actualranges.first ?? NSRange(location: 0, length: 0)) {
        NSUnionRange($0, $1)
    }
} // swiftlint:disable:this file_length
