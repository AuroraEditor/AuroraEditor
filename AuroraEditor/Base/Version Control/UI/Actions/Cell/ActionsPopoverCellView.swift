//
//  ActionsPopoverCellView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ActionsPopoverCellView: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.diamond.fill")
                .symbolRenderingMode(.multicolor)

            Text("Set up job")
                .font(.system(size: 11))

            Spacer()

            Text("2s")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
    }
}

struct ActionsPopoverCellView_Previews: PreviewProvider {
    static var previews: some View {
        ActionsPopoverCellView()
    }
}
