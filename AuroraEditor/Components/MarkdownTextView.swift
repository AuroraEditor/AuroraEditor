//
//  MarkdownTextView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import AppKit

class MarkdownTextView: NSView {
    private let textView = NSTextView()
    private var tappableRanges: [NSRange] = []
    private var onTap: ((String) -> Void)?

    init(
        markdownText: String,
        tappableRanges: [NSRange],
        onTap: @escaping (String) -> Void
    ) {
        self.tappableRanges = tappableRanges
        self.onTap = onTap
        super.init(frame: .zero)
        setupTextView(with: markdownText)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupTextView(with markdownText: String) {
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer?.lineFragmentPadding = 0

        let attributedString = NSMutableAttributedString(string: markdownText)
        tappableRanges.forEach { range in
            attributedString.addAttribute(
                .underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: range
            )
            attributedString.addAttribute(
                .foregroundColor,
                value: NSColor.blue,
                range: range
            )
        }
        textView.textStorage?.setAttributedString(attributedString)

        let gestureRecognizer = NSClickGestureRecognizer(
            target: self,
            action: #selector(handleClick(_:))
        )
        textView.addGestureRecognizer(gestureRecognizer)

        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func handleClick(_ gestureRecognizer: NSClickGestureRecognizer) {
        let location = gestureRecognizer.location(in: textView)
        if let characterIndex = textView.characterIndexForInsertion(at: location),
           let tappedText = textView.attributedString().stringForRange(
            characterIndex,
            inRanges: tappableRanges
           ) {
            onTap?(tappedText)
        }
    }
}

private extension NSTextView {
    func characterIndexForInsertion(at point: NSPoint) -> Int? {
        guard let layoutManager = layoutManager, let textContainer = textContainer else { return nil }
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        return layoutManager.characterIndexForGlyph(at: glyphIndex)
    }
}

private extension NSAttributedString {
    func stringForRange(_ characterIndex: Int, inRanges ranges: [NSRange]) -> String? {
        for range in ranges where NSLocationInRange(characterIndex, range) {
            return (string as NSString).substring(with: range)
        }
        return nil
    }
}
