//
//  ThemePreviewIcon.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

struct ThemePreviewIcon: View {
    init(_ theme: AuroraTheme, selection: Binding<AuroraTheme?>, colorScheme: ColorScheme) {
        self.theme = theme
        self._selection = selection
        self.colorScheme = colorScheme
    }

    var theme: AuroraTheme

    @Binding
    var selection: AuroraTheme?

    var colorScheme: ColorScheme

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(Color(hex: colorScheme == .dark ? 0x4c4c4c : 0xbbbbbb))

                HStack(spacing: 1) {
                    sidebar
                    content
                }
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(1)
            }
            .padding(1)
            .frame(width: 130, height: 88)
            .shadow(color: Color(NSColor.shadowColor).opacity(0.1), radius: 8, x: 0, y: 2)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(lineWidth: 2)
                    .foregroundColor(selection == theme ? .accentColor : .clear)
            }
            Text(theme.displayName)
                .font(.subheadline)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .foregroundColor(selection == theme ? .white : .primary)
                .background(Capsule().foregroundColor(selection == theme ? .accentColor : .clear))
        }
        .help(theme.metadataDescription)
        .onTapGesture {
            withAnimation(.interactiveSpring()) {
                self.selection = theme
            }
        }
    }

    private var sidebar: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(Color(hex: colorScheme == .dark ? 0x383838 : 0xd0d0d0))
                .frame(width: 36)

            HStack(spacing: 1.5) {
                Circle().foregroundColor(.red)
                Circle().foregroundColor(Color(hex: 0xf9b82d))
                Circle().foregroundColor(.green)
            }
            .frame(width: 12, height: 3)
            .padding(4)
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(Color(hex: colorScheme == .dark ? 0x2b2b2b : 0xe0e0e0))
                .frame(height: 10)
            Rectangle()
                .foregroundColor(theme.editor.background.swiftColor)
                .overlay(alignment: .topLeading) {
                    codeWindow
                }
        }
    }

    private var codeWindow: some View {
        VStack(alignment: .leading, spacing: 4) {
            block1
            block2
            block3
            block4
            block5
        }
        .padding(.top, 6)
        .padding(.leading, 6)
    }

    private var block1: some View {
        codeStatement(colorHexForScope(scope: "comment"), length: 25)
    }

    private var block2: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeStatement(colorHexForScope(scope: "keyword"), length: 6)
                codeStatement(colorHexForScope(scope: "variable"), length: 6)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(colorHexForScope(scope: "support.constant"), length: 8)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(colorHexForScope(scope: "support.constant"), length: 8)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(colorHexForScope(scope: "keyword"), length: 6)
                codeStatement(colorHexForScope(scope: "string"), length: 7)
            }
            HStack(spacing: 1) {
                codeStatement(colorHexForScope(scope: "keyword"), length: 6)
                codeStatement(colorHexForScope(scope: "variable"), length: 8)
                codeStatement(colorHexForScope(scope: "keyword"), length: 6)
                codeStatement(colorHexForScope(scope: "string"), length: 12)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeStatement(colorHexForScope(scope: "keyword"), length: 6)
                codeStatement(colorHexForScope(scope: "string"), length: 14)
                codeStatement(theme.editor.text.color, length: 1)
            }
        }
    }

    private var block3: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeStatement(colorHexForScope(scope: "keyword"), length: 4)
                codeStatement(colorHexForScope(scope: "variable"), length: 8)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(theme.editor.text.color, length: 3)
                codeStatement(colorHexForScope(scope: "constant"), length: 1)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(theme.editor.text.color, length: 6)
                codeStatement(colorHexForScope(scope: "string"), length: 7)
                codeStatement(colorHexForScope(scope: "string"), length: 5)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(theme.editor.text.color, length: 5)
                codeStatement(colorHexForScope(scope: "keyword"), length: 5)
            }
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeStatement(theme.editor.text.color, length: 2)
            }
        }
    }

    private var block4: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeStatement(colorHexForScope(scope: "keyword"), length: 6)
                codeStatement(colorHexForScope(scope: "keyword"), length: 7)
                codeStatement(colorHexForScope(scope: "meta.function"), length: 8)
                codeStatement(colorHexForScope(scope: "constant"), length: 3)
                codeStatement(theme.editor.text.color, length: 2)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(colorHexForScope(scope: "keyword"), length: 4)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(colorHexForScope(scope: "variable"), length: 5)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(colorHexForScope(scope: "constant"), length: 8)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(colorHexForScope(scope: "storage.type"), length: 8)
                codeStatement(theme.editor.text.color, length: 2)
            }
        }
    }

    private var block5: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(colorHexForScope(scope: "keyword"), length: 4)
                codeStatement(colorHexForScope(scope: "variable"), length: 10)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(colorHexForScope(scope: "storage.type"), length: 11)
                codeStatement(theme.editor.text.color, length: 3)
                codeStatement(colorHexForScope(scope: "keyword"), length: 2)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(colorHexForScope(scope: "variable"), length: 8)
                codeStatement(theme.editor.text.color, length: 2)
                codeStatement(colorHexForScope(scope: "variable"), length: 5)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(colorHexForScope(scope: "keyword"), length: 2)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(7)
                codeStatement(colorHexForScope(scope: "keyword"), length: 3)
                codeStatement(colorHexForScope(scope: "variable"), length: 12)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(9)
                codeStatement(theme.editor.text.color, length: 3)
                codeStatement(colorHexForScope(scope: "string"), length: 1)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(9)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(9)
                codeStatement(theme.editor.text.color, length: 3)
                codeStatement(colorHexForScope(scope: "variable"), length: 5)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(colorHexForScope(scope: "storage.type"), length: 6)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(colorHexForScope(scope: "constant.numeric"), length: 1)
                codeStatement(theme.editor.text.color, length: 1)
            }
        }
    }

    private func codeStatement(_ color: String, length: Double) -> some View {
        Rectangle()
            .foregroundColor(Color(hex: color))
            .frame(width: length, height: 2)
    }

    private func codeSpace(_ length: Double) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: length-1, height: 2)
    }

    private func colorHexForScope(scope: String) -> String {
        let comment = theme.editor.highlightTheme.settings.first(where: {
            $0.scope.split(separator: ".").map({ String($0) }).contains(scope) || // Scope components contain the scope
            $0.scope.contains(".\(scope).") ||  // Contains the scope
            $0.scope.hasPrefix("\(scope).") ||  // Starts with the scope
            $0.scope.hasSuffix(".\(scope)") ||  // Ends with the scope
            $0.scope == scope                   // Is the scope
        })
        let color = comment?.attributes.first(where: { $0 is ColorThemeAttribute })
        let hexString = (color as? ColorThemeAttribute)?.color.hexString
        return hexString ?? theme.editor.text.nsColor.hexString // use the default text color as fallback
    }
}

 private struct ThemePreviewIcon_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreviewIcon(ThemeModel.shared.themes.first!,
                         selection: .constant(ThemeModel.shared.themes.first),
                         colorScheme: .light)
            .preferredColorScheme(.light)

        ThemePreviewIcon(ThemeModel.shared.themes.last!,
                         selection: .constant(nil),
                         colorScheme: .dark)
            .preferredColorScheme(.dark)
    }
 }
