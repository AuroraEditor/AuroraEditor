//
//  NoCommitHistoryView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/04/19.
//

import SwiftUI

// When there is no commits on the opened file
// we will show this view as empty placeholder.
struct NoCommitHistoryView: View {
    var body: some View {
        VStack {
            Text("No History")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
}

struct NoCommitHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NoCommitHistoryView()
    }
}
