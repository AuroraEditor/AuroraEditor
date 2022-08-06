//
//  WorkspaceClientInterface.swift
//  AuroraEditorModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//

import Combine
import Foundation

// TODO: DOCS (Marco Carnevali)
public struct WorkspaceClient {

    public var folderURL: () -> URL?

    public var getFiles: AnyPublisher<[FileItem], Never>

    public var getFileItem: (_ id: String) throws -> FileItem

    public var model: SourceControlModel?

    /// callback function that is run when a change is detected in the file system.
    /// This usually contains a `reloadData` function.
    public static var onRefresh: ([FileItem]) -> Void = { _ in }
    public static var filter: String = "" {
        didSet { WorkspaceClient.onRefresh([]) }
    }

    // For some strange reason, swiftlint thinks this is wrong?
    public init(
        folderURL: @escaping () -> URL?,
        getFiles: AnyPublisher<[FileItem], Never>,
        getFileItem: @escaping (_ id: String) throws -> FileItem,
        model: SourceControlModel? = nil
    ) {
        self.folderURL = folderURL
        self.getFiles = getFiles
        self.getFileItem = getFileItem
        self.model = model
    }
    // swiftlint:enable vertical_parameter_alignment

    enum WorkspaceClientError: Error {
        case fileNotExist
    }
}
