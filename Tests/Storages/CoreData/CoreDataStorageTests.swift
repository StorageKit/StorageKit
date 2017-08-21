//
//  CoreDataStorageTests.swift
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

class CoreDataStorageTests: XCTestCase {
    
    fileprivate var sut: CoreDataStorage!
    
    override func setUp() {
        super.setUp()

        var configuration = CoreDataConfiguration()
        configuration.ManagedObjectModelType = SpyManagedObjectModel.self
        configuration.PersistentStoreCoordinatorType = SpyPersistentStoreCoordinator.self
        configuration.ManagedObjectContext = SpyManagedObjectContext.self
        configuration.bundle = FakeBundle()
        sut = CoreDataStorage(configuration: configuration)
    }
    
    override func tearDown() {
        sut = nil
        
        SpyManagedObjectModel.clean()
        SpyPersistentStoreCoordinator.clean()
        SpyManagedObjectContext.clean()
        
        super.tearDown()
    }
}

// MARK: - init(configuration:)
extension CoreDataStorageTests {
    
    func test_Init_BundleWithExtensionIsCalled() {
        let bundle = SpyBundle()
        var configuration = CoreDataConfiguration()
        configuration.ManagedObjectModelType = SpyManagedObjectModel.self
        configuration.PersistentStoreCoordinatorType = SpyPersistentStoreCoordinator.self
        configuration.ManagedObjectContext = SpyManagedObjectContext.self
        configuration.bundle = bundle
        sut = CoreDataStorage(configuration: configuration)
        
        XCTAssertTrue(bundle.isUrlWithExtensionCalled)
    }
    
    func test_Init_BundleWithExtensionIsCalledWithRightArguments() {
        let bundle = SpyBundle()
        var configuration = CoreDataConfiguration()
        configuration.ManagedObjectModelType = SpyManagedObjectModel.self
        configuration.PersistentStoreCoordinatorType = SpyPersistentStoreCoordinator.self
        configuration.ManagedObjectContext = SpyManagedObjectContext.self
        configuration.bundle = bundle
        sut = CoreDataStorage(configuration: configuration)
        
        XCTAssertEqual(bundle.urlWithExtensionNameArgument, "StorageKit")
        XCTAssertEqual(bundle.urlWithExtensionExtArgument, "momd")
    }
    
    func test_Init_CreatesManagedObjectModel() {
        XCTAssertTrue(SpyManagedObjectModel.isInitWithContentCalled)
    }
    
    func test_Init_CreatesManagedObjectModelWithRightUrl() {
        XCTAssertEqual(SpyManagedObjectModel.initWithContentUrlParameter?.absoluteString, "www.google.com")
    }
    
    func test_Init_CreatesPersistentStoreCoordinator() {
        XCTAssertTrue(SpyPersistentStoreCoordinator.isInitWithModelCalled)
    }
    
    func test_Init_CreatesPersistentStoreCoordinatorWithRightModel() {
        guard let model = SpyPersistentStoreCoordinator.initWithModelArgument as? SpyManagedObjectModel else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.url.absoluteString, "www.google.com")
    }
    
    func test_Init_AddsPersistentStore() {
        XCTAssertTrue(SpyPersistentStoreCoordinator.isAddPersistentStoreCalled)
    }
    
    func test_Init_SqlType_AddsPersistentStoreWithRightType() {
        XCTAssertEqual(SpyPersistentStoreCoordinator.addPersistentStoreTypeArgument, CoreDataStorage.StoreType.sql.rawValue)
    }
    
    func test_Init_MemoryType_AddsPersistentStoreWithRightType() {
        var configuration = CoreDataConfiguration()
        configuration.storeType = .memory
        configuration.ManagedObjectModelType = SpyManagedObjectModel.self
        configuration.PersistentStoreCoordinatorType = SpyPersistentStoreCoordinator.self
        configuration.bundle = FakeBundle()
        sut = CoreDataStorage(configuration: configuration)

        XCTAssertEqual(SpyPersistentStoreCoordinator.addPersistentStoreTypeArgument, CoreDataStorage.StoreType.memory.rawValue)
    }
    
    func test_Init_AddsPersistentStoreWithRightStoreUrl() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        let url = docURL.appendingPathComponent("StorageKit.sqlite")

        XCTAssertEqual(SpyPersistentStoreCoordinator.addPersistentStoreStoreUrlArgument, url)
    }
    
    func test_Init_AddsPersistentStoreWithNilConfigurationAndOptions() {
        XCTAssertNil(SpyPersistentStoreCoordinator.addPersistentStoreConfigurationArgument)
        XCTAssertNil(SpyPersistentStoreCoordinator.addPersistentStoreOptionsArgument)
    }
    
    func test_Init_CreatesManagedObjectContextWithConcurrencyType() {
        XCTAssertTrue(SpyManagedObjectContext.isInitWithConcurrencyTypeCalled)
    }
    
    func test_Init_CreatesManagedObjectContextWithMainQueue() {
        XCTAssertEqual(SpyManagedObjectContext.initWithConcurrencyTypeArgument ?? NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType, NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    }
    
    func test_Init_AddsPersistentStoreCoordinatorToContext() {
        XCTAssertTrue(SpyManagedObjectContext.isPersistentStoreCoordinatorTypeSet)
    }
    
    func test_Init_AddsRightPersistentStoreCoordinatorToContext() {
        guard let coordinator = SpyManagedObjectContext.persistentStoreCoordinatorTypeSetValue as? SpyPersistentStoreCoordinator,
            let model = coordinator.model as? SpyManagedObjectModel else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.url.absoluteString, "www.google.com")
    }
}

// MARK: mainContext
extension CoreDataStorageTests {
    func test_MainContext_IsMainManagedObjectContext() {
        XCTAssertTrue(sut.mainContext === sut.mainManagedObjectContext, "Main Context is not Main Managed Object Context")
    }
}

// MARK: performBackgroundTask(_:)
extension CoreDataStorageTests {
    func test_PerformBackgroundTask_ClosureHasNewContextAsArgument() {
        let expectation = self.expectation(description: "PerformBackgroundTask_ClosureHasNewContextAsArgument")
        
        sut.performBackgroundTask {
            guard let moc = $0 as? SpyManagedObjectContext else {
                XCTFail()
                expectation.fulfill()

                return
            }
            XCTAssertTrue(moc.isInitWithConcurrencyTypeCalled)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_PerformBackgroundTask_ClosureHasPrivateContextAsArgument() {
        let expectation = self.expectation(description: "PerformBackgroundTask_ClosureHasPrivateContextAsArgument")
        
        sut.performBackgroundTask {
            guard let moc = $0 as? SpyManagedObjectContext else {
                XCTFail()
                expectation.fulfill()
                
                return
            }
            XCTAssertEqual(moc.initWithConcurrencyTypeArgument, .privateQueueConcurrencyType)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_PerformBackgroundTask_ClosureHasContextAsArgumentWithAParentContext() {
        let expectation = self.expectation(description: "PerformBackgroundTask_ClosureHasContextAsArgumentWithAParentContext")
        
        sut.performBackgroundTask {
            guard let moc = $0 as? SpyManagedObjectContext else {
                XCTFail()
                expectation.fulfill()
                
                return
            }
            XCTAssertTrue(moc.isContextParentSetCalled)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }

	func test_PerformBackgroundTask_ClosureHasContextAsArgumentWithMainAsParent() {
		let expectation = self.expectation(description: "PerformBackgroundTask_ClosureHasContextAsArgumentWithMainAsParent")

		sut.performBackgroundTask {
			guard let moc = $0 as? SpyManagedObjectContext else {
				XCTFail()
				expectation.fulfill()

				return
			}
			XCTAssertTrue(moc.contextParentSetArgument === self.sut.mainContext)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func test_PerformBackgroundTask_ManagedObjectContextPerformIsCalled() {
		let expectation = self.expectation(description: "PerformBackgroundTask_ManagedObjectContextPerformIsCalled")

		sut.performBackgroundTask {
			guard let moc = $0 as? SpyManagedObjectContext else {
				XCTFail()
				expectation.fulfill()

				return
			}
			XCTAssertTrue(moc.isPerformCalled)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 1)
	}
}

extension CoreDataStorageTests {

    func test_GetThreadSafeEntities_ContextNotNSManagedObjectContext_ReturnsEmptyArrat() {
        let expectation = self.expectation(description: "GetThreadSafeEntities_TwoEntitiesNotNSManagedObject_ObjectWithIDIsNotCalled")
        let context = DummyStorageContext()
        
        sut.getThreadSafeEntities(for: context, originalContext: DummyStorageContext(), originalEntities: [DummyStorageEntity(), DummyStorageEntity()]) { result in
            
            XCTAssertEqual(result.count, 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_GetThreadSafeEntities_TwoEntitiesNotNSManagedObject_ObjectWithIDIsNotCalled() {
        let expectation = self.expectation(description: "GetThreadSafeEntities_TwoEntitiesNotNSManagedObject_ObjectWithIDIsNotCalled")
        let context = StubManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        sut.getThreadSafeEntities(for: context, originalContext: DummyStorageContext(), originalEntities: [DummyStorageEntity(), DummyStorageEntity()]) { _ in
            
            XCTAssertEqual(context.objectWithIDCallsCount, 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_GetThreadSafeEntities_TwoNSManagedObjects_ObjectWithIDIsCalled() {
        let expectation = self.expectation(description: "GetThreadSafeEntities_TwoNSManagedObjects_ObjectWithIDIsCalled")
        let context = StubManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        sut.getThreadSafeEntities(for: context, originalContext: DummyStorageContext(), originalEntities: [FakeManagedObject(), FakeManagedObject()]) { _ in
            
            XCTAssertEqual(context.objectWithIDCallsCount, 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
	}

	func test_GetThreadSafeEntities_TwoNSManagedObjects_ObjectWithIDIsCalledWithRightArguments() {
		let entity = FakeManagedObject()
		entity.uri = URL(string: "google.com")!
		let entity2 = FakeManagedObject()
		entity2.uri = URL(string: "apple.com")!

        let expectation = self.expectation(description: "GetThreadSafeEntities_TwoNSManagedObjects_ObjectWithIDIsCalled")
        let context = StubManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        sut.getThreadSafeEntities(for: context, originalContext: DummyStorageContext(), originalEntities: [entity, entity2]) { _ in
            
            XCTAssertNotEqual(entity.objectID.uriRepresentation().absoluteString, entity2.objectID.uriRepresentation().absoluteString)
            
            XCTAssertEqual(context.objectWithIDArguments?.first?.uriRepresentation().absoluteString ?? "", "google.com")
            XCTAssertEqual(context.objectWithIDArguments?[1].uriRepresentation().absoluteString ?? "", "apple.com")

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
	}
}

// MARK: - contextDidSave(context:)
extension CoreDataStorageTests {
    func test_ContextDidSave_ContextWithMainAsParent_CallsMainContextSave() {
        guard let mainContext = sut.mainContext as? SpyManagedObjectContext else {
            XCTFail()
            return
        }
        let context = SpyManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.contextParent = mainContext
        
        sut.contextDidSave(context: context)
        
        XCTAssertTrue(mainContext.isSaveCalled)
    }
    
    func test_ContextDidSave_ContextWithoutMainAsParent_DoesNotCallContextSave() {
        guard let mainContext = sut.mainContext as? SpyManagedObjectContext else {
            XCTFail()
            return
        }
        let context = SpyManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        sut.contextDidSave(context: context)
        
        XCTAssertFalse(mainContext.isSaveCalled)
    }
}
