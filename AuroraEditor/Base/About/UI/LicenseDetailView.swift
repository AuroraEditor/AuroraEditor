//
//  LicenseDetailView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct LicenseDetailView: View {
    var body: some View {
        ScrollView(.vertical) {
            Text(AboutViewModal().loadLicense())
                .multilineTextAlignment(.leading)
                .font(.system(size: 11))
        }
        .frame(height: 370)
    }
}

struct LicenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseDetailView()
    }
}
