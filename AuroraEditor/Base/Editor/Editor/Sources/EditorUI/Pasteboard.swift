//
//  Pasteboard.swift
//  
//
//  Created by Matthew Davidson on 21/1/20.
//

import Foundation

#if os(iOS)
import UIKit
public typealias Pasteboard = UIPasteboard
public typealias PasteboardType = UIPasteboard.Type
#elseif os(macOS)
import Cocoa
public typealias Pasteboard = NSPasteboard
public typealias PasteboardType = NSPasteboard.PasteboardType
#endif
