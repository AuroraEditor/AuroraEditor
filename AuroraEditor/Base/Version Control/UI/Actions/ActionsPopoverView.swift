//
//  ActionsPopoverView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//

import SwiftUI

struct ActionsPopoverView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Update nightly.yml")
                    .font(.system(size: 11))

                Text("(Build & Lint)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: "timer.circle")
                    .symbolRenderingMode(.hierarchical)
            }

            HStack {
                Text("In Progress...")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Spacer()
            }

            List {
                ForEach(0...11, id: \.self) { _ in
                    ActionsPopoverCellView()
                }
            }
            .listStyle(.plain)
            .overlay(alignment: .top) {
                Divider()
            }
            .overlay(alignment: .bottom) {
                Divider()
            }

            Button {
            } label: {
                Text("View Workflow on GitHub")
                    .foregroundColor(.white)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct ActionsPopoverView_Previews: PreviewProvider {
    static var previews: some View {
        ActionsPopoverView()
    }
}
