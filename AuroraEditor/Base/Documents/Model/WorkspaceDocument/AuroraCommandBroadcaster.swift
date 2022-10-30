//
//  AuroraCommandBroadcaster.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 30/10/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import Combine

class AuroraCommandBroadcaster: ObservableObject {
    public var broadcaster: AnyPublisher<[String: String], Never>
    private var subject: CurrentValueSubject<[String: String], Never>

    init() {
        subject = .init([:])
        broadcaster = subject
            .handleEvents(receiveCancel: {})
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    /// Broadcasts a command to any subscribers of ``broadcaster``. Those subscribers
    /// can then act on the information provided.
    /// The `[String: String]` command must contain a `name` property or it will not be broadcast.
    ///
    /// To create a subscriber to ``broadcaster``, use the following code:
    /// ```
    /// workspace.broadcaster.sink { command in
    ///     if command["name"] == "myCommand" {
    ///         // do something with the command
    ///     }
    /// }
    /// ```
    ///
    /// For example, in a `View`:
    /// ```swift
    /// @EnvironmentObject var workspace: WorkspaceDocument
    ///
    /// var body: some View {
    ///     VStack { /*your view here*/ }
    ///     // this code does not need to go on a VStack,
    ///     // just put it somewhere in your body.
    ///     // this cannot occur in the init function
    ///     // as workspace would not exist yet
    ///     .onAppear {
    ///         workspace.broadcaster.sink { command in
    ///             if command["name"] == "myCommand" {
    ///                 // do something with the command
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter command: The command to send
    func broadcast(command: [String: String]) {
        guard command["name"] != nil else { return }
        subject.send(command)
    }
}
