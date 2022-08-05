//
//  ShellClientMock.swift
//  AuroraEditorModules/ShellClient
//
//  Created by Marco Carnevali on 27/03/22.
//
import Combine

public extension ShellClient {
    /// Description
    /// - Parameter output: output description
    /// - Returns: description
    static func always(_ output: String) -> Self {
        Self(
            runLive: { _ in
                CurrentValueSubject<String, Never>(output)
                    .eraseToAnyPublisher()
            },
            run: { _ in
                output
            }
        )
    }
}
