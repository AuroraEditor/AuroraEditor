//
//  LicenseDetailView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

public struct LicenseDetailView: View {
    public var body: some View {
        ScrollView(.vertical) {
            Text(.init(AboutViewModal().loadLicense()))
                .multilineTextAlignment(.leading)
                .font(.system(size: 11))
        }
        .frame(height: 300)
    }
}

struct LicenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseDetailView()
    }
}
