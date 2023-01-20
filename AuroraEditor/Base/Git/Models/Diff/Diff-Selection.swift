//
//  Diff-Selection.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/29.
//

import Foundation

/// The state of a file's diff selection
enum DiffSelectionType: String {
    /// The entire file should be committed
    case all = "All"
    /// A subset of lines in the file have been selected for committing
    case partial = "Partial"
    /// The file should be excluded from committing
    case none = "None"
}

/// Utility function which determines whether a boolean selection state
/// matches the given DiffSelectionType. A true selection state matches
/// DiffSelectionType.All, a false selection state matches
/// DiffSelectionType.None and if the selection type is partial there's
/// never a match.
func typeMatchesSelection(selectionType: DiffSelectionType,
                          selected: Bool) throws -> Bool {
    switch selectionType {
    case .all:
        return selected
    case .none:
        return !selected
    case .partial:
        return false
    default:
        throw DiffSelectionError.unknownSelectionType("Uknown selection type \(selectionType)")
    }
}

/// An immutable, efficient, storage object for tracking selections of indexable
/// lines. While general purpose by design this is currently used exclusively for
/// tracking selected lines in modified files in the working directory.
///
/// This class starts out with an initial (or default) selection state, ie
/// either all lines are selected by default or no lines are selected by default.
///
/// The selection can then be transformed by marking a line or a range of lines
/// as selected or not selected. Internally the class maintains a list of lines
/// whose selection state has diverged from the default selection state.
class DiffSelection {

    var defaultSelectionType: DiffSelectionType

    /// Any line numbers where the selection differs from the default state.
    var divergingLines: Set<Int>?

    /// Optional set of line numbers which can be selected.
    var selectableLines: Set<Int>?

    /// Initialize a new selection instance where either all lines are selected by default
    /// or not lines are selected by default.
    public func fromInitialSelection(initialSelection: DiffSelectionType) throws -> DiffSelection {
        if initialSelection != .all && initialSelection != .none {
            // swiftlint:disable:next line_length
            throw DiffSelectionError.unknownDiffSelection("Can only instantiate a DiffSelection with All or None as the initial selection")
        }

        return DiffSelection(defaultSelectionType: initialSelection,
                             divergingLines: nil,
                             selectableLines: nil)
    }

    init(defaultSelectionType: DiffSelectionType,
         divergingLines: Set<Int>? = nil,
         selectableLines: Set<Int>? = nil) {
        self.defaultSelectionType = defaultSelectionType
        self.divergingLines = divergingLines
        self.selectableLines = selectableLines
    }

    /// Returns a value indicating the computed overall state of the selection
    public func getSelectionType() -> DiffSelectionType {
        let divergingLines = self.divergingLines
        let selectableLines = self.selectableLines

        // No diverging lines, happy path. Either all lines are selected or none are.
        // swiftlint:disable:next control_statement
        if (divergingLines == nil) {
            return self.defaultSelectionType
        }

        // swiftlint:disable:next control_statement
        if ((divergingLines?.isEmpty) != nil) {
            return self.defaultSelectionType
        }

        // If we know which lines are selectable we need to check that
            // all lines are divergent and return the inverse of default selection.
            // To avoid looping through the set that often our happy path is
            // if there's a size mismatch.
        if (selectableLines != nil) && selectableLines?.count == divergingLines?.count {
            var allSelectableLinesAreDivergent: Bool = false

            for line in selectableLines! {
                allSelectableLinesAreDivergent = divergingLines!.contains(line)
            }

            if allSelectableLinesAreDivergent {
                return self.defaultSelectionType == .all ? .none : .all
            }
        }

        // Note that without any selectable lines we'll report partial selection
            // as long as we have any diverging lines since we have no way of knowing
            // if _all_ lines are divergent or not
        return .partial
    }

    /// Returns a value indicating wether the given line number is selected or not
    public func isSelected(lineIndex: Int) throws -> Bool {
        let lineIsDivergent = (self.divergingLines == nil) && ((self.divergingLines?.contains(lineIndex)) != nil)

        if self.defaultSelectionType == .all {
            return !lineIsDivergent
        } else if self.defaultSelectionType == .none {
            return lineIsDivergent
        } else {
            throw DiffSelectionError.unknownBaseSelection("Unknown base selection type \(self.defaultSelectionType)")
        }
    }

    /// Returns a value indicating wether the given line number is selectable.
    /// A line not being selectable usually means it's a hunk header or a context
    /// line.
    public func isSelectable(lineIndex: Int) -> Bool {
        return (((self.selectableLines != nil) ? self.selectableLines?.contains(lineIndex) : true) != nil)
    }

    /// Returns a copy of this selection instance with the provided
    /// line selection update.
    ///
    /// @param lineIndex - The index (line number) of the line which should
    /// be selected or unselected.
    ///
    /// @param selected - Whether the given line number should be marked
    /// as selected or not.
    public func withLineSection(lineIndex: Int, selected: Bool) throws -> DiffSelection {
        return try self.withRangeSelection(from: lineIndex,
                                       length: 1,
                                       selected: selected)
    }

    /// Returns a copy of this selection instance with the provided
    /// line selection update. This is similar to the withLineSelection
    /// method except that it allows updating the selection state of
    /// a range of lines at once. Use this if you ever need to modify
    /// the selection state of more than one line at a time as it's
    /// more efficient.
    ///
    /// @param from -  The line index (inclusive) from where to start
    /// updating the line selection state.
    ///
    /// @param to -  The number of lines for which to update the
    /// selection state. A value of zero means no lines
    /// are updated and a value of 1 means only the
    /// line given by lineIndex will be updated.
    ///
    /// @param selected - Whether the lines should be marked as selected
    /// or not.
    public func withRangeSelection(from: Int,
                                   length: Int,
                                   selected: Bool) throws -> DiffSelection {
        let computedSelectionType = self.getSelectionType()
        // swiftlint:disable:next identifier_name
        let to = from + length

        if try typeMatchesSelection(selectionType: computedSelectionType,
                                selected: selected) {
            return self
        }

        if computedSelectionType == .partial {
            var newDivergingLines: Set<Int> = self.divergingLines!

            if try typeMatchesSelection(selectionType: self.defaultSelectionType,
                                    selected: selected) {
                // swiftlint:disable:next identifier_name
                for i in stride(from: from, to: to, by: 1) {
                    newDivergingLines.remove(i)
                }
            } else {
                // swiftlint:disable:next identifier_name
                for i in stride(from: from, to: to, by: 1) {
                    // swiftlint:disable:next for_where
                    if try self.isSelected(lineIndex: i) {
                        newDivergingLines.insert(i)
                    }
                }
            }

            return DiffSelection(defaultSelectionType: self.defaultSelectionType,
                                 divergingLines: newDivergingLines.isEmpty ? nil : newDivergingLines,
                                 selectableLines: self.selectableLines)
        } else {
            var newDivergingLines: Set<Int> = []

            // swiftlint:disable:next identifier_name
            for i in stride(from: from, to: to, by: 1) {
                // swiftlint:disable:next for_where
                if try self.isSelected(lineIndex: i) {
                    newDivergingLines.insert(i)
                }
            }

            return DiffSelection(defaultSelectionType: computedSelectionType,
                                 divergingLines: newDivergingLines,
                                 selectableLines: self.selectableLines)
        }
    }

    /// Returns a copy of this selection instance where the selection state
    /// of the specified line has been toggled (inverted).
    public func withToggleLineSelection(lineIindex: Int) throws -> DiffSelection {
        return try self.withLineSection(lineIndex: lineIindex,
                                    selected: !self.isSelected(lineIndex: lineIindex))
    }

    /// Returns a copy of this selection instance with all lines selected.
    public func withSelectAll() -> DiffSelection {
        return DiffSelection(defaultSelectionType: .all,
                             divergingLines: nil,
                             selectableLines: self.selectableLines)
    }

    /// Returns a copy of this selection instance with no lines selected.
    public func withSelectNone() -> DiffSelection {
        return DiffSelection(defaultSelectionType: .none,
                             divergingLines: nil,
                             selectableLines: self.selectableLines)
    }

    /// With selectable lines
    /// - Parameter selectableLines: Selectable lines
    /// - Returns: Diff Selection
    public func withSelectableLines(selectableLines: Set<Int>) -> DiffSelection {
        let divergingLines = (self.divergingLines != nil) ? self.divergingLines?.filter {
            selectableLines.contains($0)
        } : nil

        return DiffSelection(defaultSelectionType: self.defaultSelectionType,
                             divergingLines: divergingLines,
                             selectableLines: selectableLines)
    }
}

enum DiffSelectionError: Error {
    case unknownSelectionType(String)
    case unknownDiffSelection(String)
    case unknownBaseSelection(String)
}
