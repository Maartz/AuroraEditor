//
//  Diff-Check.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/29.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Returns a list of files with conflict markers present
/// 
/// - Parameter directoryURL: Directory URL
/// 
/// - Returns: A dictionary of file names and the number of conflict markers
/// 
/// - Throws: ShellClientError
func getFilesWithConflictMarkers(directoryURL: URL) throws -> [String: Int] {
    let args = ["diff", "--check"]
    let output = try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
    )

    let outputString = output.utf8CString
    // TODO: Find a way to parse the data effeciently

    return [:]
}

/// Matches a line reporting a leftover conflict marker
/// and captures the name of the file
let fileNameCapetureRe = "/(.+):\\d+: leftover conflict marker/gi"
