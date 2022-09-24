//
//  UpdateView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/23.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct UpdateView: View {
    var body: some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Automatic Updates")
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                        Text("On")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12, weight: .medium))
                        Button {

                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .buttonStyle(.plain)
                    }
                    Text("This IDE is currently enrolled in the Nightly Build Programme")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.vertical, -4)

                    Text("Learn more...")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                }
                .padding(5)
            }
            .padding(5)

            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Update Available")
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                        Button {

                        } label: {
                            Text("Update Now")
                        }
                    }

                    HStack {
                        Text("* Aurora Editor Nightly Build")
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("10MB")
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    Text("More Info...")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                        .padding(.vertical, 5)

                }
                .padding(5)
            }
            .padding(5)

            // swiftlint:disable:next line_length
            Text("Use of this software is subject to the original license agreement that accompanied the software being updated.")
                .multilineTextAlignment(.center)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .padding(5)
        }
    }
}

struct UpdateView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateView()
    }
}
