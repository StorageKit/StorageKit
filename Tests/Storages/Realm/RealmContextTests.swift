//
//  RealmContextTests.swift
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

import Realm
import RealmSwift
import XCTest

class RealmContextTests: XCTestCase {

	fileprivate var sut: RealmContext!

    override func setUp() {
        super.setUp()

		sut = RealmContext(realmType: SpyRealm.self)
	}
    
    override func tearDown() {
		sut = nil

		super.tearDown()
    }

	func getSpyRealm() -> SpyRealm {
		guard let realm = sut.realm as? SpyRealm else {
			Swift.fatalError("spy realm not found")
		}
		return realm
	}
}

// MARK: - init
extension RealmContextTests {
	func test_Init_RealmInitIsCalled() {
		XCTAssertTrue(getSpyRealm().isInitCalled)
	}

	func test_Init_RealmInitIsCalledWithDefaultConfiguration() {
		let configPath = getSpyRealm().initConfigurationArgument?.fileURL?.relativePath
		XCTAssertEqual(configPath, RLMRealmPathForFile("default.realm"))
	}
}

// MARK: - safeWriteAction
extension RealmContextTests {
	func test_SafeWriteAction_IsInWriteTransactionFalse_RealmWriteIsCalled() {
		let realm = getSpyRealm()
		realm.isInWriteTransaction = false

		do {
			try sut.safeWriteAction {}
		} catch {}

		XCTAssertTrue(realm.isWriteCalled)
	}
	
	func test_SafeWriteAction_IsInWriteTransactionTrue_RealmWriteIsNotCalled() {
		let realm = getSpyRealm()
		realm.isInWriteTransaction = true

		do {
			try sut.safeWriteAction {}
		} catch {}

		XCTAssertFalse(realm.isWriteCalled)
	}
}

// MARK: - delete(entity)
extension RealmContextTests {
	func test_Delete_EntityNotObject_ThrowsError() {
		do {
			try sut.delete(DummyStorageEntity())

			XCTFail()
		} catch RealmContext.RealmError.wrongObject {
			XCTAssertTrue(true)
		} catch {
			XCTFail()
		}
	}

	func test_Delete_EntityObject_CallsRealmDeleteOnce() {
		do {
			let object = Object()
			try sut.delete(object)

			XCTAssertEqual(getSpyRealm().deleteCallsCount, 1)

		} catch {}
	}

	func test_Delete_EntityObject_CallsRealmDeleteOnceWithRightArgument() {
		do {
			let object = Object()
			try sut.delete(object)

			XCTAssertTrue(getSpyRealm().deleteObjectArguments?.first === object)
		} catch {}
	}

	func test_Delete_EntityObject_CallsRealmWriteBlock() {
		do {
			let object = Object()
			try sut.delete(object)

			XCTAssertTrue(getSpyRealm().isWriteCalled)
		} catch {}
	}
}

// MARK: - delete(entities)
extension RealmContextTests {
	func test_DeleteEntities_EntityObject_CallsRealmDeleteTwice() {
		do {
			let object = Object()
			let object2 = Object()
			try sut.delete([object, object2])

			XCTAssertEqual(getSpyRealm().deleteCallsCount, 2)

		} catch {}
	}

	func test_DeleteEntities_EntityObject_CallsRealmDeleteTwiceWithRightArgument() {
		do {
			let object = Object()
			let object2 = Object()
			try sut.delete([object, object2])

			XCTAssertTrue(getSpyRealm().deleteObjectArguments?.first === object)
			XCTAssertTrue(getSpyRealm().deleteObjectArguments?[1] === object2)
		} catch {}
	}

	func test_DeleteEntities_EntityObject_CallsRealmWriteBlock() {
		do {
			let object = Object()
			let object2 = Object()
			try sut.delete([object, object2])

			XCTAssertTrue(getSpyRealm().isWriteCalled)
		} catch {}
	}
}

// MARK: - deleteAll(_)
extension RealmContextTests {
	func test_DeleteAll_EntityNotObject_ThrowsError() {
		do {
			try sut.deleteAll(DummyStorageEntity.self)

			XCTFail()
		} catch RealmContext.RealmError.wrongObject {
			XCTAssertTrue(true)
		} catch {
			XCTFail()
		}
	}

	func test_DeleteAll_EntityObject_CallsRealmObjects() {
		do {
			try sut.deleteAll(Object.self)

			XCTAssertTrue(getSpyRealm().isObjectsCalled)

		} catch {}
	}

	func test_DeleteAll_EntityObject_CallsRealmObjectsWithRightArgument() {
		do {
			try sut.deleteAll(Object.self)

			XCTAssertTrue(getSpyRealm().objectsTypeArgument is Object.Type)

		} catch {}
	}

	func test_DeleteAll_TwoEntityObjects_CallsRealmDeleteTwice() {
		do {
			let object = Object()
			let object2 = Object()
			getSpyRealm().forcedResult.toArray = [object, object2]

			try sut.deleteAll(Object.self)

			XCTAssertEqual(getSpyRealm().deleteCallsCount, 2)

		} catch {}
	}

	func test_DeleteAll_TwoEntityObjects_CallsRealmDeleteTwiceWithRightArguments() {
		do {
			let object = Object()
			let object2 = Object()
			getSpyRealm().forcedResult.toArray = [object, object2]

			try sut.deleteAll(Object.self)

			XCTAssertTrue(getSpyRealm().deleteObjectArguments?.first === object)
			XCTAssertTrue(getSpyRealm().deleteObjectArguments?[1] === object2)

		} catch {}
	}

	func test_DeleteAll_EntityObject_CallsRealmWriteBlock() {
		do {
			try sut.deleteAll(Object.self)

			XCTAssertTrue(getSpyRealm().isWriteCalled)
		} catch {}
	}
}
