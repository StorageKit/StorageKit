//
//  RealmDataStorageTests.swift
//  StorageKit
//
//  Copyright (c) 2017 StorageKit (https://github.com/StorageKit)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@testable import StorageKit

import RealmSwift
import XCTest

class RealmDataStorageTests: XCTestCase {

	var sut: RealmDataStorage!

    override func setUp() {
        super.setUp()

		var configuration = RealmDataStorage.Configuration()
		configuration.ContextRepoType = SpyContextRepo.self
		configuration.RealmContextType = SpyRealmContext.self
		sut = RealmDataStorage(configuration: configuration)
	}
    
    override func tearDown() {
		sut = nil

		SpyContextRepo.clean()
		SpyRealmContext.clean()

		super.tearDown()
    }
}

// MARK: - init
extension RealmDataStorageTests {
	func test_Init_MainContextIsNotNil() {
		XCTAssertNotNil(sut.mainContext)
	}

	func test_Init_MainContextIsRightValue() {
		XCTAssertTrue(type(of: sut.mainContext!) == SpyRealmContext.self)
	}

	func test_Init_RealmContextTypeInitIsCalled() {
		XCTAssertTrue(SpyRealmContext.isInitCalled)
	}

	func test_Init_RealmContextTypeInitIsCalledWithRightArgument() {
		XCTAssertTrue(SpyRealmContext.initRealmTypeArgument == Realm.self)
	}

	func test_Init_ContextRepoInitIsCalled() {
		XCTAssertTrue(SpyContextRepo.isInitCalled)
	}

	func test_Init_ContextRepoInitIsCalledWithRightArgument() {
		XCTAssertNil(SpyContextRepo.initCleaningIntervalArgumet)
	}

	func test_Init_ContextRepoStoreIsCalled() {
		XCTAssertTrue(SpyContextRepo.isStoreCalled)
	}

	func test_Init_ContextRepoStoreIsCalledWithRightArguments() {
		XCTAssertTrue(SpyContextRepo.storeContextArgumet === sut.mainContext)
		XCTAssertEqual(SpyContextRepo.storeQueueArgumet, .main)
	}
}

// MARK: - performBackgroundTask(_:)
extension RealmDataStorageTests {
	func test_PerformBackgrounTask_ClosureIsCalledInRightQueue() {
		let expectation = self.expectation(description: "")

		sut.performBackgroundTask { _, _ in
			let name = __dispatch_queue_get_label(nil)
			let queueName = String(cString: name, encoding: .utf8)

			XCTAssertEqual(queueName, "com.StorageKit.realmDataStorage")

			expectation.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func test_PerformBackgrounTask_RealmContextTypeInitIsCalled() {
		SpyContextRepo.clean()
		let expectation = self.expectation(description: "")

		sut.performBackgroundTask { _, _ in
			XCTAssertTrue(SpyRealmContext.isInitCalled)

			expectation.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func test_PerformBackgrounTask_RealmContextTypeInitIsCalledWithRightArgument() {
		SpyContextRepo.clean()
		let expectation = self.expectation(description: "")

		sut.performBackgroundTask { _, _ in
			XCTAssertTrue(SpyRealmContext.initRealmTypeArgument == Realm.self)

			expectation.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func test_PerformBackgrounTask_ContextRepoStoreIsCalled() {
		SpyContextRepo.clean()
		let expectation = self.expectation(description: "")

		sut.performBackgroundTask { _, _ in
			XCTAssertTrue(SpyContextRepo.isStoreCalled)

			expectation.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func test_PerformBackgrounTask_ContextRepoStoreIsCalledWithRightArgument() {
		SpyContextRepo.clean()
		let expectation = self.expectation(description: "")

		sut.performBackgroundTask { context, queue in
			XCTAssertTrue(SpyContextRepo.storeContextArgumet === context)
			XCTAssertTrue(SpyContextRepo.storeQueueArgumet === queue)

			expectation.fulfill()
		}

		waitForExpectations(timeout: 1)
	}
}

// MARK: - getThreadSafeEntities(_:)
extension RealmDataStorageTests {
	func test_GetThreadSafeEntities_StorageContextNotRealmContext_CompletionHasEmptyArray() {
		let expectation = self.expectation(description: "")

		sut.getThreadSafeEntities(for: DummyStorageContext(), originalContext: DummyStorageContext(), originalEntities: [DummyStorageEntity(), DummyStorageEntity()]) { (result: [DummyStorageEntity]) in
			XCTAssertTrue(result.isEmpty)

			expectation.fulfill()
		}

		waitForExpectations(timeout: 1)
	}
}
