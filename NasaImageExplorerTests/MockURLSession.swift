//
//  MockURLSession.swift
//  NasaImageExplorerTests
//
//  Created by Micheal Bingham on 6/3/24.
//

import Foundation

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

class MockURLSession: URLSessionProtocol {
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = nextError {
            throw error
        }
        return (nextData ?? Data(), nextResponse ?? URLResponse())
    }
}
