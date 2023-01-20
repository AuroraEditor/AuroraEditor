//
//  NotificationWithButton.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct NotificationWithButton: View {
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

            HStack {
                Text("Source: \(data.source ?? "")").lineLimit(2).font(.system(size: 12))
                    .foregroundColor(Color.gray)
                Spacer()
//                if data.primaryAction != nil {
//                    Text(data.primaryTitle)
//                        .foregroundColor(.white)
//                        .lineLimit(1)
//                        .font(.system(size: 12))
//                        .padding(.leading, 8)
//                        .padding(.trailing, 8)
//                        .padding(.top, 4)
//                        .padding(.bottom, 4)
//                        .cornerRadius(10)
//                        .onTapGesture {
//                            data.primaryAction?()
//                            withAnimation {
//                                isRemoved = true
//                            }
//                        }
//                }
//                if data.secondaryAction != nil {
//                    Text(data.secondaryTitle)
//                        .foregroundColor(.white)
//                        .lineLimit(1)
//                        .font(.system(size: 12))
//                        .padding(.leading, 8)
//                        .padding(.trailing, 8)
//                        .padding(.top, 4)
//                        .padding(.bottom, 4)
//                        .cornerRadius(10)
//                        .onTapGesture {
//                            data.secondaryAction?()
//                            withAnimation {
//                                isRemoved = true
//                            }
//                        }
//                }
            }
            .frame(height: 30)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 10)
        }
    }
}
