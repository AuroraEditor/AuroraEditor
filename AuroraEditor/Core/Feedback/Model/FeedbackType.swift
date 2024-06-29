//
//  FeedbackType.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/14.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// Feedback type model
struct FeedbackType: Identifiable, Hashable {
    /// Feedback type name
    let name: String

    /// Feedback type id
    let id: String
}
