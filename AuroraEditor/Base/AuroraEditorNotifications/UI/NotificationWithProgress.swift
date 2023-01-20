//
//  NotificationWithProgress.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/12.
//

import SwiftUI

struct NotificationWithProgress: View {
    let data: NotificationData
    @Binding
    var isPresented: Bool
    @Binding
    var isRemoved: Bool

    var body: some View {
        VStack {
            HStack {
                data.priority.icon

                VStack(alignment: .leading) {
                    Text(data.title)
                        .fontWeight(.medium)

                    Text(data.secondaryTitle)
                        .lineLimit(3)
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 5)
            }

//            ProgressView(data.progress!).padding(
//                EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
//            ).onChange(
//                of: data.progress,
//                perform: { value in
//                    if data.progress!.isFinished {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                            withAnimation {
//                                isRemoved = true
//                            }
//                        }
//                    }
//                }
//            )
//            .progressViewStyle(LinearProgressViewStyle())
        }
        .onTapGesture {
            withAnimation {
                isRemoved = true
            }
        }
    }
}
