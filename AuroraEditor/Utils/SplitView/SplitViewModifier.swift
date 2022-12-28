//
//  SplitViewModifier.swift
//
//  Created by Mateusz Bąk on 2022/07/07.
//

import SwiftUI

struct SplitViewModifier: ViewModifier {

    @Binding
    var proposalPosition: SplitViewProposalDropPosition?

    let availablePositions: [SplitViewProposalDropPosition]
    let margin: CGFloat
    let isProportional: Bool
    let hitboxSizes: [SplitViewProposalDropPosition: CGFloat]
    let onDrop: ((SplitViewProposalDropPosition, DropInfo) -> Void)?

    func body(content: Content) -> some View {
        GeometryReader { geometryProxy in
            ZStack {
                content
                    .onDrop(
                        of: ["public.file-url"],
                        delegate: SplitViewDropDelegate(
                            proposalPosition: $proposalPosition,
                            availablePositions: availablePositions,
                            geometryProxy: geometryProxy,
                            margin: margin,
                            hitboxSizes: isProportional ? getHitboxSizes(geometryProxy: geometryProxy) : hitboxSizes,
                            onDrop: onDrop
                        )
                    )

                SplitViewDropProposalOverlay(
                    proposalPosition: proposalPosition
                )
                .opacity(proposalPosition == nil ? 0 : 1)
            }
        }
    }

    func getHitboxSizes(geometryProxy: GeometryProxy) -> [SplitViewProposalDropPosition: CGFloat] {
        let localFrame = geometryProxy.frame(in: .local)
        return [
            .top: localFrame.height * (hitboxSizes[.top] ?? margin),
            .bottom: localFrame.height * (hitboxSizes[.bottom] ?? margin),
            .leading: localFrame.width * (hitboxSizes[.leading] ?? margin),
            .trailing: localFrame.width * (hitboxSizes[.trailing] ?? margin)
        ]
    }
}

extension View {
    /// Description
    ///
    /// - Parameters:
    ///   - availablePositions: availablePositions description
    ///   - proposalPosition: proposalPosition description
    ///   - margin: margin description
    ///   - isProportional: If true, the `margin` is used as a percentage of the frame for the dragging hitbox
    ///   - onDrop: onDrop description
    ///
    /// - Returns: description
    public func splitView(availablePositions: [SplitViewProposalDropPosition],
                          proposalPosition: Binding<SplitViewProposalDropPosition?>,
                          margin: CGFloat,
                          isProportional: Bool = false,
                          hitboxSizes: [SplitViewProposalDropPosition: CGFloat] = [:],
                          onDrop: ((SplitViewProposalDropPosition, DropInfo) -> Void)?) -> some View {
        modifier(SplitViewModifier(proposalPosition: proposalPosition,
                                   availablePositions: availablePositions,
                                   margin: margin,
                                   isProportional: isProportional,
                                   hitboxSizes: hitboxSizes,
                                   onDrop: onDrop))
    }
}
