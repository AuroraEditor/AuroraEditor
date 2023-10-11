//
//  LoaderState.swift
//  Aurora Editor Updater
//
//  Created by Nanashi Li on 2023/10/09.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// https://github.com/Shubham0812/SwiftUI-Animations/
enum LoaderState: CaseIterable {
    case right
    case down
    case left
    case up

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

    var capsuleDimension: CGFloat {
        return 40
    }
    var increasingOffset: CGFloat {
        return 72
    }

    // swiftlint:disable:next large_tuple
    var incrementBefore: (CGFloat, CGFloat, CGFloat, CGFloat) {
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

    // swiftlint:disable:next large_tuple
    var incrementAfter: (CGFloat, CGFloat, CGFloat, CGFloat) {
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
