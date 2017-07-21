//
//  NSManagedObjectContextManagedObjectContextTypeTests.swift
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
class NSManagedObjectContextManagedObjectContextTypeTests: XCTestCase {}

// MARK: - contextParent
extension NSManagedObjectContextManagedObjectContextTypeTests {
    func test_ContextParent_SetNotNSManagedObjectContext_ReturnsNil() {
        let mainMoc = SpyManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let sut = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        sut.contextParent = mainMoc
        
        XCTAssertNil(sut.parent)
        XCTAssertNil(sut.contextParent)
    }
    
    func test_ContextParent_SetNSManagedObjectContext_ReturnsParent() {
        let mainMoc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let sut = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        sut.contextParent = mainMoc
        
        XCTAssertTrue(sut.parent === mainMoc)
        XCTAssertTrue(sut.parent === sut.contextParent)
    }
}

// MARK: - persistentStoreCoordinatorType
extension NSManagedObjectContextManagedObjectContextTypeTests {
    func test_PersistentStoreCoordinatorType_SetNotNSPersistentStoreCoordinator_ReturnsNil() {
        let sut = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        sut.persistentStoreCoordinatorType = SpyPersistentStoreCoordinator()
        
        XCTAssertNil(sut.persistentStoreCoordinator)
        XCTAssertNil(sut.persistentStoreCoordinatorType)
    }
}
