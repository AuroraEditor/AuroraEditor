//
//  Shims.swift
//  Pods
//
//  Created by Kabir Oberai on 19/06/18.
//
//

import Foundation

#if os(OSX)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

#if swift(>=4.2)
    /// AttributedStringKey
    public typealias AttributedStringKey = NSAttributedString.Key
#else
/// AttributedStringKey
    public typealias AttributedStringKey = NSAttributedStringKey
#endif

#if swift(>=4.2) && os(iOS)
/// AttributedStringKey
    public typealias TextStorageEditActions = NSTextStorage.EditActions
#else
/// AttributedStringKey
    public typealias TextStorageEditActions = NSTextStorageEditActions
#endif
