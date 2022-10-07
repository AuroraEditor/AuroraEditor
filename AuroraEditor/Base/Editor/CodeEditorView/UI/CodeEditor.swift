//
//  CodeEditor.swift
//
//  Created by Manuel M T Chakravarty on 23/08/2020.
//
//  SwiftUI 'CodeEditor' view

import SwiftUI

/// SwiftUI code editor based on TextKit.
public struct CodeEditor {

    /// Specification of the editor layout.
    public struct LayoutConfiguration: Equatable {

        /// Show the minimap if possible. (Currently only supported on macOS.)
        ///
        public let showMinimap: Bool

        /// Creates a layout configuration.
        ///
        /// - Parameter showMinimap: Whether to show the minimap if possible.\
        /// It may not be possible on all supported OSes.
        public init(showMinimap: Bool) {
            self.showMinimap = showMinimap
        }

        public static let standard = LayoutConfiguration(showMinimap: true)
    }

    /// Specification of a text editing position; i.e., text selection and scroll position.
    public struct Position: Equatable {

        /// Specification of a list of selection ranges.
        ///
        /// * A range with a zero length indicates an insertion point.
        /// * An empty array, corresponds to an insertion point at position 0.
        /// * On iOS, this can only always be one range.
        public var selections: [NSRange]

        /// The editor vertical scroll position. The value is between 0 and 1,
        /// which represent the completely scrolled up and down position, respectively.
        public var verticalScrollFraction: CGFloat

        public init(selections: [NSRange], verticalScrollFraction: CGFloat) {
            self.selections = selections
            self.verticalScrollFraction = verticalScrollFraction
        }

        public init() {
            self.init(selections: [NSRange(location: 0, length: 0)], verticalScrollFraction: 0)
        }
    }

    let layout: LayoutConfiguration

    @Binding var text: String
    @Binding var position: Position
    @Binding var caretPosition: CursorLocation
    @Binding var messages: Set<Located<Message>>
    @State var theme: AuroraTheme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!

    /// Creates a fully configured code editor.
    ///
    /// - Parameters:
    ///   - text: Binding to the edited text.
    ///   - position: Binding to the current edit position.
    ///   - messages: Binding to the messages reported at the appropriate lines of the edited text. NB: Messages
    ///               processing and display is relatively expensive. Hence, there should only be a limited number of
    ///               simultaneous messages and they shouldn't change to frequently.
    ///   - language: Language configuration for highlighting and similar.
    ///   - layout: Layout configuration determining the visible elements of the editor view.
    public init(text: Binding<String>,
                position: Binding<Position>,
                caretPosition: Binding<CursorLocation>,
                messages: Binding<Set<Located<Message>>>,
                layout: LayoutConfiguration = .standard,
                theme: AuroraTheme
    ) {
        self._text = text
        self._position = position
        self._caretPosition = caretPosition
        self._messages = messages
        self.layout = layout
        self.theme = theme
    }

    public class TCoordinator {
        @Binding var text: String
        @Binding var position: Position
        @Binding var caretPosition: CursorLocation

        /// In order to avoid update cycles, where view code tries to update SwiftUI state variables (such as the view's
        /// bindings) during a SwiftUI view update, we use `updatingView` as a flag that indicates whether the view is
        /// being updated, and hence, whether state updates ought to be avoided or delayed.
        public var updatingView = false

        /// This is the last observed value of `messages`, to enable us to compute the difference in the next update.
        public var lastMessages: Set<Located<Message>> = Set()

        init(_ text: Binding<String>, _ position: Binding<Position>, _ caretPosition: Binding<CursorLocation>) {
            self._text = text
            self._position = position
            self._caretPosition = caretPosition
        }
    }
}
