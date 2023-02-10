//
//  NotificationToastView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 10/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct NotificationToastView: View {

    @Environment(\.colorScheme)
    var colorScheme

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: "square.dashed.inset.filled")
                    .font(.system(size: 14))
                    .cornerRadius(5)

                Text("Docker")
                    .fontWithLineHeight(fontSize: 12,
                                        lineHeight: 7)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Now")
                    .fontWithLineHeight(fontSize: 11,
                                        lineHeight: 7)
                    .foregroundColor(.secondary)
            }

            Text("Update Available")
                .fontWithLineHeight(fontSize: 13,
                                    lineHeight: 8)
                .foregroundColor(.primary)
                .padding(.top, 10)

            Text("A new update of the docker extension for Aurora Editor is now available.")
                .fontWeight(.regular)
                .fontWithLineHeight(fontSize: 13,
                                    lineHeight: 8)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(width: 350, height: 105)
        .background(colorScheme == .light ? .white : Color(hex: "#252525"))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct NotificationToastView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationToastView()
    }
}
