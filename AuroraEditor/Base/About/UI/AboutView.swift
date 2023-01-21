//
//  AboutView.swift
//  Aurora Editor
//
//  Created by Andrei Vidrasco on 02.04.2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// swiftlint:disable:next missing_docs
public enum AboutDetailState {
    // swiftlint:disable:next missing_docs
    case license
    // swiftlint:disable:next missing_docs
    case contributers
    // swiftlint:disable:next missing_docs
    case credits
}

public struct AboutView: View {
    @Environment(\.openURL)
    private var openURL

    @State
    private var aboutDetailState: AboutDetailState = .license

    private let fade: Gradient = Gradient(colors: [.clear, .white])

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ApplicationsDetailsView(aboutDetailState: $aboutDetailState)
                    .frame(width: 260)
                switch aboutDetailState {
                case .license:
                    LicenseDetailView()
                        .frame(width: 400)
                case .contributers:
                    ZStack(alignment: .bottom) {
                        ContributersDetailView()
                            .mask(LinearGradient(gradient: fade,
                                                 startPoint: .bottom,
                                                 endPoint: .top))

                        ZStack {
                            Color.gray
                                .opacity(0.2)
                                .cornerRadius(20)
                            HStack {
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 11))
                                    .foregroundColor(.primary)
                                Text("AuroraEditor/Contributers")
                                    .font(.system(size: 11))
                                    .foregroundColor(.primary)
                            }
                        }
                        .frame(width: 180, height: 20)
                        .onTapGesture {
                            openURL(URL(string: "https://github.com/AuroraEditor/AuroraEditor/contributors")!)
                        }
                        .padding(.bottom)
                    }
                    .frame(width: 400)
                case .credits:
                    CreditsDetailView()
                        .frame(width: 400)
                }
            }
        }
        .background(.white)
    }

    public func showWindow() {
        AboutWindowHostingController(view: self,
                                    size: NSSize(width: 640,
                                                 height: 370))
        .showWindow(nil)
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .frame(width: 640, height: 370)
    }
}
