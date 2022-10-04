//
//  ActionThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public class ActionThemeAttribute: TokenThemeAttribute {

    public typealias Handler = (String, NSRange) -> Void

    public static let HandlerKey = NSAttributedString.Key("linkHandler")

    public let key = "action"
    public let actionId: String
    public let handler: Handler?

    public init(actionId: String, handler: Handler? = nil) {
        self.actionId = actionId
        self.handler = handler
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.link, value: actionId, range: range)
        if let handler = handler {
            attrStr.addAttribute(Self.HandlerKey, value: handler, range: range)
        }
    }
}
