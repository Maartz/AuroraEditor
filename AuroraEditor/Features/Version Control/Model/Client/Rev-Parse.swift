//
//  Rev-Parse.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// The type of repository that was found.
enum RepositoryType {

    /// A bare repository.
    case bare

    /// A regular repository.
    case regular

    /// The repository was not found.
    case missing

    /// The repository was found but is unsafe.
    case unsafe
}

/// Attempts to fulfill the work of isGitRepository and isBareRepository while
/// requiring only one Git process to be spawned.
///
/// Returns 'bare', 'regular', or 'missing' if the repository couldn't be
/// found.
/// 
/// - Parameter path: The path to the repository.
/// 
/// - Returns: The type of repository.
func getRepositoryType(path: String) throws -> RepositoryType {
    if FileManager().directoryExistsAtPath(path) {
        return .missing
    }

    do {
        let result = try ShellClient.live().run(
            "cd \(path);git rev-parse --is-bare-repository -show-cdup"
        )

        if !result.contains(GitError.notAGitRepository.rawValue) {
            let isBare = result.split(separator: "\n", maxSplits: 2)

            return isBare.description == "true" ? .bare : .regular
        }

        if result.contains("fatal: detected dubious ownership in repository at") {
            return .unsafe
        }

        return .missing
    } catch {
        // This could theoretically mean that the Git executable didn't exist but
        // in reality it's almost always going to be that the process couldn't be
        // launched inside of `path` meaning it didn't exist. This would constitute
        // a race condition given that we stat the path before executing Git.
        self.loggererror("Git doesn't exist, returning as missing")
        return .missing
    }
}
