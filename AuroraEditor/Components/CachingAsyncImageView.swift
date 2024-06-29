//
//  CachingAsyncImageView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/11/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// A view that represents a caching async image view.
struct CachingAsyncImageView: NSViewRepresentable {
    /// The contributor avatar URL.
    let contributorAvatarURL: String

    /// The image size.
    let imageSize: CGFloat

    /// Make the CachingImageView.
    /// 
    /// - Parameter context: The context.
    /// 
    /// - Returns: The CachingImageView.
    func makeNSView(context: Context) -> CachingImageView {
        let view = CachingImageView()
        return view
    }

    /// Update the CachingImageView.
    /// 
    /// - Parameter nsView: The NSView.
    /// - Parameter context: The context.
    func updateNSView(_ nsView: CachingImageView, context: Context) {
        if let url = URL(string: contributorAvatarURL) {
            nsView.loadImage(from: url)
        }

        nsView.setImageSize(NSSize(width: imageSize, height: imageSize))
    }
}
