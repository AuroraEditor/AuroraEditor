//
//  AboutView.swift
//  Aurora Editor
//
//  Created by Andrei Vidrasco on 02.04.2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Which page is presented right now
public enum AboutDetailState {
    /// Licence page
    case license
    /// Contributors page
    case contributers
    /// Credits page
    case credits
}

public struct AboutView: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject var viewModel = AboutViewModal()

    private let fade: Gradient = Gradient(colors: [.clear, .white])

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ApplicationsDetailsView(aboutDetailState: $viewModel.aboutDetailState)
                    .frame(width: 260)

                Group {
                    switch viewModel.aboutDetailState {
                    case .license:
                        LicenseDetailView()
                    case .contributers:
                        contributorsView
                    case .credits:
                        CreditsDetailView()
                    }
                }.frame(width: 400)
            }
        }
        .background(.regularMaterial)
    }

    private var contributorsView: some View {
        ZStack(alignment: .bottom) {
            ContributorsDetailView(viewModel: viewModel)
                .mask(LinearGradient(gradient: fade, startPoint: .bottom, endPoint: .top))
            contributorFooter
        }
    }

    private var contributorFooter: some View {
        let contributorsURL = "https://github.com/AuroraEditor/AuroraEditor/contributors"
        return ZStack {
            Color.gray.opacity(0.2).cornerRadius(20)
            HStack {
                Image(systemName: "arrow.right.circle")
                Text("AuroraEditor/Contributors")
            }
            .font(.system(size: 11))
            .foregroundColor(.primary)
        }
        .frame(width: 180, height: 20)
        .onTapGesture {
            if let url = URL(string: contributorsURL) {
                openURL(url)
            }
        }
        .padding(.bottom, 25)
    }

    public func showWindow() {
        AboutWindowHostingController(view: self, size: NSSize(width: 640, height: 370))
            .showWindow(nil)
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .frame(width: 640, height: 370)
    }
}
