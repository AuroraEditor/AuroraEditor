//
//  ContributersDetailView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct ContributersDetailView: View {

    @StateObject
    private var model: AboutViewModal = .shared

    private var gridItemLayout = [GridItem(.adaptive(minimum: 50))]

    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: gridItemLayout) {
                ForEach(model.contributers, id: \.id) { contributer in
                    Avatar().contributerAvatar(contributerAvatarURL: contributer.avatarURL)
                        .help(contributer.username)
                }
            }
            .padding(.vertical, 10)
        }
    }
}

struct ContributersDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContributersDetailView()
    }
}
