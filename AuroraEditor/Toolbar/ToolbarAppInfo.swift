//
//  ToolbarAppInfo.swift
//  
//
//  Created by Nanashi Li on 2022/07/11.
//

import SwiftUI
import AuroraEditorNotifications

public struct ToolbarAppInfo: View {

    @State
    private var openNotifications: Bool = false

    public var body: some View {
        HStack(alignment: .center) {
            HStack {
                HStack {
                    Image(systemName: "app.dashed")

                    Text("AuroraEditor")
                        .font(.system(size: 11))

                    Image(systemName: "chevron.right")

                    Text("Chrome")
                        .font(.system(size: 11))
                }

                Spacer()

                HStack {
                    Text("Build Succeeded")
                        .font(.system(size: 11))

                    Text("|")

                    Text("Today at 17:45")
                        .font(.system(size: 11))
                }
            }
            .padding(5)
            .background(Rectangle().foregroundColor(Color(nsColor: NSColor(named: "ToolbarAppInfoBackground")!)))
            .cornerRadius(6)

            Button {
                NotificationManager().postProgressNotification(
                    title: "Test Notification",
                    progress: Progress(totalUnitCount: 100)
                )
            } label: {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .imageScale(.small)

                    Text("2")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                }
            }
            .buttonStyle(.plain)

            Button {
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .symbolRenderingMode(.multicolor)
                        .imageScale(.small)

                    Text("147")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                }
            }
            .buttonStyle(.plain)

            Button {
                openNotifications.toggle()
            } label: {
                HStack {
                    Image(systemName: "bell.badge.fill")
                        .symbolRenderingMode(.multicolor)
                        .imageScale(.small)

                    Text("1K+")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                }
            }
            .buttonStyle(.plain)
            .popover(isPresented: $openNotifications, arrowEdge: .bottom) {
                NotificationCentreView()
                    .padding(.vertical, 5)
                    .frame(width: 310)
            }
        }
    }
}

struct ToolbarAppInfo_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarAppInfo()
    }
}
