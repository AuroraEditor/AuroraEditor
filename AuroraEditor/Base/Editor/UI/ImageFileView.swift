//
//  ImageFileView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/16.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Image file view
public struct ImageFileView: View {
    /// The image to display
    private let image: NSImage?

    /// Initialize image file view
    /// 
    /// - Parameter image: image
    public init(image: NSImage?) {
        self.image = image
    }

    /// The body of the view
    public var body: some View {
        GeometryReader { proxy in
            if let image = image {
                if image.size.width > proxy.size.width || image.size.height > proxy.size.height {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel("Image preview")
                } else {
                    Image(nsImage: image)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .accessibilityLabel("Image preview")
                }
            } else {
                EmptyView()
            }
        }
    }
}
