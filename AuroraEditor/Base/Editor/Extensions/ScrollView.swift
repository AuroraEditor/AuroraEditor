//
//  ScrollView.swift
//  Aurora Editor
//
//  Created by Manuel M T Chakravarty on 27/11/2021.
//

import SwiftUI

// MARK: - AppKit version
extension NSScrollView {

    var verticalScrollFraction: CGFloat {
        get {
            let verticalScrollRange = (documentView?.bounds.height ?? 0) - documentVisibleRect.height
            return verticalScrollRange > 0 ? min(max(0, documentVisibleRect.origin.y / verticalScrollRange), 1) : 0
        }
        set {
            let visibleRectY = newValue * max(0, (documentView?.bounds.height ?? 0) - documentVisibleRect.height)
            contentView.scroll(to: CGPoint(x: documentVisibleRect.origin.x, y: visibleRectY))
        }
    }
}
