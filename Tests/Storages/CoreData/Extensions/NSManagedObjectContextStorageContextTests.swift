//
//  NSManagedObjectContextStorageContextTests.swift
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

import CoreData
import XCTest

// swiftlint:disable type_name
class NSManagedObjectContextStorageContextTests: XCTestCase {

    var sut: StubManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        sut = StubManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }
    
    override func tearDown() {
        sut = nil
        
        SpyEntityDescription.clean()
        
        super.tearDown()
    }
}

// MARK: - identifier
extension NSManagedObjectContextStorageContextTests {
    
    func test_Identifier_IsAValidUUID() {
        let uuid = NSUUID(uuidString: sut.identifier)
        
        XCTAssertNotNil(uuid)
    }
}

// MARK: - delete(_:)
extension NSManagedObjectContextStorageContextTests {
    
    func test_Delete_ObjectNotNSManagedObject_ThrowsError() {
        let entity = DummyStorageEntity()

        do {
            try sut.delete(entity)

            XCTFail()
        } catch StorageKitErrors.Entity.wrongType {
            XCTAssertTrue(true)
        } catch { XCTFail() }

        XCTAssertEqual(sut.deleteCallsCount, 0)
    }

    func test_Delete_ObjectNotNSManagedObject_DoesNotCallSuperDelete() {
        let entity = DummyStorageEntity()

        do {
            try sut.delete(entity)
        } catch {}

        XCTAssertEqual(sut.deleteCallsCount, 0)
    }

    func test_Delete_ObjectNSManagedObject_CallsSuperDelete() {
        let entity = NSManagedObject()
        
        do {
            try (sut as StorageContext).delete(entity)
        } catch {
            XCTFail()
        }
        
        XCTAssertEqual(sut.deleteCallsCount, 1)
    }
    
    func test_Delete_ObjectNSManagedObject_CallsSuperDeleteWithRightArgument() {
        let entity = NSManagedObject()
        
        do {
            try (sut as StorageContext).delete(entity)
        } catch {
            XCTFail()
        }
        
        XCTAssertTrue(sut.deleteRequestArguments?.first === entity)
    }

	func test_Delete_ObjectNSManagedObjectAndHasNoChanges_DoesNotCallSuperSave() {
		do {
			try (sut as StorageContext).delete(NSManagedObject())
		} catch {
			XCTFail()
		}

		XCTAssertFalse(sut.isSaveCalled)
	}

	func test_Delete_ObjectNSManagedObjectAndHasChanges_CallsSuperSave() {
		do {
			sut.forcedHasChanges = true
			try (sut as StorageContext).delete(NSManagedObject())
		} catch {
			XCTFail()
		}

		XCTAssertTrue(sut.isSaveCalled)
	}
}

// MARK: - delete(_:[])
extension NSManagedObjectContextStorageContextTests {
    func test_Delete_ObjectsNotNSManagedObject_ThrowsError() {
        do {
            try sut.delete([DummyStorageEntity(), DummyStorageEntity(), DummyStorageEntity()])

            XCTFail()
        } catch StorageKitErrors.Entity.wrongType {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
        
        XCTAssertFalse(sut.isSaveCalled)
    }
    
    func test_Delete_ObjectsNotNSManagedObject_DoesNotCallSuperSave() {
        do {
            try sut.delete([DummyStorageEntity(), DummyStorageEntity(), DummyStorageEntity()])
        } catch {}
        
        XCTAssertFalse(sut.isSaveCalled)
    }

	func test_Delete_ObjectsNotNSManagedObject_DoesNotCallSuperDelete() {
		do {
			try sut.delete([DummyStorageEntity(), DummyStorageEntity(), DummyStorageEntity()])
		} catch {}

		XCTAssertEqual(sut.deleteCallsCount, 0)
	}

	func test_Delete_ObjectsNSManagedObject_CallsSuperDelete() {
		do {
			try (sut as StorageContext).delete([NSManagedObject(), NSManagedObject(), NSManagedObject()])
		} catch {
			XCTFail()
		}

		XCTAssertEqual(sut.deleteCallsCount, 3)
	}

	func test_Delete_ObjectsNSManagedObject_CallsSuperDeleteWithRightArguments() {
		let entity = NSManagedObject()
		let entity2 = NSManagedObject()
		let entity3 = NSManagedObject()

		do {
			try (sut as StorageContext).delete([entity, entity2, entity3])
		} catch {
			XCTFail()
		}

		XCTAssertTrue(sut.deleteRequestArguments?.first === entity)
		XCTAssertTrue(sut.deleteRequestArguments?[1] === entity2)
		XCTAssertTrue(sut.deleteRequestArguments?[2] === entity3)
	}

	func test_Delete_ObjectsNSManagedObjectAndHasNoChanges_DoesNotCallSuperSave() {
		do {
			try (sut as StorageContext).delete([NSManagedObject(), NSManagedObject(), NSManagedObject()])
		} catch {
			XCTFail()
		}

		XCTAssertFalse(sut.isSaveCalled)
	}

	func test_Delete_ObjectsNSManagedObjectAndHasChanges_CallsSuperSave() {
		do {
			sut.forcedHasChanges = true
			try (sut as StorageContext).delete([NSManagedObject(), NSManagedObject(), NSManagedObject()])
		} catch {
			XCTFail()
		}

		XCTAssertTrue(sut.isSaveCalled)
	}
}

// MARK: - add(_ :)
extension NSManagedObjectContextStorageContextTests {
    func test_Add_OneEntityNotNSManagedObject_DoesNotCallsSuperSave() {
        do {
            try sut.addOrUpdate(DummyStorageEntity())
        } catch {}

        XCTAssertFalse(sut.isSaveCalled)
    }
    
    func test_Add_OneEntityNotNSManagedObject_ThrowsError() {
        do {
            try sut.addOrUpdate(DummyStorageEntity())

            XCTFail()
        } catch StorageKitErrors.Entity.wrongType {
            XCTAssertTrue(true)
        } catch { XCTFail() }

        XCTAssertFalse(sut.isSaveCalled)
    }
    
    func test_Add_OneEntity_CallsSuperSave() {
        do {
            try sut.addOrUpdate(NSManagedObject())
        } catch {
            XCTFail()
        }

        XCTAssertTrue(sut.isSaveCalled)
    }

    func test_Add_ArrayOfEntities_CallsSuperSave() {
        do {
            try sut.addOrUpdate([NSManagedObject(), NSManagedObject(), NSManagedObject()])
        } catch {
            XCTFail()
        }
        
        XCTAssertTrue(sut.isSaveCalled)
    }
}

// MARK: - update(transform:)
extension NSManagedObjectContextStorageContextTests {
    func test_Update_CallsSuperSave() {
        do {
            try sut.update {}
        } catch {
            XCTFail()
        }
        
        XCTAssertTrue(sut.isSaveCalled)
    }
}

// MARK: - fetch(predicate: sortDescriptors:)
extension NSManagedObjectContextStorageContextTests {
    func test_Fetch_NotNSManagedObject_ThrowsErrror() {
        do {
            try sut.fetch { (_: [DummyStorageEntity]?) in }
            XCTFail()
        } catch StorageKitErrors.Entity.wrongType {
            XCTAssertTrue(true)
        } catch { XCTFail() }

        XCTAssertFalse(sut.isExecuteCalled)
    }
    
    func test_Fetch_NotNSManagedObject_ExecuteIsNotCalled() {
        do {
            try sut.fetch { (_: [DummyStorageEntity]?) in }
        } catch {}

        XCTAssertFalse(sut.isExecuteCalled)
    }
    
    func test_Fetch_NotNSManagedObject_ExecuteDoesNotUsePredicate() {
        let request = NSPredicate()

        do {
            try sut.fetch(predicate: request) { (_: [DummyStorageEntity]?) in }
        } catch {}

        XCTAssertFalse(sut.executeRequestArgument?.fetchRequest.predicate === request)
    }

    func test_Fetch_NotNSManagedObject_ExecuteDoesNotUseRightEntityName() {
        do {
            try sut.fetch { (_: [DummyStorageEntity]?) in }
        } catch {}

        XCTAssertNil(sut.executeRequestArgument?.fetchRequest.entityName)
    }

    func test_Fetch_NSManagedObject_ExecuteIsCalled() {
        do {
            try sut.fetch { (_: [NSManagedObject]?) in }
        } catch {}

        XCTAssertTrue(sut.isExecuteCalled)
    }

    func test_Fetch_NSManagedObject_ExecuteUsesRightPredicate() {
        let request = NSPredicate()

        do {
            try sut.fetch(predicate: request) { (_: [NSManagedObject]?) in }
        } catch {}

        XCTAssertTrue(sut.executeRequestArgument?.fetchRequest.predicate === request)
    }

    func test_Fetch_NSManagedObject_ExecuteUsesRightSortDesc() {
        let sortDesc = SortDescriptor(key: "t1", ascending: false)
        let sortDesc2 = SortDescriptor(key: "t2", ascending: true)

        do {
            try sut.fetch(sortDescriptors: [sortDesc, sortDesc2]) { (_: [NSManagedObject]?) in }
        } catch {}

        XCTAssertEqual(sut.executeRequestArgument?.fetchRequest.sortDescriptors?.first?.key, "t1")
        XCTAssertEqual(sut.executeRequestArgument?.fetchRequest.sortDescriptors?[1].key, "t2")
    }

    func test_Fetch_NSManagedObject_ExecuteUsesRightEntityName() {
        do {
            try sut.fetch { (_: [FakeManagedObject]?) in }
        } catch {}

        XCTAssertEqual(sut.executeRequestArgument?.fetchRequest.entityName, "FAKE")
    }
}
