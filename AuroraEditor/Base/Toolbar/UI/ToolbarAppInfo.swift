//
//  ToolbarAppInfo.swift
//  
//
//  Created by Nanashi Li on 2022/07/11.
//

import SwiftUI

// Shows the project name, runtime instance and the build
// progress of a current project.
//
// This is still a work in progress.
public struct ToolbarAppInfo: View {

    @Environment(\.controlActiveState)
    private var activeState

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @State
    private var openErrors: Bool = false

    @State
    private var openWarnings: Bool = false

    @State
    private var openNotifications: Bool = false

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

                    Text("Today at " + getTime())
                        .font(.system(size: 11))
                }
            }
            .padding(5)
            .background(.ultraThinMaterial)
            .cornerRadius(6)

            Button {
                openErrors.toggle()
            } label: {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .imageScale(.small)

                    Text("\(workspace.errorList.count)")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                }
            }
            .buttonStyle(.plain)

            Button {
                openWarnings.toggle()
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .symbolRenderingMode(.multicolor)
                        .imageScale(.small)

                    Text("\(workspace.warningList.count)")
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

                    Text("\(workspace.notificationList.count)")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                }
            }
            .buttonStyle(.plain)
            .popover(isPresented: $openErrors, arrowEdge: .bottom) {
                Text("ERROR LIST:")
                NotificationCentreView()
                    .padding(.vertical, 5)
                    .frame(width: 310)
            }
            .popover(isPresented: $openWarnings, arrowEdge: .bottom) {
                Text("WARNING LIST:")
                NotificationCentreView()
                    .padding(.vertical, 5)
                    .frame(width: 310)
            }
            .popover(isPresented: $openNotifications, arrowEdge: .bottom) {
                Text("NOTIFICATION LIST:")
                NotificationCentreView()
                    .padding(.vertical, 5)
                    .frame(width: 310)
            }
        }
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}

struct ToolbarAppInfo_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarAppInfo()
    }
}
