//
//  Avatar.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/08.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

class Avatar {
    /// Get Git Avatar
    /// - Parameter authorEmail: Author's email
    /// - Returns: Avatar image
    public func gitAvatar(authorEmail: String) -> some View {
        VStack {
            // swiftlint:disable:next line_length
            AsyncImage(url: URL(string: "https://www.gravatar.com/avatar/\(Avatar().generateAvatarHash(authorEmail: authorEmail))")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 42, height: 42)
                } else if phase.error != nil {
                    self.defaultAvatar(authorEmail: authorEmail)
                } else {
                    self.defaultAvatar(authorEmail: authorEmail)
                }
            }
        }
    }

    private func defaultAvatar(authorEmail: String) -> some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .foregroundColor(Avatar().avatarColor(authorEmail: authorEmail))
                .frame(width: 42, height: 42)
        }
    }

    // send 404 if no image available, image size 84x84 (42x42 @2x)
    public func generateAvatarHash(authorEmail: String) -> String {
        let hash = authorEmail.md5(trim: true, caseSensitive: false)
        return "\(hash)?d=404&s=84"
    }

    public func avatarColor(authorEmail: String) -> Color {
        let hash = generateAvatarHash(authorEmail: authorEmail).hash
        switch hash % 12 {
        case 0: return .red
        case 1: return .orange
        case 2: return .yellow
        case 3: return .green
        case 4: return .mint
        case 5: return .teal
        case 6: return .cyan
        case 7: return .blue
        case 8: return .indigo
        case 9: return .purple
        case 10: return .brown
        case 11: return .pink
        default: return .teal
        }
    }
}
