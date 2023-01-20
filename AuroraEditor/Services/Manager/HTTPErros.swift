//
//  HTTPErros.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

/// A enum class that has strings that can be used to check what
/// type of error we got back from the lookout api.
enum HTTPErrors: String, Error {
    case notVerified = "User is not verified"
}
