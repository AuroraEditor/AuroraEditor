//
//  ScrollView.swift
//  
//
//  Created by Manuel M T Chakravarty on 27/11/2021.
//

import SwiftUI

#if os(iOS)

// MARK: -
// MARK: UIKit version

extension UIScrollView {

  var verticalScrollFraction: CGFloat {
    get {
      let verticalScrollRange = contentSize.height - bounds.height
      return verticalScrollRange > 0 ? min(max(0, contentOffset.y / verticalScrollRange), 1) : 0
    }
    set {
      let visibleRectY = newValue * max(0, contentSize.height - bounds.height)
      setContentOffset(CGPoint(x: contentOffset.x, y: visibleRectY), animated: false)
    }
  }
}

#elseif os(macOS)

// MARK: -
// MARK: AppKit version

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

#endif
