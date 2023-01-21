//
//  CreditsDetailView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct CreditsDetailView: View {
    var body: some View {
        ScrollView(.vertical) {
            Text(AboutViewModal().loadCredits())
        }
    }
}

struct CreditsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsDetailView()
    }
}
