//
//  HStackToggle.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct HStackToggle: View {

    @State
    public var text: String

    @Binding
    public var toggleValue: Bool

    var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .font(.system(size: 13,
                              weight: .medium))
            Spacer()
            Toggle("", isOn: $toggleValue)
                .labelsHidden()
                .toggleStyle(.switch)
        }
        .padding(.horizontal)
    }
}
