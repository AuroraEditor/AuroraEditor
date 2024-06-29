//
//  SplitViewDropDelegate.swift
//  Aurora Editor
//
//  Created by Mateusz Bąk on 2022/07/03.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// Split view drop delegate
struct SplitViewDropDelegate: DropDelegate {
    /// Proposal position
    @Binding
    var proposalPosition: SplitViewProposalDropPosition?

    /// Available positions
    let availablePositions: [SplitViewProposalDropPosition]

    /// Geometry proxy
    let geometryProxy: GeometryProxy

    /// Margin
    let margin: CGFloat

    /// Hitbox sizes
    let hitboxSizes: [SplitViewProposalDropPosition: CGFloat]

    /// On drop closure
    let onDrop: ((SplitViewProposalDropPosition, DropInfo) -> Void)?

    /// Perform drop
    /// 
    /// - Parameter info: drop info
    /// 
    /// - Returns: drop performed
    func performDrop(info: DropInfo) -> Bool {
        if let proposalPosition = proposalPosition {
            onDrop?(proposalPosition, info)
        }

        return false
    }

    /// Drop updated
    /// 
    /// - Parameter info: drop info
    /// 
    /// - Returns: drop proposal
    func dropUpdated(info: DropInfo) -> DropProposal? {
        let localFrame = geometryProxy.frame(in: .local)

        if let calculatedProposalPosition = calculateDropProposalPosition(
            in: localFrame,
            for: info.location,
            margin: margin,
            hitboxSizes: hitboxSizes,
            availablePositions: availablePositions
        ), availablePositions.contains(calculatedProposalPosition) {
            proposalPosition = calculatedProposalPosition
        } else {
            proposalPosition = nil
        }

        return nil
    }

    /// Drop exited
    /// 
    /// - Parameter info: drop info
    func dropExited(info: DropInfo) {
        proposalPosition = nil
    }
}
