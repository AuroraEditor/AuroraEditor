//
//  GutterRect.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/24.
//

import AppKit

extension GutterView {

    /// Compute the full width rectangle in the gutter from a text container rectangle, such that they both have the
    /// same vertical extension.
    public func gutterRectFrom(textRect: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: 0, y: textRect.origin.y + textView.textContainerOrigin.y),
                      size: CGSize(width: frame.size.width, height: textRect.size.height))
    }

    /// Compute the line number glyph rectangle in the gutter from a text container rectangle, such that they both have
    /// the same vertical extension.
    public func gutterRectForLineNumbersFrom(textRect: CGRect) -> CGRect {
        let gutterRect = gutterRectFrom(textRect: textRect)
        return CGRect(x: gutterRect.origin.x + gutterRect.size.width * 2 / 7,
                      y: gutterRect.origin.y,
                      width: gutterRect.size.width * 4 / 7,
                      height: gutterRect.size.height)
    }

    /// Compute the full width rectangle in the text container from a gutter rectangle, such that they both have the
    /// same vertical extension.
    public func textRectFrom(gutterRect: CGRect) -> CGRect {
        let containerWidth = optTextContainer?.size.width ?? 0
        return CGRect(origin: CGPoint(x: frame.size.width, y: gutterRect.origin.y - textView.textContainerOrigin.y),
                      size: CGSize(width:
                                    containerWidth - frame.size.width,
                                   height: gutterRect.size.height))
    }
}
