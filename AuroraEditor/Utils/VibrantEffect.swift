//
//  VibrantEffect.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 17/01/2023.
//

import SwiftUI

struct VibrantEffect: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()

        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .underWindowBackground

        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        //
    }
}
