//
//  CoreDataStorage.swift
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

import CoreData

struct CoreDataConfiguration {
    var storeType = CoreDataStorage.StoreType.sql
    var dataModelName = "StorageKit"
    var bundle = Bundle.main
    var ManagedObjectModelType: ManagedObjectModelType.Type = NSManagedObjectModel.self
    var PersistentStoreCoordinatorType: PersistentStoreCoordinatorType.Type = PersistentStoreCoordinator.self
    var ManagedObjectContext: ManagedObjectContextType.Type = NSManagedObjectContext.self
}

final class CoreDataStorage {
    
    enum StoreType {
        case sql
        case memory
        
        var rawValue: String {
            switch self {
            case .sql:
                return NSSQLiteStoreType
            case .memory:
                return NSInMemoryStoreType
            }
        }
    }
    
    var mainContext: StorageContext? {
        return mainManagedObjectContext
    }
    
    fileprivate(set) var mainManagedObjectContext: ManagedObjectContextType
    fileprivate let backgroundTaskQueue = DispatchQueue(label: "com.StorageKit.coreDataStorage")
    fileprivate let configuration: CoreDataConfiguration
    fileprivate let coreDataObserver: CoreDataObserver
    
    init(configuration: CoreDataConfiguration = CoreDataConfiguration()) {
        self.configuration = configuration
        
        let managedObjectModel = CoreDataStorage.makeManagedObjectModel(for: configuration)
        let persistentStoreCoordinator = CoreDataStorage.makePersistentStoreCoordinator(managedObjectModel: managedObjectModel, configuration: configuration)
        mainManagedObjectContext = configuration.ManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        mainManagedObjectContext.persistentStoreCoordinatorType = persistentStoreCoordinator
        
        coreDataObserver = CoreDataObserver()
        coreDataObserver.delegate = self
    }
    
    private static func makeManagedObjectModel(for configuration: CoreDataConfiguration) -> ManagedObjectModelType {
        guard let modelURL = configuration.bundle.url(forResource: configuration.dataModelName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        guard let managedObjectModel = configuration.ManagedObjectModelType.init(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        return managedObjectModel
    }
    
    private static func makePersistentStoreCoordinator(managedObjectModel: ManagedObjectModelType, configuration: CoreDataConfiguration) -> PersistentStoreCoordinatorType {
        let persistentStoreCoordinator = configuration.PersistentStoreCoordinatorType.init(managedObjectModel: managedObjectModel)
        
        do {
            let storeURL = self.storeURL(configuration: configuration)
            try persistentStoreCoordinator.addPersistentStore(ofType: configuration.storeType.rawValue, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        return persistentStoreCoordinator
    }
    
    private static func storeURL(configuration: CoreDataConfiguration) -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        return docURL.appendingPathComponent("\(configuration.dataModelName).sqlite")
    }
}

// MARK: - StorageType
extension CoreDataStorage: Storage {
    private func makePrivateContext() -> StorageContext {
        let ManagedObjectContextType = self.configuration.ManagedObjectContext
        let moc = ManagedObjectContextType.init(concurrencyType: .privateQueueConcurrencyType)
        moc.contextParent = self.mainManagedObjectContext
        return moc
    }

    func performBackgroundTask(_ taskClosure: @escaping TaskClosure) {
        let context = makePrivateContext()

        backgroundTaskQueue.async { [unowned self] in
            taskClosure(context, self.backgroundTaskQueue)
        }
    }
    
    func getThreadSafeEntities<T: StorageEntityType>(for destinationContext: StorageContext, originalContext: StorageContext, originalEntities: [T], completion: @escaping ([T]) -> Void) {
        guard let destinationContext = destinationContext as? NSManagedObjectContext else {
            // TODO: Add an error
            completion([])
            return
        }
        
        let threadSafeEntities: [T] = originalEntities.lazy
            .flatMap { $0 as? NSManagedObject }
            .flatMap { $0.objectID }
            .flatMap { destinationContext.object(with: $0) }
            .flatMap { $0 as? T }
        
        completion(threadSafeEntities)
    }
}

// MARK: - CoreDataObserverDelegate
extension CoreDataStorage: CoreDataObserverDelegate {
    func contextDidSave(context: ManagedObjectContextType) {
        if context.contextParent === mainManagedObjectContext {
            do {
                try mainManagedObjectContext.save()
            } catch {
                
            }
        }
    }
}
