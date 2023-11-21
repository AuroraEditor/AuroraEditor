//
//  CachingImageView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/11/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit

class CachingImageView: NSView {
    private var imageUrl: URL?

    var image: NSImage? {
        didSet {
            updateImageDisplay()
        }
    }

    private let imageView = NSImageView(frame: .zero)
    private var imageSize: NSSize = NSSize(width: 42, height: 42) // Default value

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupImageView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }

    func setImageSize(_ size: NSSize) {
        imageSize = size
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size.width),
            imageView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        updateImageDisplay()
    }

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

    private func updateImageDisplay() {
        guard let image = image else { return }
        let resizedImage = image.resizing(to: imageSize)
        imageView.image = resizedImage
    }

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
                    return
                }
                DispatchQueue.main.async {
                    if let image = NSImage(data: data) {
                        ImageCache.shared.cacheImage(data: data, response: response)
                        self.image = image
                    }
                }
            }.resume()
        }
    }
}
