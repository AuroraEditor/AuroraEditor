//
//  TokenizeResult.swift
//  
//
//  Created by Matthew Davidson on 4/1/20.
//

import Foundation

public struct TokenizeResult {

    public let state: LineState
    public let tokenizedLine: TokenizedLine
    public let matchTokens: [Token]
}
