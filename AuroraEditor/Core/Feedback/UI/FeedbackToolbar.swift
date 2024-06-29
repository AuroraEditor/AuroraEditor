//
//  FeedbackToolbar.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/14.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Feedback toolbar
struct FeedbackToolbar<T: View>: View {
    /// Content
    private var content: () -> T

    /// Initialize feedback toolbar
    /// 
    /// - Parameter bgColor: background color
    /// - Parameter content: content
    /// 
    /// - Returns: feedback toolbar
    init(bgColor: Color = Color(NSColor.controlBackgroundColor),
         @ViewBuilder content: @escaping () -> T) {
        self.content = content
    }

    /// Toolbar body
    var body: some View {
        ZStack {
            HStack {
                content()
                    .padding(.horizontal, 8)
            }
        }
    }
}
