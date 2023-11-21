//
//  ContributersDetailView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

public struct ContributorsDetailView: View {

    @ObservedObject
    private var viewModel: AboutViewModal

    private let gridItemLayout = [GridItem(.adaptive(minimum: 50))]

    public init(viewModel: AboutViewModal) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: gridItemLayout) {
                ForEach(viewModel.contributers, id: \.id) { contributor in
                    Avatar().contributorAvatar(contributorAvatarURL: contributor.avatarURL)
                        .help(contributor.username)
                }
            }
            .padding(.vertical, 10)
        }
    }
}
