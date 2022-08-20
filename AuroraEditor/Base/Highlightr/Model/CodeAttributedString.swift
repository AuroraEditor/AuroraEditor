//
//  CodeAttributedString.swift
//  Pods
//
//  Created by Illanes, J.P. on 4/19/16.
//
//

import Foundation
import AppKit

/// Highlighting Delegate
@objc public protocol HighlightDelegate {
    /**
     If this method returns *false*, the highlighting process will be skipped for this range.
     
     - parameter range: NSRange
     
     - returns: Bool
     */
    @objc optional func shouldHighlight(_ range: NSRange) -> Bool

    /**
     Called after a range of the string was highlighted, if there was an error **success** will be *false*.
     
     - parameter range:   NSRange
     - parameter success: Bool
     */
    @objc optional func didHighlight(_ range: NSRange, success: Bool)
}

/// NSTextStorage subclass. Can be used to dynamically highlight code.
open class CodeAttributedString: NSTextStorage {
    /// Internal Storage
    let stringStorage = NSTextStorage()

    /// Highlightr instace used internally for highlighting. Use this for configuring the theme.
    public let highlightr: Highlightr

    /// This object will be notified before and after the highlighting.
    open var highlightDelegate: HighlightDelegate?

    /**
     Initialize the CodeAttributedString
     - parameter highlightr: The highlightr instance to use. Defaults to `Highlightr()`.
     */
    public init(highlightr: Highlightr = Highlightr()!) {
        self.highlightr = highlightr
        super.init()
        setupListeners()
    }

    /// Initialize the CodeAttributedString
    override public init() {
        self.highlightr = Highlightr()!
        super.init()
        setupListeners()
    }

    /// Initialize the CodeAttributedString
    public required init?(coder aDecoder: NSCoder) {
        self.highlightr = Highlightr()!
        super.init(coder: aDecoder)
        setupListeners()
    }

    /// Initialize the CodeAttributedString
    public required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        self.highlightr = Highlightr()!
        super.init(pasteboardPropertyList: propertyList, ofType: type)
        setupListeners()
    }

    /// Language syntax to use for highlighting. Providing nil will disable highlighting.
    open var language: String? {
        didSet {
            highlight(NSRange(location: 0, length: stringStorage.length))
        }
    }

    /// Returns a standard String based on the current one.
    override open var string: String {
        return stringStorage.string
    }

    /**
     Returns the attributes for the character at a given index.
     
     - parameter location: Int
     - parameter range:    NSRangePointer
     
     - returns: Attributes
     */
    override open func attributes(
        at location: Int,
        effectiveRange range: NSRangePointer?) -> [AttributedStringKey: Any] {
            return stringStorage.attributes(at: location, effectiveRange: range)
        }

    /**
     Replaces the characters at the given range with the provided string.
     
     - parameter range: NSRange
     - parameter str:   String
     */
    override open func replaceCharacters(in range: NSRange, with str: String) {
        stringStorage.replaceCharacters(in: range, with: str)
        self.edited(TextStorageEditActions.editedCharacters,
                    range: range,
                    changeInLength: (str as NSString).length - range.length)
    }

    /**
     Sets the attributes for the characters in the specified range to the given attributes.
     
     - parameter attrs: [String : AnyObject]
     - parameter range: NSRange
     */
    override open func setAttributes(_ attrs: [AttributedStringKey: Any]?, range: NSRange) {
        stringStorage.setAttributes(attrs, range: range)
        self.edited(TextStorageEditActions.editedAttributes, range: range, changeInLength: 0)
    }

    /// Called internally everytime the string is modified.
    override open func processEditing() {
        super.processEditing()
        if language != nil {
            if self.editedMask.contains(.editedCharacters) {
                let string = (self.string as NSString)
                let range = string.paragraphRange(for: editedRange)
                highlight(range)
            }
        }
    }

    func highlight(_ range: NSRange) {
        if language == nil {
            return
        }

        if let highlightDelegate = highlightDelegate {
            let shouldHighlight: Bool? = highlightDelegate.shouldHighlight?(range)
            if shouldHighlight != nil && !shouldHighlight! {
                return
            }
        }

        let string = (self.string as NSString)
        let line = string.substring(with: range)
        DispatchQueue.global().async {
            let tmpStrg = self.highlightr.highlight(line, as: self.language!)
            DispatchQueue.main.async(execute: {
                // Checks to see if this highlighting is still valid.
                if (range.location + range.length) > self.stringStorage.length {
                    self.highlightDelegate?.didHighlight?(range, success: false)
                    return
                }

                if tmpStrg?.string != self.stringStorage.attributedSubstring(from: range).string {
                    self.highlightDelegate?.didHighlight?(range, success: false)
                    return
                }

                self.beginEditing()
                tmpStrg?.enumerateAttributes(
                    in: NSRange(
                        location: 0,
                        length: (tmpStrg?.length)!
                    ),
                    options: [],
                    using: { (attrs, locRange, _) in
                        var fixedRange = NSRange(location: range.location+locRange.location, length: locRange.length)
                        fixedRange.length = (
                            fixedRange.location + fixedRange.length < string.length
                        ) ? fixedRange.length : string.length-fixedRange.location
                        fixedRange.length = (fixedRange.length >= 0) ? fixedRange.length : 0
                        self.stringStorage.setAttributes(attrs, range: fixedRange)
                    })
                self.endEditing()
                self.edited(TextStorageEditActions.editedAttributes, range: range, changeInLength: 0)
                self.highlightDelegate?.didHighlight?(range, success: true)
            })
        }
    }

    func setupListeners() {
        highlightr.themeChanged = { [weak self] _ in
            guard let self = self else { return }
            self.highlight(NSRange(location: 0, length: self.stringStorage.length))
        }
    }
}
