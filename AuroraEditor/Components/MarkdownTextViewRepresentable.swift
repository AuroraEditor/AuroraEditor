//
//  MarkdownTextViewRepresentable.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

struct MarkdownTextViewRepresentable: NSViewRepresentable {
    let markdownText: String
    let tappableRanges: [NSRange]
    let onTap: (String) -> Void

    func makeNSView(context: Context) -> MarkdownTextView {
        MarkdownTextView(
            markdownText: markdownText,
            tappableRanges: tappableRanges,
            onTap: onTap
        )
    }

    func updateNSView(_ nsView: MarkdownTextView, context: Context) {}
}
