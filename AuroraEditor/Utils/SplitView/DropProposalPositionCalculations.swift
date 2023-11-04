//
//  DropProposalPositionCalculations.swift
//  Aurora Editor
//
//  Created by Mateusz Bąk on 2022/07/03.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import Foundation

/*
 Leading Rect:
 +------+--------------------------+------+
 |xxxxxx|                          |      |
 |xxxxxx|                          |      |
 |xxxxxx+--------------------------+      |
 |xxxxxx|                          |      |
 |xxxxxx|                          |      |
 |xxxxxx|                          |      |
 |xxxxxx+--------------------------+      |
 |xxxxxx|                          |      |
 |xxxxxx|                          |      |
 +------+--------------------------+------+

 Trailing Rect:
 +------+--------------------------+------+
 |      |                          |xxxxxx|
 |      |                          |xxxxxx|
 |      +--------------------------+xxxxxx|
 |      |                          |xxxxxx|
 |      |                          |xxxxxx|
 |      |                          |xxxxxx|
 |      +--------------------------+xxxxxx|
 |      |                          |xxxxxx|
 |      |                          |xxxxxx|
 +------+--------------------------+------+

 Top Rect:
 +------+--------------------------+------+
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      +--------------------------+      |
 |      |                          |      |
 |      |                          |      |
 |      |                          |      |
 |      +--------------------------+      |
 |      |                          |      |
 |      |                          |      |
 +------+--------------------------+------+

 Bottom Rect:
 +------+--------------------------+------+
 |      |                          |      |
 |      |                          |      |
 |      +--------------------------+      |
 |      |                          |      |
 |      |                          |      |
 |      |                          |      |
 |      +--------------------------+      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 +------+--------------------------+------+

 Center Rect:
 +------+--------------------------+------+
 |      |                          |      |
 |      |                          |      |
 |      +--------------------------+      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      +--------------------------+      |
 |      |                          |      |
 |      |                          |      |
 +------+--------------------------+------+
 */
func calculateDropProposalPosition(in rect: CGRect,
                                   for point: CGPoint,
                                   margin: CGFloat,
                                   hitboxSizes: [SplitViewProposalDropPosition: CGFloat] = [:],
                                   availablePositions: [SplitViewProposalDropPosition] = []
) -> SplitViewProposalDropPosition? {
    let leadingRect = CGRect(
        x: rect.minX,
        y: rect.minY,
        width: availablePositions.contains(.leading) ? (hitboxSizes[.leading] ?? margin) : 0,
        height: rect.height
    )

    let trailingRect = CGRect(
        x: rect.maxX - (availablePositions.contains(.trailing) ? (hitboxSizes[.trailing] ?? margin) : 0),
        y: rect.minY,
        width: availablePositions.contains(.trailing) ? (hitboxSizes[.trailing] ?? margin) : 0,
        height: rect.height
    )

    let topRect = CGRect(
        x: leadingRect.maxX,
        y: rect.minY,
        width: rect.width - leadingRect.width - trailingRect.width,
        height: availablePositions.contains(.top) ? (hitboxSizes[.top] ?? margin) : 0
    )

    let bottomRect = CGRect(
        x: leadingRect.maxX,
        y: rect.maxY - (availablePositions.contains(.bottom) ? (hitboxSizes[.bottom] ?? margin) : 0),
        width: rect.width - leadingRect.width - trailingRect.width,
        height: availablePositions.contains(.top) ? (hitboxSizes[.bottom] ?? margin) : 0
    )

    if leadingRect.contains(point) {
        return .leading
    }

    if trailingRect.contains(point) {
        return .trailing
    }

    if topRect.contains(point) {
        return .top
    }

    if bottomRect.contains(point) {
        return .bottom
    }

    if rect.contains(point) {
        return .center
    }

    return nil
}
