//
//  PressActionsModifier.swift
//  Aurora Editor
//
//  Created by Gabriel Theodoropoulos on 1/11/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A custom view modifier for press actions with callbacks for `onPress` and `onRelease`.
public struct PressActions: ViewModifier {
    /// The action to perform once the view is pressed.
    var onPress: () -> Void

    /// The action to perform once the view press is released.
    var onRelease: () -> Void

    /// Initializes the view modifier with the provided `onPress` and `onRelease` actions.
    /// - Parameter onPress: The action to perform once the view is pressed.
    /// - Parameter onRelease: The action to perform once the view press is released.
    public init(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) {
        self.onPress = onPress
        self.onRelease = onRelease
    }

    /// The body of the view modifier.
    /// 
    /// - Parameter content: The content view.
    /// 
    /// - Returns: some View
    public func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

public extension View {
    /// A custom view modifier for press actions with callbacks for `onPress` and `onRelease`.
    /// - Parameters:
    ///   - onPress: Action to perform once the view is pressed.
    ///   - onRelease: Action to perform once the view press is released.
    /// - Returns: some View
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}
