//
//  LoaderView.swift
//  Aurora Editor Updater
//
//  Created by Nanashi Li on 2023/10/09.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct LoaderView: View {

    @State var animateLoaders: Bool = false

    var body: some View {
        ZStack {
            Color.clear
                .edgesIgnoringSafeArea(.all)
            ZStack {
                Loader(loaderState: .down, timerDuration: 0.35, startAnimating: $animateLoaders)
                Loader(loaderState: .right, timerDuration: 1.05, startAnimating: $animateLoaders)
                Loader(loaderState: .up, timerDuration: 1.75, startAnimating: $animateLoaders)
            }
            .offset(x: -40, y: -40)
        }.onAppear {
            self.animateLoaders.toggle()
        }
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView()
    }
}
