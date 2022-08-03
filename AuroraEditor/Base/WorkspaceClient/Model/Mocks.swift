//
//  Mocks.swift
//  AuroraEditorModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//

import Combine
import Foundation

// TODO: DOCS (Marco Carnevali)
public extension WorkspaceClient {
    /// <#Description#>
    static var empty = Self(
        folderURL: { nil },
        getFiles: CurrentValueSubject<[FileItem], Never>([]).eraseToAnyPublisher(),
        getFileItem: { _ in throw WorkspaceClientError.fileNotExist }
    )
}
