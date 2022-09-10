//
//  Target.swift
//  
//
//  Created by Pavel Kasila on 27.03.22.
//

import Foundation

/// This structure stores information about the target to be available in CodeEdit for running
public struct Target: Identifiable {

    /// Initializes a target with parameters
    ///  - Parameter id: The unique identifier of the target set by the extension
    ///  - Parameter displayName: The name of the target to be displayed in the UI
    ///  - Parameter executable: The executable to launch inside the pseudo terminal
    ///  - Parameter args: an array of strings that is passed as the arguments to the underlying process
    ///  - Parameter environment: an array of environment variables to pass to the child process.
    ///  - Parameter execName: If provided, this is used as the Unix argv[0] parameter, otherwise, 
    /// the executable is used as the args [0], this is used when the intent is to set a different
    /// process name than the file that backs it.
    public init(id: String, displayName: String,
                executable: String, args: [String] = [],
                environment: [String]? = nil, execName: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.executable = executable
        self.args = args
        self.environment = environment
        self.execName = execName
    }

    /// ``id`` is a unique identifier of the target set by the extension
    public var id: String

    /// ``displayName`` is a name to be displayed in the UI to represent target
    public var displayName: String

    /// ``executable`` is the executable to launch inside the pseudo terminal
    public var executable: String

    /// ``args`` is an array of strings that is passed as the arguments to the underlying process
    public var args: [String] = []

    /// ``environment`` is an array of environment variables to pass to the child process.
    public var environment: [String]?

    /// ``execName`` If provided, this is used as the Unix argv[0] parameter,
    /// otherwise, the executable is used as the args [0],
    /// this is used when the intent is to set a different process name than the file that backs it.
    public var execName: String?
}
