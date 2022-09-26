//
//  ParagraphStyle.swift
//  
//
//  Created by Matthew Davidson on 21/12/19.
//

import Foundation

#if os(iOS)
import UIKit
public typealias ParagraphStyle = NSParagraphStyle
public typealias MutableParagraphStyle = NSMutableParagraphStyle

#elseif os(macOS)
import Cocoa
public typealias ParagraphStyle = NSParagraphStyle
public typealias MutableParagraphStyle = NSMutableParagraphStyle

#endif
