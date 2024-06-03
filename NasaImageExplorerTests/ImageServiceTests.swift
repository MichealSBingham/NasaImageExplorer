//
//  ImageService.swift
//  NasaImageExplorerTests
//
//  Created by Micheal Bingham on 6/3/24.
//

import XCTest
@testable import NasaImageExplorer

final class ImageServiceTests: XCTestCase {
    var mockSession: MockURLSession!
    var imageService: ImageService!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        imageService = ImageService(session: mockSession)
    }

    override func tearDown() {
        mockSession = nil
        imageService = nil
        super.tearDown()
    }

    func testFetchImages() async {
        let jsonData = """
        {
            "collection": {
                "items": [
                    {
                        "data": [{
                            "title": "Test Image",
                            "description": "Test Description",
                            "photographer": "Test Photographer",
                            "location": "Test Location"
                        }],
                        "links": [{
                            "href": "https://example.com/test.jpg",
                            "rel": "preview"
                        }]
                    }
                ]
            }
        }
        """.data(using: .utf8)!

        mockSession.nextData = jsonData
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let images = try? await imageService.fetchImages(query: "Mars")
        XCTAssertNotNil(images)
        XCTAssertEqual(images?.count, 1)
        XCTAssertEqual(images?.first?.title, "Test Image")
    }
}
