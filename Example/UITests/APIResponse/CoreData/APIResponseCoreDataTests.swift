//
//  APIResponseCoreDataTests.swift
//  Example
//
//  Created by Marco Santarossa on 18/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import XCTest

class APIResponseCoreDataTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func test_FirstRow_ContainsRightData() {

        XCUIApplication().tables.staticTexts["API response - Core Data"].tap()
        
		let jamesBondUsernameExists = XCUIApplication().tables.staticTexts["007"].exists
		let jamesBondFullnameExists = XCUIApplication().tables.staticTexts["James Bond"].exists

		XCTAssertTrue(jamesBondUsernameExists)
		XCTAssertTrue(jamesBondFullnameExists)
	}
    
}
