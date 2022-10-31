//
//  WorkspaceErrors.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/10/29.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

enum WorkspaceErrors: String, Error {
    case extensionNavigatorData = "Couldn't unwrap extension navigator due to nil value"
}
