//
//  CachingAsyncImageView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/11/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

struct CachingAsyncImageView: NSViewRepresentable {
    let contributorAvatarURL: String
    let imageSize: CGFloat

    func makeNSView(context: Context) -> CachingImageView {
        let view = CachingImageView()
        return view
    }

    func updateNSView(_ nsView: CachingImageView, context: Context) {
        if let url = URL(string: contributorAvatarURL) {
            nsView.loadImage(from: url)
        }
        nsView.setImageSize(NSSize(width: imageSize, height: imageSize))
    }
}
