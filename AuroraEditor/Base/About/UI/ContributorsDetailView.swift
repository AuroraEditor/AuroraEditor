//
//  ContributersDetailView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The view that displays the details of the contributors
public struct ContributorsDetailView: View {
    @ObservedObject
    /// The view model
    private var viewModel: AboutViewModal

    /// The grid item layout
    private let gridItemLayout = [GridItem(.adaptive(minimum: 50))]

    /// Initializes the view
    /// 
    /// - Parameter viewModel: The view model
    public init(viewModel: AboutViewModal) {
        self.viewModel = viewModel
    }

    /// The view body
    public var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: gridItemLayout) {
                ForEach(viewModel.contributors, id: \.id) { contributor in
                    Avatar()
                        .contributorAvatar(contributorAvatarURL: contributor.avatarURL)
                        .help(contributor.username)
                }
            }
            .padding(.vertical, 10)
        }
    }
}
