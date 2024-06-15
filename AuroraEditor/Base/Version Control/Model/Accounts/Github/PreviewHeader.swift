//
//  PreviewHeader.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Some APIs provide additional data for new (preview) APIs if a custom header is added to the request.
///
/// - Note: Preview APIs are subject to change.
public enum PreviewHeader {
    /// The `Reactions` preview header provides reactions in `Comment`s.
    case reactions

    /// HTTP Header
    public var header: HTTPHeader {
        switch self {
        case .reactions:
            return HTTPHeader(headerField: "Accept", value: "application/vnd.github.squirrel-girl-preview")
        }
    }
}
