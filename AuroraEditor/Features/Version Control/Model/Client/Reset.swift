//
//  Reset.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// The reset modes which are supported.
public enum GitResetMode: Int {
    /// Resets the index and working tree. Any changes to tracked files in the
    /// working tree since <commit> are discarded.
    case hard = 0

    /// Does not touch the index file or the working tree at all (but resets the
    /// head to <commit>, just like all modes do). This leaves all your changed
    /// files "Changes to be committed", as git status would put it.
    case soft

    /// Resets the index but not the working tree (i.e., the changed files are
    /// preserved but not marked for commit) and reports what has not been updated.
    /// This is the default action for git reset.
    case mixed
}

/// GIT Reset
public struct Reset {
    /// Convert the mode to the arguments.
    /// 
    /// - Parameter mode: The mode to convert.
    /// - Parameter ref: The ref to reset to.
    /// 
    /// - Returns: The arguments for the mode.
    func resetModeToArgs(mode: GitResetMode, ref: String) -> [String] {
        switch mode {
        case .hard:
            return ["reset", "--hard", ref]
        case .mixed:
            return ["reset", ref]
        case .soft:
            return ["reset", "--soft", ref]
        }
    }

    /// Reset with the mode to the ref.
    /// 
    /// - Parameter directoryURL: The directory to reset the index in.
    /// - Parameter mode: The mode to use when resetting.
    /// - Parameter ref: The ref to reset to.
    /// 
    /// - Returns: Whether the reset was successful.
    /// 
    /// - Throws: Error
    func reset(directoryURL: URL,
               mode: GitResetMode,
               ref: String) throws -> Bool {
        let args = resetModeToArgs(mode: mode,
                                   ref: ref)
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
        )
        return true
    }

    /// Updates the index with information from a particular tree for a given
    /// set of paths.
    ///
    /// - Parameter directoryURL: The repository in which to reset the index.
    /// - Parameter mode: Which mode to use when resetting, see the GitResetMode
    ///                   enum for more information.
    /// - Parameter ref: A string which resolves to a tree, for example 'HEAD' or a
    ///                  commit sha.
    /// - Parameter paths: The paths that should be updated in the index with information
    ///                    from the given tree
    /// 
    /// - Returns: Whether the reset was successful.
    /// 
    /// - Throws: Error
    func resetPaths(directoryURL: URL,
                    mode: GitResetMode,
                    ref: String,
                    paths: [String]) throws {

        let baseArgs = resetModeToArgs(mode: mode,
                                       ref: ref)

        let args = [baseArgs, "--", paths] as [Any]

        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
        )
    }

    /// Unstage all paths.
    /// 
    /// - Parameter directoryURL: The repository in which to unstage all paths.
    /// 
    /// - Returns: Whether the unstage was successful.
    /// 
    /// - Throws: Error
    @discardableResult
    func unstageAll(directoryURL: URL) throws -> Bool {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git reset -- ."
        )
        return true
    }
}
