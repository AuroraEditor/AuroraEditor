//
//  CommitHistoryCellView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/08.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct CommitHistoryCellView: View {
    var body: some View {
        HStack {
            Avatar().gitAvatar(authorEmail: "tihannicopaxton1@gmail.com")

            VStack(alignment: .leading, spacing: 3) {
                Text("Nanashi Li")
                    .font(.system(size: 11))
                    .fontWeight(.bold)

                Text("Inspector: Added basic support for inspector (#470)")
                    .font(.system(size: 11))
                    .lineLimit(1)
            }

            Spacer()

            VStack {
                VStack(alignment: .trailing, spacing: 3) {
                    Text("e038595")
                        .font(.system(size: 10))
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .padding(.trailing, -5)
                                .padding(.leading, -5)
                                .foregroundColor(Color(nsColor: .quaternaryLabelColor))
                        )
                        .padding(.trailing, 5)

                    Text("10 minutes ago")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 1)
            }
        }
        .padding(.horizontal, 10)
    }
}

struct CommitHistoryCellView_Previews: PreviewProvider {
    static var previews: some View {
        CommitHistoryCellView()
    }
}
