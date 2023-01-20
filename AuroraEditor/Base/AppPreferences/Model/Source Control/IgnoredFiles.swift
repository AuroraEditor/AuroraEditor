//
//  IgnoredFiles.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public struct IgnoredFiles: Codable, Identifiable, Hashable {
    public var id: String
    public var name: String
}
