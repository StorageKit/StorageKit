//
//  ContextRepoTests.swift
//  StorageKit
//
//  Created by Marco Santarossa on 20/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

@testable import StorageKit

import XCTest

class ContextRepoTests: XCTestCase {

	var contextRepo: ContextRepo!

    override func setUp() {
        super.setUp()

		contextRepo = ContextRepo()
	}
    
    override func tearDown() {
		contextRepo = nil

		super.tearDown()
    }
}

// MARK: - retrieveQueue(for: )
extension ContextRepoTests {
	func test_RetrieveQueue_InvalidContext_ReturnsNil() {
		let queue = contextRepo.retrieveQueue(for: DummyStorageContext())

		XCTAssertNil(queue)
	}

	func test_RetrieveQueue_ValidContext_ReturnsValidQueue() {
		contextRepo.store(context: DummyStorageContext(), queue: .init(label: "Q1"))
		contextRepo.store(context: DummyStorageContext(), queue: .init(label: "Q2"))
		contextRepo.store(context: DummyStorageContext(), queue: .init(label: "Q3"))
		contextRepo.store(context: DummyStorageContext(), queue: .init(label: "Q4"))
		contextRepo.store(context: DummyStorageContext(), queue: .init(label: "Q5"))
		let context = DummyStorageContext()
		let originalQueue = DispatchQueue.init(label: "Q6")
		contextRepo.store(context: context, queue: originalQueue)

		let queue = contextRepo.retrieveQueue(for: context)

		XCTAssertTrue(queue === originalQueue)
	}
}
