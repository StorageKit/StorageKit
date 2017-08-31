//
//  RealmContext+StorageContext.swift
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

import RealmSwift

// MARK: - StorageDeletableContext
extension RealmContext {
    func delete<T: StorageEntityType>(_ entity: T) throws {
        try delete([entity])
    }

    func delete<T: StorageEntityType>(_ entities: [T]) throws {
        guard entities is [Object] else {
            throw StorageKitErrors.Entity.wrongType
        }

		try self.safeWriteAction {

            entities.lazy
                .flatMap { return $0 as? Object }
                .forEach { realm.delete($0) }
        }
    }
    
    func deleteAll<T: StorageEntityType>(_ entityType: T.Type) throws {
        guard let entityToDelete = entityType as? Object.Type else {
            throw StorageKitErrors.Entity.wrongType
        }
        
        try self.safeWriteAction {
            let objects = realm.objects(type: entityToDelete)

			objects.toArray.forEach {
				realm.delete($0)
			}
        }
    }
}

// MARK: - StorageWritableContext
extension RealmContext {
    func create<T: StorageEntityType>() throws -> T? {
        guard let entityToCreate = T.self as? Object.Type else {
            throw StorageKitErrors.Entity.wrongType
        }
        
        return entityToCreate.init() as? T
    }

    func addOrUpdate<T: StorageEntityType>(_ entity: T) throws {
        guard entity is Object else {
            throw StorageKitErrors.Entity.wrongType
        }

        try addOrUpdate([entity])
    }
    
    func addOrUpdate<T: StorageEntityType>(_ entities: [T]) throws {
        guard entities is [Object] else {
            throw StorageKitErrors.Entity.wrongType
        }

        try self.safeWriteAction {
            
            entities.lazy
                .flatMap { return $0 as? Object }
                .forEach {
                    let canUpdateIfExists = $0.objectSchema.primaryKeyProperty != nil
                    realm.add($0, update: canUpdateIfExists)
            }
        }
    }
}

// MARK: - StorageUpdatableContext
extension RealmContext {
    func update(transform: @escaping () -> Void) throws {
        try safeWriteAction {
            transform()
        }
    }
}

// MARK: - StorageReadableContext
extension RealmContext {
    func fetch<T>(completion: @escaping FetchCompletionClosure<T>) throws where T : StorageEntityType {
        return try fetch(predicate: nil, sortDescriptors: nil, completion: completion)
    }
    
    func fetch<T: StorageEntityType>(predicate: NSPredicate?, sortDescriptors: [SortDescriptor]?, completion: @escaping FetchCompletionClosure<T>) throws {

        guard let entityToFetch = T.self as? Object.Type else {
            throw StorageKitErrors.Entity.wrongType
        }
        
        var objects = realm.objects(type: entityToFetch)
        
        if let predicate = predicate {
            objects = objects.filter(predicate: predicate)
        }
        
        if let sortDescriptors = sortDescriptors {
            for sortDescriptor in sortDescriptors {
                objects = objects.sorted(keyPath: sortDescriptor.key, ascending: sortDescriptor.ascending)
            }
        }
        
        completion(objects.toArray.flatMap { $0 as? T })
    }
}
