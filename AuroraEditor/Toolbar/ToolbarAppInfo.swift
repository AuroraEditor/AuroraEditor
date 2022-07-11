//
//  ToolbarAppInfo.swift
//  
//
//  Created by Nanashi Li on 2022/07/11.
//

import SwiftUI

public struct ToolbarAppInfo: View {

    public init(){}

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
                    .frame(width: 400)

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

            HStack {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .imageScale(.small)

                Text("2")
                    .foregroundColor(.secondary)
                    .font(.system(size: 10))
            }
            .padding(.trailing, 5)

            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)
                    .imageScale(.small)

                Text("147")
                    .foregroundColor(.secondary)
                    .font(.system(size: 10))
            }
            .padding(.trailing, 5)

            HStack {
                Image(systemName: "bell.badge.fill")
                    .symbolRenderingMode(.multicolor)
                    .imageScale(.small)

                Text("1K+")
                    .foregroundColor(.secondary)
                    .font(.system(size: 10))
            }
        }
    }
}

struct ToolbarAppInfo_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarAppInfo()
    }
}
