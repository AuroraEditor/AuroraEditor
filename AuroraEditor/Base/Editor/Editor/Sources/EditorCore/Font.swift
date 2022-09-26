//
//  Font.swift
//
//
//  Created by Matthew Davidson on 29/11/19.
//  
//

import Foundation

#if os(iOS)
import UIKit
public typealias Font = UIFont

#elseif os(macOS)
import Cocoa
public typealias Font = NSFont

#endif
