//
//  BitbucketAccount.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// BitBucket base URL
public let bitbucketBaseURL = "https://api.bitbucket.org/2.0"

/// BitBucket web URL
public let bitbucketWebURL = "https://bitbucket.org/"

/// BitBucket Account
public struct BitbucketAccount {
    /// Bitbucket token configuration
    public let configuration: BitbucketTokenConfiguration

    /// Initialize Bitbucket Account
    /// 
    /// - Parameter config: Bitbucket token configuration
    public init(_ config: BitbucketTokenConfiguration = BitbucketTokenConfiguration()) {
        configuration = config
    }
}

extension Router {
    /// URLRequest
    internal var URLRequest: Foundation.URLRequest? {
        request()
    }
}
