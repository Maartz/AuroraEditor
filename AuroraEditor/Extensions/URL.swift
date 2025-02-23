//
//  URL.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

extension URL {
    /// URL parameters
    var URLParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return [:] }
        var params = [String: String]()
        components.queryItems?.forEach { queryItem in
            params[queryItem.name] = queryItem.value
        }
        return params
    }

    /// Bitbucket URL parameters
    ///
    /// - Returns: URL parameters
    func bitbucketURLParameters() -> [String: String] {
        let stringParams = absoluteString.components(separatedBy: "?").last
        let params = stringParams?.components(separatedBy: "&")
        var returnParams: [String: String] = [:]
        if let params = params {
            for param in params {
                let keyValue = param.components(separatedBy: "=")
                if let key = keyValue.first, let value = keyValue.last {
                    returnParams[key] = value
                }
            }
        }
        return returnParams
    }

    /// Initialize with an static string
    /// - Parameter string: Static string
    init(_ string: StaticString) {
        self.init(string: "\(string)")!
        // swiftlint:disable:previous force_unwrapping
    }

    /// Initialize with an static string
    /// - Parameter string:  string
    init(_ string: String) {
        self.init(string: "\(string)")!
        // swiftlint:disable:previous force_unwrapping
    }
}
