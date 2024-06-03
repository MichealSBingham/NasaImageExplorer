//
//  NasaImageExplorerUITests.swift
//  NasaImageExplorerUITests
//
//  Created by Micheal Bingham on 6/2/24.
//

import XCTest



final class NasaImageExplorerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testSearchFunctionality() {
        let searchBar = app.searchFields["Search"]
        XCTAssertTrue(searchBar.exists, "The search bar should exist")
        
        searchBar.tap()
        searchBar.typeText("Mars")
        app.keyboards.buttons["Search"].tap()
        
        let firstCell = app.collectionViews.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "The collection view should show search results")
    }

    func testDetailView() {
        let searchBar = app.searchFields["Search"]
        searchBar.tap()
        searchBar.typeText("Mars")
        app.keyboards.buttons["Search"].tap()
        
        let firstCell = app.collectionViews.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "The collection view should show search results")
        
        firstCell.tap()
        
        let detailImage = app.images["DetailImageView"]
        XCTAssertTrue(detailImage.waitForExistence(timeout: 5), "The detail view should show the image")
        
        let titleLabel = app.staticTexts["TitleLabel"]
        XCTAssertTrue(titleLabel.exists, "The detail view should show the title")
    }
}
