//
//  SpyPersistentStoreCoordinator.swift
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

import Foundation

final class SpyPersistentStoreCoordinator: PersistentStoreCoordinatorType {
    
    let model: ManagedObjectModelType
    
    static private(set) var isInitWithModelCalled = false
    static private(set) var initWithModelArgument: ManagedObjectModelType?
    
    static private(set) var isAddPersistentStoreCalled = false
    static private(set) var addPersistentStoreTypeArgument: String?
    static private(set) var addPersistentStoreConfigurationArgument: String?
    static private(set) var addPersistentStoreStoreUrlArgument: URL?
    static private(set) var addPersistentStoreOptionsArgument: [AnyHashable : Any]?
    
    init() {
        self.model = SpyManagedObjectModel(contentsOf: URL(string: "www.google.com")!)!
    }
    
    init(managedObjectModel model: ManagedObjectModelType) {
        self.model = model
        
        SpyPersistentStoreCoordinator.isInitWithModelCalled = true
        SpyPersistentStoreCoordinator.initWithModelArgument = model
    }
    
    @discardableResult
    func addPersistentStore(ofType storeType: String, configurationName configuration: String?, at storeURL: URL?, options: [AnyHashable : Any]?) throws -> PersistentStoreType {
        SpyPersistentStoreCoordinator.isAddPersistentStoreCalled = true
        SpyPersistentStoreCoordinator.addPersistentStoreTypeArgument = storeType
        SpyPersistentStoreCoordinator.addPersistentStoreConfigurationArgument = configuration
        SpyPersistentStoreCoordinator.addPersistentStoreStoreUrlArgument = storeURL
        SpyPersistentStoreCoordinator.addPersistentStoreOptionsArgument = options
        
        return DummyPersistentStore()
    }
    
    static func clean() {
        SpyPersistentStoreCoordinator.isInitWithModelCalled = false
        SpyPersistentStoreCoordinator.initWithModelArgument = nil
        
        SpyPersistentStoreCoordinator.isAddPersistentStoreCalled = false
        SpyPersistentStoreCoordinator.addPersistentStoreTypeArgument = nil
        SpyPersistentStoreCoordinator.addPersistentStoreConfigurationArgument = nil
        SpyPersistentStoreCoordinator.addPersistentStoreStoreUrlArgument = nil
        SpyPersistentStoreCoordinator.addPersistentStoreOptionsArgument = nil
    }
}
