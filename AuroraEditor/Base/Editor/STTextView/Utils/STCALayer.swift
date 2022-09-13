//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Foundation
import QuartzCore
import AppKit

open class STCALayer: CALayer {

    public var enableAnimations: Bool = false

    // Suppress default animation of opacity when adding comment bubbles.
    override public class func defaultAction(forKey event: String) -> CAAction? {
        return NSNull()
    }

    /// A dictionary containing layer actions.
    /// Disable animations
    override public var actions: [String: CAAction]? {
        get {
            super.actions
        }
        set {
            if !enableAnimations {
                return
            }

            super.actions = newValue
        }
    }

    override public init() {
        super.init()
        needsDisplayOnBoundsChange = true
    }

    public init(frame frameRect: CGRect) {
        super.init()
        needsDisplayOnBoundsChange = true
        frame = frameRect
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        needsDisplayOnBoundsChange = true
    }

    override public init(layer: Any) {
        super.init(layer: layer)
        needsDisplayOnBoundsChange = true
    }

}

open class STCATiledLayer: CATiledLayer {

    public var enableAnimations: Bool = false

    // Suppress default animation of opacity when adding comment bubbles.
    override public class func defaultAction(forKey event: String) -> CAAction? {
        return NSNull()
    }

    override open class func fadeDuration() -> CFTimeInterval {
        0
    }

    /// A dictionary containing layer actions.
    /// Disable animations
    override public var actions: [String: CAAction]? {
        get {
            super.actions
        }
        set {
            if !enableAnimations {
                return
            }

            super.actions = newValue
        }
    }

    override public init() {
        super.init()
        needsDisplayOnBoundsChange = true
    }

    public init(frame frameRect: CGRect) {
        super.init()
        needsDisplayOnBoundsChange = true
        frame = frameRect
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        needsDisplayOnBoundsChange = true
    }

    override public init(layer: Any) {
        super.init(layer: layer)
        needsDisplayOnBoundsChange = true
    }
}
