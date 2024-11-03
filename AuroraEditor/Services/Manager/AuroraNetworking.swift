//
//  AuroraNetworking.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import OSLog

enum AuthType: Codable {
    case github
    case gitlab
    case bitbucket
    case auroraeditor
    case none
}

class AuroraNetworking { // swiftlint:disable:this type_body_length
    static let shared = AuroraNetworking()

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Aurora Networking")

    let keychain = AuroraEditorKeychain()

    private var prefs: AppPreferencesModel = .shared

    /// All the cookies
    static var cookies: [HTTPCookie]? = []

    /// the full networkRequestResponse
    static var fullResponse: String? = ""

    /// The dispatch group
    static let group: DispatchGroup = .init()

    struct NetworkingError: Error {
        let message: String

        init(message: String) {
            self.message = message
        }

        public var localizedDescription: String {
            return message
        }
    }

    private func createRequest(url: URL, useAuthType: AuthType) -> URLRequest {
        // Create a URL Request
        var request = URLRequest(url: url)

        var gitAccounts: [AccountPreferences] = []

        do {
            gitAccounts = try AccountPreferences.fetchAll()
        } catch {
            self.logger.fault("Failed to fetch accounts")
        }

        if useAuthType == .github {
            request.addValue(
                "application/vnd.github+json",
                forHTTPHeaderField: "Accept"
            )

            if let username = gitAccounts.first?.accountUsername,
               let token = keychain.get("github_\(username)") {
                request.setValue(
                    "Bearer \(token)",
                    forHTTPHeaderField: "Authorization"
                )
            }
        } else if useAuthType == .auroraeditor {
            request.addValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )

            if let username = gitAccounts.first?.accountUsername.contains("auroraeditor_"),
               let token = keychain.get("auroraeditor_\(username)") {
                request.setValue(
                    "Bearer \(token)",
                    forHTTPHeaderField: "Authorization"
                )
            }
        } else if useAuthType == .none {
            request.addValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
        }

        return request
    }

    private func exec(
        with request: URLRequest,
        completionHandler: @escaping (Result<Data, Error>) -> Void,
        file: String = #file,
        line: Int = #line,
        function: String = #function) {
            // Create a  URLSession
            var session: URLSession? = URLSession.shared

            if let cookieData = AuroraNetworking.cookies {
                session?.configuration.httpCookieStorage?.setCookies(
                    cookieData,
                    for: request.url,
                    mainDocumentURL: nil
                )
            }

            // Start our datatask
            session?.dataTask(with: request) { [self] (sitedata, response, taskError) in
                // Check if we got any useable site data
                guard let sitedata = sitedata else {
                    completionHandler(.failure(taskError ?? NetworkingError(message: "Unknown error")))
                    return
                }

                // Save our cookies
                AuroraNetworking.cookies = session?.configuration.httpCookieStorage?.cookies
                AuroraNetworking.fullResponse = String(data: sitedata, encoding: .utf8)

                if let httpResponse = response as? HTTPURLResponse {
                    self.networkLog(
                        request: request, session: session, response: response, data: sitedata,
                        file: file, line: line, function: function
                    )

                    switch httpResponse.statusCode {
                    case 200, 201:
                        completionHandler(
                            .success(sitedata)
                        )
                        return self.logger.debug("[\(function)] HTTP OK")
                    default:
                        return completionHandler(
                            .failure(
                                NetworkingError(
                                    message: String(data: sitedata, encoding: .utf8) ?? "Unknown error"
                                )
                            )
                        )
                    }
                }
            }.resume()

            session = nil
        }

    /// Creates a network request that retrieves the contents of a URL \
    /// based on the specified URL request object, and calls a handler upon completion.
    ///
    /// - Parameters:
    ///   - url: A value that identifies the location of a resource, \
    ///   such as an item on a remote server or the path to a local file.
    ///   - method: The HTTP request method.
    ///   - parameters: POST values (if any)
    ///   - completionHandler: This completion handler takes the following parameters:
    ///   `Result<Data, Error>`
    ///     - `Data`: The data returned by the server.
    ///     - `Errror`: An error object that indicates why the request failed, or nil if the request was successful.
    public func request(
        baseURL: String,
        path: String,
        useAuthType: AuthType = .github,
        method: HTTPMethod,
        parameters: [String: Any]?,
        completionHandler: @escaping (Result<Data, Error>) -> Void,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        guard let siteURL = URL(string: baseURL + path) else {
            completionHandler(
                .failure(
                    NetworkingError(message: "Error: Request endpoint doesn't appear to be an URL")
                )
            )
            return
        }

        // Create a URL Request
        var request = createRequest(url: siteURL, useAuthType: useAuthType)
        request.httpMethod = method.rawValue

        if method == .POST || method == .PUT {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters ?? "")
        }

        exec(with: request, completionHandler: { result in
            completionHandler(result)
        }, file: file, line: line, function: function)
    }

    /// HTTP Request
    /// - Parameters:
    ///   - path: url path
    ///   - method: HTTP method
    ///   - useAuthType: Authentication type
    ///   - parameters: Parameters
    ///   - completionHandler: Completion handler
    ///   - file: current caller file
    ///   - line: current caller line
    ///   - function: current caller function
    public func request(
        path: String,
        method: HTTPMethod,
        useAuthType: AuthType = .github,
        parameters: [[String: Any]],
        completionHandler: @escaping (Result<Data, Error>) -> Void,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        // Check if the URL is valid
        guard let siteURL = URL(string: GithubNetworkingConstants.baseURL + path) else {
            completionHandler(
                .failure(
                    NetworkingError(message: "Error: Request endpoint doesn't appear to be an URL")
                )
            )
            return
        }

        // Create a URL Request
        var request = createRequest(url: siteURL, useAuthType: useAuthType)
        request.httpMethod = method.rawValue

        if method == .POST || method == .PUT {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }

        exec(with: request, completionHandler: { result in
            completionHandler(result)
        }, file: file, line: line, function: function)
    }

    /// Creates a network request that retrieves the contents of a URL \
    /// based on the specified URL request object, and calls a handler upon completion.
    ///
    /// - Parameters:
    ///   - url: A value that identifies the location of a resource, \
    ///   such as an item on a remote server or the path to a local file.
    ///   - method: The HTTP request method.
    ///   - useAuthToken: Use auth token?
    ///   - parameters: Codable post value
    ///   - completionHandler: This completion handler takes the following parameters:
    ///   `Result<Data, Error>`
    ///     - `Data`: The data returned by the server.
    ///     - `Errror`: An error object that indicates why the request failed, or nil if the request was successful.
    public func request<T: Encodable>(
        path: String,
        method: HTTPMethod,
        useAuthType: AuthType = .github,
        parameters: T,
        completionHandler: @escaping (Result<Data, Error>) -> Void,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        // Check if the URL is valid
        guard let siteURL = URL(string: GithubNetworkingConstants.baseURL + path) else {
            completionHandler(
                .failure(
                    NetworkingError(message: "Error: Request endpoint doesn't appear to be an URL")
                )
            )
            return
        }

        // Create a URL Request
        var request = createRequest(url: siteURL, useAuthType: useAuthType)
        request.httpMethod = method.rawValue

        if method == .POST || method == .PUT {
            request.httpBody = try? JSONEncoder().encode(parameters)
        }

        exec(with: request, completionHandler: { result in
            completionHandler(result)
        }, file: file, line: line, function: function)
    }

    /// Return the full networkRequestResponse
    /// - Returns: the full networkRequestResponse
    public func networkRequestResponse() -> String? {
        return AuroraNetworking.fullResponse
    }

    func networkLog(request: URLRequest?,
                    session: URLSession?,
                    response: URLResponse?,
                    data: Data?,
                    file: String = #file,
                    line: Int = #line,
                    function: String = #function) {
        if (response as? HTTPURLResponse)?.statusCode == 200 {
            return
        }

#if DEBUG
        self.logger.debug("Network debug start")
        if let request = request {
            self.networkLogRequest(request: request)
        }

        if let response = response as? HTTPURLResponse {
            self.networkLogResponse(response: response)
        }

        if let data = data {
            self.networkLogData(data: data)
        }

        self.logger.debug("End of network debug\n")
#endif
    }

    private func networkLogRequest(request: URLRequest) {
        self.logger.debug("URLRequest:")
        self.logger.debug("  \(request.httpMethod ?? "") \(String(describing: request.url))")
        self.logger.debug("\n  Headers:")
        if let headerFields = request.allHTTPHeaderFields {
            for (header, cont) in headerFields {
                self.logger.debug("    \(header): \(cont)")
            }
        }
        self.logger.debug("\n  Body:")
        if let httpBody = request.httpBody,
           let httpBodyValue = String(data: httpBody, encoding: .utf8) {
            self.logger.debug("    \(httpBodyValue)")
        }
        self.logger.debug("\n")
    }

    private func networkLogResponse(response: HTTPURLResponse) {
        self.logger.debug("HTTPURLResponse:")
        self.logger.debug("  HTTP \(response.statusCode)")
        for (header, cont) in response.allHeaderFields {
            self.logger.debug("    \(header): \(cont as? String ?? "")")
        }
    }

    private func networkLogData(data: Data) {
        if let stringData = String(data: data, encoding: .utf8) {
            self.logger.debug("\n  Body:")
            for line in stringData.split(separator: "\n") {
                self.logger.debug("    \(line)")
            }
        }

        do {
            self.logger.debug("\n  Decoded JSON:")
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                for (key, value) in dictionary {
                    self.logger.debug("    \(key): \"\(value as? String ?? "")\"")
                }
            }
        } catch {
            self.logger.fault("\(error.localizedDescription)")
        }
    }
}
