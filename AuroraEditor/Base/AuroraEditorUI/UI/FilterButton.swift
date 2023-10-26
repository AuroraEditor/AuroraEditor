//
//  FilterButton.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/17.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct FilterButton: View {
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 8))
                .symbolRenderingMode(.hierarchical)

            Image(systemName: "chevron.down")
                .font(.system(size: 8))
                .symbolRenderingMode(.hierarchical)
        }
        .padding(7)
        .border(Color.secondary, width: 0.5)
        .cornerRadius(20)
    }
}

struct FilterButtonPreview: PreviewProvider {
    static var previews: some View {
        FilterButton()
    }
}
