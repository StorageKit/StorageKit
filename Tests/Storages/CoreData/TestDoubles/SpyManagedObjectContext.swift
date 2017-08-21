//
//  SpyManagedObjectContext.swift
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

final class SpyManagedObjectContext: ManagedObjectContextType {

    // MARK: Static spies
    static private(set) var isInitWithConcurrencyTypeCalled = false
    static private(set) var initWithConcurrencyTypeArgument: NSManagedObjectContextConcurrencyType?
    
    static private(set) var isPersistentStoreCoordinatorTypeSet = false
    static private(set) var persistentStoreCoordinatorTypeSetValue: PersistentStoreCoordinatorType?

    // MARK: Not-Static spies
    private(set) var isInitWithConcurrencyTypeCalled = false
    private(set) var initWithConcurrencyTypeArgument: NSManagedObjectContextConcurrencyType?
    
    private(set) var isContextParentSetCalled = false
    private(set) var contextParentSetArgument: ManagedObjectContextType?
	private(set) var isSaveCalled = false

	private(set) var isPerformCalled = false

    var persistentStoreCoordinatorType: PersistentStoreCoordinatorType? {
        get {
            return nil
        }
        set {
            SpyManagedObjectContext.isPersistentStoreCoordinatorTypeSet = true
            SpyManagedObjectContext.persistentStoreCoordinatorTypeSetValue = newValue
        }
    }
    
    var contextParent: ManagedObjectContextType? {
        get {
            return contextParentSetArgument
        }
        set {
            isContextParentSetCalled = true
            contextParentSetArgument = newValue
        }
    }
    
    required init(concurrencyType ct: NSManagedObjectContextConcurrencyType) {
        SpyManagedObjectContext.isInitWithConcurrencyTypeCalled = true
        SpyManagedObjectContext.initWithConcurrencyTypeArgument = ct
        
        isInitWithConcurrencyTypeCalled = true
        initWithConcurrencyTypeArgument = ct
    }
    
    static func clean() {
        SpyManagedObjectContext.isInitWithConcurrencyTypeCalled = false
        SpyManagedObjectContext.initWithConcurrencyTypeArgument = nil
        
        SpyManagedObjectContext.isPersistentStoreCoordinatorTypeSet = false
        SpyManagedObjectContext.persistentStoreCoordinatorTypeSetValue = nil
    }
    
    func save() throws {
        isSaveCalled = true
    }

	func perform(_ block: @escaping () -> Void) {
		isPerformCalled = true

		block()
	}
}

// MARK: - StorageContext
extension SpyManagedObjectContext {
    func delete<T: StorageEntityType>(_ entity: T) throws {}
    func delete<T: StorageEntityType>(_ entities: [T]) throws {}
    func deleteAll<T: StorageEntityType>(_ entityType: T.Type) throws {}
    
    func fetch<T: StorageEntityType>(predicate: NSPredicate?, sortDescriptors: [SortDescriptor]?, completion: @escaping FetchCompletionClosure<T>) {}

    func update(transform: @escaping () -> Void) throws {}
    
    func create<T: StorageEntityType>() -> T? { return nil }
    
    func add<T>(_ entity: T) throws { }
}
