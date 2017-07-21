//
//  NSEntityDescriptionEntityDescriptionTypeTests.swift
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
class NSEntityDescriptionEntityDescriptionTypeTests: XCTestCase {

    fileprivate var context: StorageWritableContext!
    
    override func setUp() {
        super.setUp()
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }
    
    override func tearDown() {
        context = nil
        
        SpyNSEntityDescription.clean()
    }
}

// MARK: - insertNewObject(forEntityName:, into:)
extension NSEntityDescriptionEntityDescriptionTypeTests {
    func test_InsertNewObject_InvalidManagedObjectContext_ThrowsFatalError() {
        expectFatalError(expectedMessage: "context is not NSManagedObjectContext") {
            _ = SpyNSEntityDescription.insertNewObject(forEntityName: "test", into: DummyStorageContext())
        }
        
    }
    
    func test_InsertNewObject_ValidManagedObjectContext_CallsSuper() {
        _ = SpyNSEntityDescription.insertNewObject(forEntityName: "test", into: context)
        
        XCTAssertTrue(SpyNSEntityDescription.isInsertNewObjectCalled)
    }
    
    func test_InsertNewObject_ValidManagedObjectContext_CallsSuperWithRightEntityName() {
        _ = SpyNSEntityDescription.insertNewObject(forEntityName: "test", into: context)
        
        XCTAssertEqual(SpyNSEntityDescription.insertNewObjectEntityNameArgument ?? "", "test")
    }
    
    func test_InsertNewObject_ValidManagedObjectContext_CallsSuperWithRightContext() {
        _ = SpyNSEntityDescription.insertNewObject(forEntityName: "test", into: context)
        
        XCTAssertTrue(SpyNSEntityDescription.insertNewObjectContextArgument === context)
    }
}
