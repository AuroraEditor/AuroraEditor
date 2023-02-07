//
//  ToolbarAppInfo.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/11.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// Shows the project name, runtime instance and the build
// progress of a current project.
//
// This is still a work in progress.
public struct ToolbarAppInfo: View {

    @Environment(\.controlActiveState)
    private var activeState

    private let notificationService: NotificationService = .init()

    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let dateString = formatter.string(from: Date())
        return dateString
    }

    public var body: some View {
        HStack(alignment: .center) {
            HStack {
                HStack {
                    Image(systemName: "app.dashed")
                        .onTapGesture {
                            notificationService.error(message: "This is a error notification")

                            Log.debug("Notification Added")
                        }

                    Text("AuroraEditor")
                        .font(.system(size: 11))
                        .onTapGesture {
                            notificationService.warn(message: "This is a warning notification")

                            Log.debug("Notification Added")
                        }

                    Image(systemName: "chevron.right")

                    Text("Chrome")
                        .font(.system(size: 11))
                        .onTapGesture {
                            notificationService.error(message: "This is a error notification")

                            Log.debug("Notification Added")
                        }
                }

                Spacer()

                HStack {
                    Text("Build Succeeded")
                        .font(.system(size: 11))

                    Text("|")

                    Text("Today at " + getTime())
                        .font(.system(size: 11))
                }
            }
            .padding(5)
            .background(.ultraThinMaterial)
            .cornerRadius(6)

            NotificationIndicators()
        }
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}

struct ToolbarPopoverView: View {
    var list: [String]

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    var body: some View {
        List(list, id: \.self) { message in
            Text(message)
        }
        .padding(.horizontal)
    }
}

struct ToolbarAppInfo_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarAppInfo()
    }
}
