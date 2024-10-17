//
//  Loader.swift
//  Aurora Editor Updater
//
//  Created by Nanashi Li on 2023/10/09.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Loader animation
struct Loader: View {
    /// Capsule width
    @State
    var capsuleWidth: CGFloat = 40

    /// Capsule height
    @State
    var capsuleHeight: CGFloat = 40

    /// Capsule x offset
    @State
    var xOffset: CGFloat = 0

    /// Capsule y offset
    @State
    var yOffset: CGFloat = 0

    /// Loader state
    @State
    var loaderState: LoaderState

    /// Current index
    @State
    var currentIndex = 0

    /// Animation started
    @State
    var animationStarted: Bool = true

    /// Timer duration
    var timerDuration: TimeInterval

    /// Start animating
    @Binding
    var startAnimating: Bool

    /// The view body
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            Capsule()
                .stroke(style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .foregroundColor(Color.white)
                .frame(width: capsuleWidth, height: capsuleHeight, alignment: .center)
                .animation(
                    Animation.easeOut(duration: 0.35),
                    value: UUID()
                )
                .offset(x: self.xOffset, y: self.yOffset)

        })
        .frame(width: 40,
               height: 0,
               alignment: loaderState.alignment)
        .onAppear {
            self.setIndex()
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (initialTimer) in
                if self.startAnimating {
                    Timer.scheduledTimer(withTimeInterval: self.timerDuration, repeats: false) { _ in
                        self.animateCapsule()
                        Timer.scheduledTimer(withTimeInterval: 2.1, repeats: true) { (loaderTimer) in
                            if !self.startAnimating {
                                loaderTimer.invalidate()
                            }
                            self.loaderState = self.getNextCase()
                            self.animateCapsule()
                        }
                    }
                    // invalidate the initialTimer that starts the animation once the binding constant is true
                    initialTimer.invalidate()
                }
            }
        }
    }

    /// provides the next case defined in the enum based on the currentIndex
    /// 
    /// - Returns: the next case
    func getNextCase() -> LoaderState {
        let allCases = LoaderState.allCases
        if self.currentIndex == allCases.count - 1 {
            self.currentIndex = -1
        }
        self.currentIndex += 1
        let index = self.currentIndex
        return allCases[index]
    }

    /// sets the initialIndex & offset values based on the loader state provided to the view
    func setIndex() {
        for (index, loaderCase) in LoaderState.allCases.enumerated()
        where loaderCase == self.loaderState {
            self.currentIndex = index
            self.xOffset = LoaderState.allCases[self.currentIndex].incrementBefore.0
            self.yOffset = LoaderState.allCases[self.currentIndex].incrementBefore.1
        }
    }

    /// animates the capsule to a direction
    @MainActor
    func animateCapsule() {
        self.xOffset = self.loaderState.incrementBefore.0
        self.yOffset = self.loaderState.incrementBefore.1
        self.capsuleWidth = self.loaderState.incrementBefore.2
        self.capsuleHeight = self.loaderState.incrementBefore.3

        Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { _ in
            self.xOffset = self.loaderState.incrementAfter.0
            self.yOffset = self.loaderState.incrementAfter.1
            self.capsuleWidth = self.loaderState.incrementAfter.2
            self.capsuleHeight = self.loaderState.incrementAfter.3
        }
    }
}

struct Loader_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            Loader(loaderState: .down, timerDuration: 0.35, startAnimating: .constant(true))
        }
    }
}
