//
//  WorkflowJob.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/17.
//

import SwiftUI

struct WorkflowJob: View {
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                Text("Build")
                    .font(.system(size: 14, weight: .bold))

                Spacer()

                Button {

                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)

                Button {

                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
}

struct WorkflowJob_Previews: PreviewProvider {
    static var previews: some View {
        WorkflowJob()
    }
}
