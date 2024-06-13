//
//  PreferencesSection.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 03.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that wraps multiple ``PreferencesSection`` views and aligns them correctly.
public struct PreferencesContent<Content: View>: View {
    /// The view content
    private let content: Content

    /// Initializes a new preferences content view
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The view body
    public var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .padding()
    }
}

/// A view that wraps controls and more and adds a right aligned label.
public struct PreferencesSection<Content: View>: View {
    /// The title
    private let title: String
    /// The width
    private let width: Double
    /// Should we hide labels
    private let hideLabels: Bool
    /// The content
    private let content: Content
    /// The alignment
    private let align: VerticalAlignment

    /// Initializes a new preferences section
    /// 
    /// - Parameter title: The title
    /// - Parameter width: The width
    /// - Parameter hideLabels: Should we hide labels
    /// - Parameter align: The alignment
    /// - Parameter content: The content
    public init(
        _ title: String,
        width: Double = 300,
        hideLabels: Bool = true,
        align: VerticalAlignment = .firstTextBaseline,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.width = width
        self.hideLabels = hideLabels
        self.align = align
        self.content = content()
    }

    /// The view body
    public var body: some View {
        HStack(alignment: align) {
            /// We keep the ":" since it's being used by all preference views.
            Text("\(title):")
                .frame(width: width, alignment: .trailing)
            if hideLabels {
                VStack(alignment: .leading) {
                    content
                        .labelsHidden()
                        .fixedSize()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 20)
                }
            } else {
                VStack(alignment: .leading) {
                    content
                        .fixedSize()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 20)
                }
            }
        }
    }
}

struct PreferencesSection_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesSection("Title") {
            Picker("Test", selection: .constant(true)) {
                Text("Hi")
                    .tag(true)
            }
            Text("Whats up?")
        }
    }
}
