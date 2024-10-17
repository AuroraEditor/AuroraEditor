//
//  FontPickerView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 23.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A delegate for the `FontPicker` view.
final class FontPickerDelegate {
    /// The parent view.
    var parent: FontPicker

    /// Creates a new instance of the delegate.
    /// - Parameter parent: The parent view.
    init(_ parent: FontPicker) {
        self.parent = parent
    }

    /// Changes the font.
    @objc
    @MainActor
    func changeFont(_ id: Any) {
        parent.fontSelected()
    }
}

/// A view that opens a `NSFontPanel` in order to choose a font installed on the system.
public struct FontPicker: View {
    /// The label string.
    private let labelString: String

    /// The font name.
    @Binding
    private var fontName: String

    /// The font size.
    @Binding
    private var fontSize: Int

    /// The font picker delegate.
    @State
    private var fontPickerDelegate: FontPickerDelegate?

    /// The font.
    private var font: NSFont {
        get {
            NSFont(name: fontName, size: CGFloat(fontSize)) ?? .systemFont(ofSize: CGFloat(fontSize))
        }
        set {
            self.fontName = newValue.fontName
            self.fontSize = Int(newValue.pointSize)
        }
    }

    /// Creates a new instance of the `FontPicker` view.
    /// - Parameter label: The label string.
    /// - Parameter name: The font name.
    /// - Parameter size: The font size.
    public init(_ label: String, name: Binding<String>, size: Binding<Int>) {
        self.labelString = label
        self._fontName = name
        self._fontSize = size
    }

    /// The view body.
    public var body: some View {
        HStack {
            Text(labelString)
                .lineLimit(1)
                .truncationMode(.middle)

            Button {
                if NSFontPanel.shared.isVisible {
                    NSFontPanel.shared.orderOut(nil)
                    return
                }

                self.fontPickerDelegate = FontPickerDelegate(self)
                NSFontManager.shared.target = self.fontPickerDelegate
                NSFontPanel.shared.setPanelFont(self.font, isMultiple: false)
                NSFontPanel.shared.orderBack(nil)
            } label: {
                Text("Select...")
            }
            .fixedSize()
        }
    }

    /// The font has been selected.
    mutating func fontSelected() {
        self.font = NSFontPanel.shared.convert(self.font)
    }
}

struct FontPicker_Previews: PreviewProvider {
    static var previews: some View {
        FontPicker("Font Picker", name: .constant("SF-MonoMedium"), size: .constant(11))
            .padding()
    }
}
