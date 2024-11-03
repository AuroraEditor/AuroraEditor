//
//  CachingImageView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/11/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit

/// A view that represents a caching image view.
class CachingImageView: NSView, Sendable {
    /// The image URL.
    private var imageUrl: URL?

    /// The image.
    var image: NSImage? {
        didSet {
            updateImageDisplay()
        }
    }

    /// The image view.
    private let imageView = NSImageView(frame: .zero)

    /// The image size.
    private var imageSize: NSSize = NSSize(width: 42, height: 42)

    /// The fallback image.
    private var fallbackImage: NSImage {
        if let image = NSImage(
            systemSymbolName: "person.crop.circle.fill",
            accessibilityDescription: ""
        ) {
            return image.resizing(to: imageSize)
        }

        return NSImage()
    }

    /// Make the CachingImageView.
    /// 
    /// - Parameter frameRect: The frame rect.
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupImageView()
    }

    /// Make the CachingImageView.
    /// 
    /// - Parameter coder: The coder.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }

    /// Set the image size.
    /// 
    /// - Parameter size: The size.
    func setImageSize(_ size: NSSize) {
        imageSize = size
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size.width),
            imageView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        updateImageDisplay()
    }

    /// Setup the image view.
    private func setupImageView() {
        addSubview(imageView)
        imageView.imageAlignment = .alignCenter
        imageView.imageScaling = .scaleProportionallyDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /// Update the image display.
    private func updateImageDisplay() {
        guard let image = image else { return }
        let resizedImage = image.resizing(to: imageSize)
        imageView.image = resizedImage
    }

    /// Load the image from the URL.
    /// 
    /// - Parameter url: The URL.
    func loadImage(from url: URL) {
        imageUrl = url
        if let cachedImage = ImageCache.shared.getCachedImage(url: url) {
            self.image = cachedImage
        } else {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self,
                      let data = data,
                      let response = response,
                      error == nil,
                      url == self.imageUrl else {
                    Task { @MainActor in
                        self?.image = self?.fallbackImage
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let image = NSImage(data: data) {
                        ImageCache.shared.cacheImage(data: data, response: response)
                        self.image = image
                    } else {
                        self.image = self.fallbackImage
                    }
                }
            }.resume()
        }
    }
}
