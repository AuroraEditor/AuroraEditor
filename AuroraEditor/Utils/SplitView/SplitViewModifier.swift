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
    let onDrop: ((SplitViewProposalDropPosition) -> Void)?

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
                            onDrop: onDrop
                        )
                    )

                if let proposalPosition = proposalPosition {
                    SplitViewDropProposalOverlay(
                        proposalPosition: proposalPosition
                    )
                }
            }
        }
    }
}

extension View {
    /// Description
    ///
    /// - Parameters:
    ///   - availablePositions: availablePositions description
    ///   - proposalPosition: proposalPosition description
    ///   - margin: margin description
    ///   - onDrop: onDrop description
    ///
    /// - Returns: description
    public func splitView(availablePositions: [SplitViewProposalDropPosition],
                          proposalPosition: Binding<SplitViewProposalDropPosition?>,
                          margin: CGFloat,
                          onDrop: ((SplitViewProposalDropPosition) -> Void)?) -> some View {
        modifier(SplitViewModifier(proposalPosition: proposalPosition,
                                   availablePositions: availablePositions,
                                   margin: margin,
                                   onDrop: onDrop))
    }
}
