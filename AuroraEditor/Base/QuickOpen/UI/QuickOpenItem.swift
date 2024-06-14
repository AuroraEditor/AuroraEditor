//
//  QuickOpenItem.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 20.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents a single item in the quick open list.
public struct QuickOpenItem: View {
    /// Base directory
    private let baseDirectory: URL

    /// File item
    private let fileItem: FileSystemClient.FileItem

    /// Initialize a new QuickOpenItem
    /// 
    /// - Parameter baseDirectory: base directory
    /// - Parameter fileItem: file item
    /// 
    /// - Returns: a new QuickOpenItem
    public init(
        baseDirectory: URL,
        fileItem: FileSystemClient.FileItem
    ) {
        self.baseDirectory = baseDirectory
        self.fileItem = fileItem
    }

    /// The view body.
    public var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: fileItem.url.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 0) {
                Text(fileItem.url.lastPathComponent).font(.system(size: 13))
                    .lineLimit(1)
                Text(fileItem.url.path.replacingOccurrences(of: baseDirectory.path, with: ""))
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }.padding(.trailing, 15)
            Spacer()
        }
    }
}
