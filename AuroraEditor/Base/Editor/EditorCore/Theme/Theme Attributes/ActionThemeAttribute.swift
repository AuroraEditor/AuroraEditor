//
//  ActionThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 04/12/19.
//

import Foundation

// DO NOT allow this to be a codable.
// It allows for arbritrary execution of code, which is insecure.
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

    public func encode(to encoder: Encoder) throws {
        fatalError("ActionThemeAttribute does not conform to Codable for security reasons.")
    }

    public required init(from decoder: Decoder) throws {
        fatalError("ActionThemeAttribute does not conform to Codable for security reasons.")
    }
}
