//
//  CodeStorage.swift
//
//  Created by Manuel M T Chakravarty on 09/01/2021.
//
//  This file contains `NSTextStorage` extensions for code editing.

import AppKit

// MARK: -
// MARK: `NSTextStorage` subclass

// `NSTextStorage` is a class cluster; hence, we realise our subclass by decorating an embeded vanilla text storage.
class CodeStorage: NSTextStorage {

    let textStorage: NSTextStorage = NSTextStorage()

    var theme: Theme

    override var string: String { textStorage.string }

    init(theme: Theme) {
        self.theme = theme
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key: Any] {
        return textStorage.attributes(at: location, effectiveRange: range)
    }

    // Extended to handle auto-deletion of adjcent matching brackets
    override func replaceCharacters(in range: NSRange, with str: String) {

        beginEditing()

        // We are deleting one character => check whether it is a one-character
        // bracket and if so also delete its matching bracket if it is directly adjascent
        if range.length == 1 && str.isEmpty {

            textStorage.replaceCharacters(in: range, with: str)
            edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)

        } else {

            textStorage.replaceCharacters(in: range, with: str)
            edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)

        }
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        beginEditing()
        textStorage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
}
