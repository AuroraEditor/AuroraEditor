//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import CoreGraphics
import Cocoa

extension CGRect {

    enum Inset {
        case left(CGFloat)
        case right(CGFloat)
        case top(CGFloat)
        case bottom(CGFloat)
    }

    func inset(_ edgeInsets: NSEdgeInsets) -> CGRect {
        var result = self
        result.origin.x += edgeInsets.left
        result.origin.y += edgeInsets.top
        result.size.width -= edgeInsets.left + edgeInsets.right
        result.size.height -= edgeInsets.top + edgeInsets.bottom
        return result
    }

    func inset(_ insets: Inset...) -> CGRect {
        var result = self
        for inset in insets {
            switch inset {
            case .left(let value):
                result = self.inset(NSEdgeInsets(top: 0, left: value, bottom: 0, right: 0))
            case .right(let value):
                result = self.inset(NSEdgeInsets(top: 0, left: 0, bottom: 0, right: value))
            case .top(let value):
                result = self.inset(NSEdgeInsets(top: value, left: 0, bottom: 0, right: 0))
            case .bottom(let value):
                result = self.inset(NSEdgeInsets(top: 0, left: 0, bottom: value, right: 0))
            }
        }
        return result
    }

    func inset(xPos: CGFloat) -> CGRect {
        insetBy(dx: xPos, dy: 0)
    }

    func inset(yPos: CGFloat) -> CGRect {
        insetBy(dx: 0, dy: yPos)
    }

    func moved(xPos: CGFloat, yPos: CGFloat) -> CGRect {
        applying(.init(translationX: xPos, y: yPos))
    }

    func moved(by point: CGPoint) -> CGRect {
        applying(.init(translationX: point.x, y: point.y))
    }

    func margin(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> CGRect {
        inset(.init(top: -top, left: -left, bottom: -bottom, right: -right))
    }
}

extension CGPoint {
    func moved(xPos: CGFloat, yPos: CGFloat) -> CGPoint {
        applying(.init(translationX: xPos, y: yPos))
    }

    func moved(by point: CGPoint) -> CGPoint {
        applying(.init(translationX: point.x, y: point.y))
    }
}

extension CGRect {
    func isAlmostEqual(to other: CGRect) -> Bool {
        origin.isAlmostEqual(to: other.origin) && size.isAlmostEqual(to: other.size)
    }
}

extension CGPoint {
    func isAlmostEqual(to other: CGPoint) -> Bool {
        x.isAlmostEqual(to: other.x) && y.isAlmostEqual(to: other.y)
    }
}

extension CGSize {
    func isAlmostEqual(to other: CGSize) -> Bool {
        width.isAlmostEqual(to: other.width) && height.isAlmostEqual(to: other.height)
    }
}
