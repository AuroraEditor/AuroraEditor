//
//  ImageCache.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/11/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit

class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private let cache = URLCache(memoryCapacity: 100 * 1024 * 1024, // 100 MB memory cache
                                 diskCapacity: 500 * 1024 * 1024, // 500 MB disk cache
                                 diskPath: nil)

    func getCachedImage(url: URL) -> NSImage? {
        if let data = cache.cachedResponse(for: URLRequest(url: url))?.data {
            return NSImage(data: data)
        }
        return nil
    }

    func cacheImage(data: Data, response: URLResponse) {
        let cachedData = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedData, for: URLRequest(url: response.url!))
    }
}
