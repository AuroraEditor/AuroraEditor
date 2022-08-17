//
//  Cherry-Pick.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

public struct CherryPick {
    /// The app-specific results from attempting to cherry pick commits
    enum CherryPickResult: String {
        /// Git completed the cherry pick without reporting any errors, and the caller can
        /// signal success to the user.
        case completedWithoutError = "CompletedWithoutError"
        /// The cherry pick encountered conflicts while attempting to cherry pick and
        /// need to be resolved before the user can continue.
        case conflictsEncountered = "ConflictsEncountered"
        /// The cherry pick was not able to continue as tracked files were not staged in
        /// the index.
        case outstandingFilesNotStaged = "OutstandingFilesNotStaged"
        /// The cherry pick was not attempted:
        /// - it could not check the status of the repository.
        /// - there was an invalid revision range provided.
        /// - there were uncommitted changes present.
        /// - there were errors in checkout the target branch
        case unableToStart = "UnableToStart"
        /// An unexpected error as part of the cherry pick flow was caught and handled.
        /// Check the logs to find the relevant Git details.
        case error = "Error"
    }

    /// A function to initiate cherry picking in the app.
    ///
    /// @param commits - array of commits to cherry-pick
    /// For a cherry-pick operation, it does not matter what order the commits
    /// appear. But, it is best practice to send them in ascending order to prevent
    /// conflicts. First one on the array is first to be cherry-picked.
    func cherryPick() {}

    /// Inspect the `.git/sequencer` folder and convert the current cherry pick
    /// state into am `ICherryPickProgress` instance as well as return an array of
    /// remaining commits queued for cherry picking.
    /// - Progress instance required to display progress to user.
    /// - Commits required to track progress after a conflict has been resolved.
    ///
    /// This is required when Desktop is not responsible for initiating the cherry
    /// pick and when continuing a cherry pick after conflicts are resolved:
    ///
    /// It returns null if it cannot parse an ongoing cherry pick. This happens when,
    /// - There isn't a cherry pick in progress (expected null outcome).
    /// - Runs into errors parsing cherry pick files. This is expected if cherry
    ///   pick is aborted or finished during parsing. It could also occur if cherry
    ///   pick sequencer files are corrupted.
    func getCherryPickSnapshot() {

        // Abort safety sha is stored in.git/sequencer/abort-safety. It is the sha of
        // the last cherry-picked commit in the operation or the head of target branch
        // if no commits have been cherry-picked yet.
        var abortSafetySha: String

        // The head sha is stored in .git/sequencer/head. It is the sha of target
        // branch before the cherry-pick operation occurred.
        var headSha: String
    }

    /// Proceed with the current cherry pick operation and report back on whether it completed
    ///
    /// It is expected that the index has staged files which are cleanly cherry
    /// picked onto the base branch, and the remaining unstaged files are those which
    /// need manual resolution or were changed by the user to address inline
    /// conflicts.
    ///
    /// @param files - The working directory of files. These are the files that are
    /// detected to have changes that we want to stage for the cherry pick.
    func continueCherryPick() {}

    /// Abandon the current cherry pick operation
    func abortCherryPick(directoryURL: URL) throws {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git cherry-pick --abort"
        )
    }

    /// Check if the `.git/CHERRY_PICK_HEAD` file exists
    func isCherryPickHeadFound(directoryURL: URL) -> Bool {
        do {
            let cherryPickHeadPath = try String(contentsOf: directoryURL) + ".git/CHERRY_PICK_HEAD"
            return FileManager.default.fileExists(atPath: cherryPickHeadPath)
        } catch {
            // swiftlint:disable:next line_length
            Log.warning("[cherryPick] a problem was encountered reading .git/CHERRY_PICK_HEAD, so it is unsafe to continue cherry-picking")
            return false
        }
    }
}
