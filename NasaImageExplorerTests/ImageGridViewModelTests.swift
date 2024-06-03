//
//  ImageGridViewModelTests.swift
//  NasaImageExplorerTests
//
//  Created by Micheal Bingham on 6/3/24.
//

import XCTest
@testable import NasaImageExplorer

final class ImageGridViewModelTests: XCTestCase {
    var viewModel: ImageGridViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ImageGridViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testFetchImages() async {
        let expectation = XCTestExpectation(description: "Fetch images")

        Task {
            await viewModel.searchImages(query: "Mars")
            XCTAssertFalse(viewModel.images.isEmpty, "Images should not be empty")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testLoadMoreImages() async {
        // First, fetch initial set of images
        await viewModel.searchImages(query: "Mars")

        // Then, load more images
        let initialImageCount = viewModel.images.count
        await viewModel.loadMoreImages()

        XCTAssertTrue(viewModel.images.count > initialImageCount, "More images should be loaded")
    }
}

