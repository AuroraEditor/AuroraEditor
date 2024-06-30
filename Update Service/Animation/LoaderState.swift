//
//  LoaderState.swift
//  Aurora Editor Updater
//
//  Created by Nanashi Li on 2023/10/09.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// https://github.com/Shubham0812/SwiftUI-Animations/
/// Loader state
enum LoaderState: CaseIterable {
    /// Right
    case right

    /// Down
    case down

    /// Left
    case left

    /// Up
    case up

    /// Alignment
    var alignment: Alignment {
        switch self {
        case .right, .down:
            return .topLeading
        case .left:
            return .topTrailing
        case .up:
            return .bottomLeading
        }
    }

    /// Capsule dimension
    var capsuleDimension: CGFloat {
        return 40
    }

    /// Increasing offset
    var increasingOffset: CGFloat {
        return 72
    }

    /// Increment before
    var incrementBefore: (CGFloat, CGFloat, CGFloat, CGFloat) {
        // swiftlint:disable:previous large_tuple
        switch self {
        case .right:
            return (0, 0, capsuleDimension + increasingOffset, capsuleDimension)
        case .down:
            return (increasingOffset, 0, capsuleDimension, capsuleDimension + increasingOffset)
        case .left:
            return (increasingOffset, increasingOffset, capsuleDimension + increasingOffset, capsuleDimension)
        case .up:
            return (0, capsuleDimension + increasingOffset, capsuleDimension, capsuleDimension + increasingOffset)
        }
    }

    /// Increment after
    var incrementAfter: (CGFloat, CGFloat, CGFloat, CGFloat) {
        // swiftlint:disable:previous large_tuple
        switch self {
        case .right:
            return (increasingOffset, 0, capsuleDimension, capsuleDimension)
        case .down:
            return (increasingOffset, increasingOffset, capsuleDimension, capsuleDimension)
        case .left:
            return (0, increasingOffset, capsuleDimension, capsuleDimension)
        default:
            return (0, capsuleDimension, capsuleDimension, capsuleDimension)
        }
    }
}
