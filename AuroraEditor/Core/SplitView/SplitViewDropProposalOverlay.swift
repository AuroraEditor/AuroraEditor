//
//  SplitViewDropProposalOverlay.swift
//  Aurora Editor
//
//  Created by Mateusz Bąk on 2022/07/03.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// Split view proposal drop position
private enum Const {
    /// Padding
    static let padding: CGFloat = 5.5

    /// Duration of the animation
    static let animationDuration: TimeInterval = 0.2

    /// Overlay corner radius
    static let overlayCornerRadius: CGFloat = 5

    /// Overlay border color opacity
    static let overlayBorderColorOpacity: CGFloat = 0.2

    /// Overlay border line width
    static let overlayBorderLineWidth: CGFloat = 1

    /// Overlay icon size
    static let overlayIconSize: CGFloat = 30.5
}

/// Split view drop proposal overlay
struct SplitViewDropProposalOverlay: View {
    /// Matched geometry effect
    private enum MatchedGeometryEffect {
        /// Overlay
        case overlay
    }

    /// Animation namespace
    @Namespace
    private var animation

    /// Proposal position
    let proposalPosition: SplitViewProposalDropPosition?

    /// The view body
    var body: some View {
        contentView
            .padding(Const.padding)
            .animation(
                .easeInOut(duration: Const.animationDuration),
                value: proposalPosition
            )
    }

    /// Content view
    @ViewBuilder
    private var contentView: some View {
        ZStack {
            if let proposalPosition = proposalPosition {
                switch proposalPosition {
                case .leading:
                    leadingPositionOverlay
                case .trailing:
                    trailingPositionOverlay
                case .top:
                    topPositionOverlay
                case .bottom:
                    bottomPositionOverlay
                case .center:
                    centerPositionOverlay
                }
            } else {
                noPositionOverlay
            }
        }
    }

    /// Leading position overlay
    private var leadingPositionOverlay: some View {
        HStack(spacing: 0) {
            overlay
            Color.clear
        }
    }

    /// Trailing position overlay
    private var trailingPositionOverlay: some View {
        HStack(spacing: 0) {
            Color.clear
            overlay
        }
    }

    /// Top position overlay
    private var topPositionOverlay: some View {
        VStack(spacing: 0) {
            overlay
            Color.clear
        }
    }

    /// Bottom position overlay
    private var bottomPositionOverlay: some View {
        VStack(spacing: 0) {
            Color.clear
            overlay
        }
    }

    /// Center position overlay
    private var centerPositionOverlay: some View {
        overlay
    }

    /// No position overlay
    private var noPositionOverlay: some View {
        overlay
            .frame(width: 0, height: 0)
    }

    /// Overlay
    private var overlay: some View {
        ZStack {
            EffectView(
                .fullScreenUI,
                blendingMode: .withinWindow,
                emphasized: false
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Const.overlayCornerRadius
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: Const.overlayCornerRadius)
                    .stroke(
                        Color(nsColor: .secondaryLabelColor)
                            .opacity(Const.overlayBorderColorOpacity),
                        lineWidth: Const.overlayBorderLineWidth
                    )
            }
            Image(systemName: "plus")
                .foregroundColor(Color(nsColor: .secondaryLabelColor))
                .font(.system(size: Const.overlayIconSize, weight: .light))
                .accessibilityLabel(Text("Add Split view"))
        }
        .matchedGeometryEffect(id: MatchedGeometryEffect.overlay, in: animation)
    }
}
