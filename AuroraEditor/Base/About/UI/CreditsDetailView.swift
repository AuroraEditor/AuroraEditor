//
//  CreditsDetailView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The view that displays the details of the credits
struct CreditsDetailView: View {
    /// The view body
    var body: some View {
        ScrollView(.vertical) {
            Text(.init(AboutViewModal().loadCredits()))
                .multilineTextAlignment(.leading)
                .font(.system(size: 11))
        }
        .frame(height: 300)
    }
}

struct CreditsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsDetailView()
    }
}
