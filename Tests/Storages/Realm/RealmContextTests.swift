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

// swiftlint:disable file_length
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

// MARK: - create()
extension RealmContextTests {
	func test_Create_EntityNotObject_ThrowsError() {
		do {
			let _: DummyStorageEntity? = try sut.create()

			XCTFail()
		} catch RealmContext.RealmError.wrongObject {
			XCTAssertTrue(true)
		} catch {
			XCTFail()
		}
	}

	func test_Create_EntityObject_ReturnValidObject() {
		do {
			let entity: Object? = try sut.create()

			XCTAssertNotNil(entity)
		} catch {}
	}
}

// MARK: - add(entity)
extension RealmContextTests {
	func test_AddEntity_ObjectNotNil_RealmAddIsNotCalled() {
		do {
			try sut.addOrUpdate(DummyStorageEntity())

			XCTAssertEqual(getSpyRealm().addCallsCount, 0)
		} catch {}
	}

	func test_AddEntity_ObjectNil_RealmAddIsCalled() {
		do {
			try sut.addOrUpdate(Object())

			XCTAssertEqual(getSpyRealm().addCallsCount, 1)
		} catch {}
	}

	func test_AddEntity_ObjectNil_RealmAddIsCalledWithRightArguments() {
		do {
			let obj = Object()
			try sut.addOrUpdate(obj)

			XCTAssertTrue(getSpyRealm().addObjectArguments?.first === obj)
			XCTAssertFalse(getSpyRealm().addUpdatesArguments?.first ?? true)
		} catch {}
	}

	func test_AddEntity_EntityObject_CallsRealmWriteBlock() {
		do {
			try sut.addOrUpdate(Object())

			XCTAssertTrue(getSpyRealm().isWriteCalled)
		} catch {}
	}
    
    func test_AddEntity_EntityObject_UpdateIsNotCalled() {
        do {
            try sut.addOrUpdate(DummyStorageEntity())
            
            XCTAssertFalse(getSpyRealm().isUpdateCalledOnAdd)
        } catch {
            XCTFail()
        }
    }
    
    func test_AddEntity_EntityObject_UpdateIsCalled() {
        do {
            
            try sut.addOrUpdate(SpyRealmEntity())
            try sut.addOrUpdate(SpyRealmEntity())
            
            XCTAssertTrue(getSpyRealm().isUpdateCalledOnAdd)
        } catch {
            XCTFail()
        }
    }
}

// MARK: - add(entities)
extension RealmContextTests {
	func test_AddEntities_ObjectNotNil_RealmAddIsNotCalled() {
		do {
			try sut.addOrUpdate([DummyStorageEntity(), DummyStorageEntity()])

			XCTAssertEqual(getSpyRealm().addCallsCount, 0)
		} catch {}
	}

	func test_AddEntities_ObjectNil_RealmAddIsCalledTwice() {
		do {
			try sut.addOrUpdate([Object(), Object()])

			XCTAssertEqual(getSpyRealm().addCallsCount, 2)
		} catch {}
	}

	func test_AddEntities_ObjectNil_RealmAddIsCalledTwiceWithRightArguments() {
		do {
			let obj = Object()
			let obj2 = Object()
			try sut.addOrUpdate([obj, obj2])

			XCTAssertTrue(getSpyRealm().addObjectArguments?.first === obj)
			XCTAssertFalse(getSpyRealm().addUpdatesArguments?.first ?? true)

			XCTAssertTrue(getSpyRealm().addObjectArguments?[1] === obj2)
			XCTAssertFalse(getSpyRealm().addUpdatesArguments?[1] ?? true)
		} catch {}
	}

	func test_AddEntities_EntityObject_CallsRealmWriteBlock() {
		do {
			try sut.addOrUpdate(Object())

			XCTAssertTrue(getSpyRealm().isWriteCalled)
		} catch {}
	}
}

// MARK: - update()
extension RealmContextTests {
	func test_Update_ClosureIsCalled() {
		let expectation = self.expectation(description: "")

		do {
			try sut.update {
				expectation.fulfill()
			}
		} catch {}

		waitForExpectations(timeout: 1)
	}

	func test_Update_CallsRealmWriteBlock() {
		do {
			try sut.update {}

			XCTAssertTrue(getSpyRealm().isWriteCalled)
		} catch {}
	}
}

// MARK: - fetch()
extension RealmContextTests {
//	var objects = realm.objects(type: entityToFetch)
//
//	if let predicate = predicate {
//		objects = objects.filter(predicate: predicate)
//	}
//
//	if let sortDescriptors = sortDescriptors {
//		for sortDescriptor in sortDescriptors {
//			objects = objects.sorted(keyPath: sortDescriptor.key, ascending: sortDescriptor.ascending)
//		}
//	}

	func test_Fetch_EntityNotObject_DoesNotCallsRealmObjects() {
		sut.fetch { (entity: [DummyStorageEntity]?) in print(entity?.count ?? 0) }

		XCTAssertFalse(getSpyRealm().isObjectsCalled)
	}

	func test_Fetch_EntityObject_CallsRealmObjects() {
		sut.fetch { (entity: [Object]?) in print(entity?.count ?? 0) }

		XCTAssertTrue(getSpyRealm().isObjectsCalled)
	}

	func test_Fetch_EntityObject_CallsRealmObjectsWithRightArgument() {
		sut.fetch { (entity: [Object]?) in print(entity?.count ?? 0) }

		XCTAssertTrue(getSpyRealm().objectsTypeArgument is Object.Type)
	}

	func test_Fetch_PredicateNil_DoesNotCallResultPredicate() {
		sut.fetch { (entity: [Object]?) in print(entity?.count ?? 0) }

		XCTAssertFalse(getSpyRealm().forcedResult.isFilterCalled)
	}

	func test_Fetch_PredicateNotNil_CallsResultPredicate() {
		sut.fetch(predicate: NSPredicate(value: true)) { (entity: [Object]?) in print(entity?.count ?? 0) }

		XCTAssertTrue(getSpyRealm().forcedResult.isFilterCalled)
	}
	
	func test_Fetch_PredicateNotNil_CallsResultPredicateWithRightArgument() {
		let predicate = NSPredicate(value: true)
		sut.fetch(predicate: predicate) { (entity: [Object]?) in print(entity?.count ?? 0) }

		XCTAssertTrue(getSpyRealm().forcedResult.filterPredicateArgument === predicate)
	}
	
	func test_Fetch_DescriptorsNil_DoesNotCallResultDescriptors() {
		sut.fetch { (entity: [Object]?) in print(entity?.count ?? 0) }

		XCTAssertEqual(getSpyRealm().forcedResult.sortedCallsCount, 0)
	}

	func test_Fetch_DescriptorsNotNil_CallsResultDescriptors() {
		let sort = SortDescriptor(key: "a", ascending: true)
		let sort2 = SortDescriptor(key: "b", ascending: false)
		sut.fetch(sortDescriptors:[sort, sort2]) { (entity: [Object]?) in print(entity?.count ?? 0) }

		XCTAssertEqual(getSpyRealm().forcedResult.sortedCallsCount, 2)
	}

	func test_Fetch_DescriptorsNotNil_CallsResultDescriptorsWithRightArguments() {
		let sort = SortDescriptor(key: "a", ascending: true)
		let sort2 = SortDescriptor(key: "b", ascending: false)
		sut.fetch(sortDescriptors:[sort, sort2]) { (entity: [Object]?) in print(entity?.count ?? 0) }

		XCTAssertEqual(getSpyRealm().forcedResult.sortedKeyPathArguments.first, "a")
		XCTAssertEqual(getSpyRealm().forcedResult.sortedAscendingArguments.first, true)

		XCTAssertEqual(getSpyRealm().forcedResult.sortedKeyPathArguments[1], "b")
		XCTAssertEqual(getSpyRealm().forcedResult.sortedAscendingArguments[1], false)
	}

	func test_Fetch_EntityObject_ReturnsRightEntities() {
		let object = Object()
		let object2 = Object()
		getSpyRealm().forcedResult.toArray = [object, object2]
		let expectation = self.expectation(description: "")

		sut.fetch { (entity: [Object]?) in
			XCTAssertTrue(entity?.first === object)
			XCTAssertTrue(entity?[1] === object2)

			expectation.fulfill()
		}

		waitForExpectations(timeout: 1)
	}
}
