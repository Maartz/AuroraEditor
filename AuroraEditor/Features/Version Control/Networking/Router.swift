//
//  Router.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

// This file should be strictly just be used for Accounts since it's not
// built for any other networking except those of git accounts

import Foundation
import OSLog

@available(*,
            deprecated,
            renamed: "VersionControl",
            message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// HTTP Encoding
public enum HTTPEncoding: Int {
    case url, form, json
}

/// HTTP Header
public struct HTTPHeader {
    /// Field
    public var headerField: String

    /// Value
    public var value: String

    /// Init
    /// - Parameters:
    ///   - headerField: Field
    ///   - value: Value
    public init(headerField: String, value: String) {
        self.headerField = headerField
        self.value = value
    }
}

/// GIT Configuration
public protocol GitConfiguration {
    /// API Endpoint
    var apiEndpoint: String? { get }

    /// Access Token
    var accessToken: String? { get }

    /// Access Token Header Field Name
    var accessTokenFieldName: String? { get }

    /// Authorization header
    var authorizationHeader: String? { get }

    /// Error Domain
    var errorDomain: String? { get }

    /// Custom Headers
    var customHeaders: [HTTPHeader]? { get }
}

public extension GitConfiguration {
    /// Access token field name
    var accessTokenFieldName: String? {
        "access_token"
    }

    /// authorizationHeader
    var authorizationHeader: String? {
        nil
    }

    /// Error domain
    var errorDomain: String? {
        "com.auroraeditor.models.accounts.networking"
    }

    /// Custom Headers
    var customHeaders: [HTTPHeader]? {
        nil
    }
}

/// Error key
public let errorKey = "ErrorKey"

/// Router
public protocol Router {
    /// HTTP Method
    var method: HTTPMethod { get }

    /// URL Path
    var path: String { get }

    /// HTTP Encoding
    var encoding: HTTPEncoding { get }

    /// Params
    var params: [String: Any] { get }

    /// Configuration
    var configuration: GitConfiguration? { get }

    /// URL Query
    /// 
    /// - Parameter parameters: parameters
    /// 
    /// - Returns: URLQueryItem
    func urlQuery(_ parameters: [String: Any]) -> [URLQueryItem]?

    /// URL Request
    /// 
    /// - Parameters:
    ///   - urlComponents: URLComponents
    ///   - parameters: Parameters
    /// 
    /// - Returns: URLRequest
    func request(_ urlComponents: URLComponents, parameters: [String: Any]) -> URLRequest?

    /// Load JSON
    /// 
    /// - Parameters:
    ///   - session: URL Session
    ///   - expectedResultType: T
    ///   - completion: (T, Error)
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    func loadJSON<T: Codable>(
        _ session: GitURLSession,
        expectedResultType: T.Type,
        completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol?

    /// Load
    /// 
    /// - Parameters:
    ///   - session: URL Session
    ///   - dateDecodingStrategy: date decoding strategy
    ///   - expectedResultType: T
    ///   - completion: (T, Error)
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    func load<T: Codable>(
        _ session: GitURLSession,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?,
        expectedResultType: T.Type,
        completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol?

    /// Load JSON
    /// 
    /// - Parameters:
    ///   - session: URL Session
    ///   - decoder: decoder
    ///   - expectedResultType: T
    ///   - completion: (T, Error)
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    func load<T: Codable>(
        _ session: GitURLSession,
        decoder: JSONDecoder,
        expectedResultType: T.Type,
        completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol?

    /// Request
    /// 
    /// - Returns: URLRequest
    func request() -> URLRequest?
}

public extension Router {
    /// Request
    /// 
    /// - Returns: URLRequest
    func request() -> URLRequest? {
        let url = URL(string: path, relativeTo: URL(string: configuration?.apiEndpoint ?? "")!)

        var parameters = encoding == .json ? [:] : params

        if let accessToken = configuration?.accessToken, configuration?.authorizationHeader == nil {
            parameters[configuration?.accessTokenFieldName ?? ""] = accessToken as Any?
        }

        let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)

        var urlRequest = request(components!, parameters: parameters)

        if let accessToken = configuration?.accessToken, let tokenType = configuration?.authorizationHeader {
            urlRequest?.addValue("\(tokenType) \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        if let customHeaders = configuration?.customHeaders {
            customHeaders.forEach { httpHeader in
                urlRequest?.addValue(httpHeader.value, forHTTPHeaderField: httpHeader.headerField)
            }
        }

        return urlRequest
    }

    /// Due to the complexity of the the urlQuery method we disabled lint for the this method
    /// only so that it doesn't complain... Note this level of complexity is needed to give us as
    /// much success rate as possible due to all git providers having different types of url schemes.
    /// 
    /// - Parameter parameters: parameters
    /// 
    /// - Returns: URLQueryItem
    func urlQuery(_ parameters: [String: Any]) -> [URLQueryItem]? {
        guard !parameters.isEmpty else { return nil }

        var components: [URLQueryItem] = []

        for key in parameters.keys.sorted(by: <) {
            guard let value = parameters[key] else { continue }

            switch value {
            case let value as String:
                if let escapedValue = value.addingPercentEncoding(
                    withAllowedCharacters: CharacterSet.URLQueryAllowedCharacterSet()) {
                    components.append(URLQueryItem(name: key, value: escapedValue))
                }
            case let valueArray as [String]:
                for (index, item) in valueArray.enumerated() {
                    if let escapedValue = item.addingPercentEncoding(
                        withAllowedCharacters: CharacterSet.URLQueryAllowedCharacterSet()) {
                        components.append(URLQueryItem(name: "\(key)[\(index)]", value: escapedValue))
                    }
                }
            case let valueDict as [String: Any]:
                for nestedKey in valueDict.keys.sorted(by: <) {
                    guard let value = valueDict[nestedKey] as? String else { continue }
                    if let escapedValue = value.addingPercentEncoding(
                        withAllowedCharacters: CharacterSet.URLQueryAllowedCharacterSet()) {
                        components.append(URLQueryItem(name: "\(key)[\(nestedKey)]", value: escapedValue))
                    }
                }
            default:
                // Logger
                let logger = Logger(subsystem: "com.auroraeditor", category: "Router")
                logger.fault("Cannot encode object of type \(type(of: value))")
            }
        }

        return components
    }

    /// Request
    /// 
    /// - Parameters:
    ///   - urlComponents: URL Components
    ///   - parameters: Parameters
    /// 
    /// - Returns: URLRequest
    func request(_ urlComponents: URLComponents, parameters: [String: Any]) -> URLRequest? {

        var urlComponents = urlComponents

        urlComponents.percentEncodedQuery = urlQuery(parameters)?.map {
            [$0.name, $0.value ?? ""].joined(separator: "=")
        }.joined(separator: "&")

        guard let url = urlComponents.url else { return nil }

        switch encoding {
        case .url, .json:
            var mutableURLRequest = Foundation.URLRequest(url: url)

            mutableURLRequest.httpMethod = method.rawValue

            return mutableURLRequest
        case .form:
            let queryData = urlComponents.percentEncodedQuery?.data(using: String.Encoding.utf8)

            // clear the query items as they go into the body
            urlComponents.queryItems = nil

            var mutableURLRequest = Foundation.URLRequest(url: urlComponents.url!)

            mutableURLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")

            mutableURLRequest.httpBody = queryData

            mutableURLRequest.httpMethod = method.rawValue

            return mutableURLRequest as URLRequest
        }
    }

    /// [DEPRECATED] loadJSON
    /// 
    /// - Parameters:
    ///   - session: DEPRECATED
    ///   - expectedResultType: DEPRECATED
    ///   - completion: DEPRECATED
    /// 
    /// - Returns: DEPRECATED
    @available(*, deprecated, message: "Plase use `load` method instead")
    func loadJSON<T: Codable>(
        _ session: GitURLSession = URLSession.shared,
        expectedResultType: T.Type,
        completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol? {
        load(session, expectedResultType: expectedResultType, completion: completion)
    }

    /// Load
    /// 
    /// - Parameters:
    ///   - session: URL Session
    ///   - dateDecodingStrategy: date decoding strategy
    ///   - expectedResultType: T
    ///   - completion: (T, Error) -> Void
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    func load<T: Codable>(
        _ session: GitURLSession = URLSession.shared,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?,
        expectedResultType: T.Type,
        completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol? {

        let decoder = JSONDecoder()

        if let dateDecodingStrategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
        }

        return load(session, decoder: decoder, expectedResultType: expectedResultType, completion: completion)
    }

    /// Load
    /// 
    /// - Parameters:
    ///   - session: URLSession
    ///   - decoder: Decoder
    ///   - _: T
    ///   - completion: (T, Error) -> Void
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    func load<T: Codable>(
        _ session: GitURLSession = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        expectedResultType _: T.Type,
        completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol? {

        guard let request = request() else {
            return nil
        }

        let task = session.dataTaskGit(with: request) { data, response, err in
            if let response = response as? HTTPURLResponse {
                if response.wasSuccessful == false {
                    var userInfo = [String: Any]()
                    if let data = data, let json = try? JSONSerialization.jsonObject(
                        with: data,
                        options: .mutableContainers) as? [String: Any] {

                        userInfo[errorKey] = json as Any?
                    }

                    let error = NSError(
                        domain: self.configuration?.errorDomain ?? "",
                        code: response.statusCode,
                        userInfo: userInfo)

                    completion(nil, error)

                    return
                }
            }

            if let err = err {
                completion(nil, err)
            } else {
                if let data = data {
                    do {
                        let decoded = try decoder.decode(T.self, from: data)
                        completion(decoded, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }

    /// Load
    /// 
    /// - Parameters:
    ///   - session: URLSession
    ///   - decoder: Decoder
    ///   - _: T
    /// 
    /// - Returns: T
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func load<T: Codable>(
        _ session: GitURLSession = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        expectedResultType _: T.Type) async throws -> T {

        guard let request = request() else {
            throw NSError(domain: configuration?.errorDomain ?? "", code: -876, userInfo: nil)
        }

        let responseTuple = try await session.data(for: request, delegate: nil)

        if let response = responseTuple.1 as? HTTPURLResponse {
            if response.wasSuccessful == false {
                var userInfo = [String: Any]()
                if let json = try? JSONSerialization.jsonObject(
                    with: responseTuple.0,
                    options: .mutableContainers) as? [String: Any] {

                    userInfo[errorKey] = json as Any?

                }

                throw NSError(domain: configuration?.errorDomain ?? "", code: response.statusCode, userInfo: userInfo)
            }
        }

        return try decoder.decode(T.self, from: responseTuple.0)
    }

    /// Load
    /// 
    /// - Parameters:
    ///   - session: URLSession
    ///   - dateDecodingStrategy: date decoding strategy
    ///   - expectedResultType: T
    /// 
    /// - Returns: T
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func load<T: Codable>(
        _ session: GitURLSession = URLSession.shared,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?,
        expectedResultType: T.Type) async throws -> T {

        let decoder = JSONDecoder()

        if let dateDecodingStrategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
        }

        return try await load(session, decoder: decoder, expectedResultType: expectedResultType)
    }

    /// Load
    /// 
    /// - Parameters:
    ///   - session: URLSession
    ///   - completion: (error) -> Void
    ///
    /// - Returns: URLSessionDataTaskProtocol
    func load(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTaskProtocol? {

        guard let request = request() else {
            return nil
        }

        let task = session.dataTaskGit(with: request) { data, response, err in
            if let response = response as? HTTPURLResponse {
                if response.wasSuccessful == false {
                    var userInfo = [String: Any]()
                    if let data = data, let json = try? JSONSerialization.jsonObject(
                        with: data,
                        options: .mutableContainers) as? [String: Any] {

                        userInfo[errorKey] = json as Any?

                    }

                    let error = NSError(
                        domain: self.configuration?.errorDomain ?? "",
                        code: response.statusCode,
                        userInfo: userInfo)

                    completion(error)

                    return
                }
            }

            completion(err)
        }
        task.resume()
        return task
    }
}

private extension CharacterSet {

    /// https://github.com/Alamofire/Alamofire/blob/3.5rameterEncoding.swift#L220-L225
    /// Returns the character set for characters allowed in the query component of a URL.
    /// 
    /// - Returns: The character set.
    static func URLQueryAllowedCharacterSet() -> CharacterSet {

        // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        return allowedCharacterSet
    }
}

/// Checks what kind of HTTP response we get from the server
public extension HTTPURLResponse {
    /// Was the HTTP URL Response successfull?
    var wasSuccessful: Bool {
        let successRange = 200 ..< 300
        return successRange.contains(statusCode)
    }
}
// swiftlint:disable:this file_length
