//
//  Storage.swift
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

/// Typealias which defines a context. It's the union of StorageIdentifiableContext, StorageReadableContext, StorageWritableContext, StorageUpdatableContext and StorageDeletableContext.
public typealias StorageContext = StorageIdentifiableContext & StorageReadableContext & StorageWritableContext & StorageUpdatableContext & StorageDeletableContext

/**
    Typealias which the closure type of `performBackgroundTask`.

    - Parameter closure: Context to use inside the closure. It can be nil because of internal errors.
*/
public typealias TaskClosure = (_ closure: StorageContext?) -> Void

// This protocol is the base Storage type. By default `NSManagedObectContext` (CoreData) and `Realm` (Realm) implement this protocol.
public protocol Storage: class {
    /// Main context of the storage. It works in the main queue. Do not use it in a background queue. If you need to use a context in a backgroun queue, you must use the method `performBackgroundTask`
    var mainContext: StorageContext? { get }

    /**
        Use this method to perform any context action in a background queue.
        You should use a background queue as much as possible instead of using a main queue to improve the user experience.
        Every time you call this method, you will have a different context.
     
        - Parameter taskClosure: Closure which has as parameters the a new context to work in background.
    */
    func performBackgroundTask(_ taskClosure: @escaping TaskClosure)
    
    /**
        Use this method to pass entities through different queues. `StorageEntityType` is not thread safe, this means that, if you create/fetch some entities in a queue, then you cannot you those entities in another queue.
        To pass the entities in another queue you must use this method, which create an array of new entities queue-safe for the destination context queue.
     
        Example:
     
        ```
        context.getThreadSafeEntities(for: mainContext, originalContext: bgContext, originalEntities: entities) { (safeEntities: [MyEntities]) in
        }
        ```
     
        **Note**
     
        Since the completion closure parameter is a generic array of entities, you must explicitly add the type of array elements. As you can see in the example above we specified: `safeEntities: [MyEntities]`
     
        - Parameter destinationContext: The context where you would want to use the entities.
        - Parameter originalContext: The context where the original entities come from.
        - Parameter originalEntities: The original entities which you would want to use in the destinationContext's queue.
        - Parameter completion: This closure is called once the new queue-safe entities are made. You can find the new entities in the closure parameter.
        - Throws: StorageKitErrors.Entity.wrongType
        - Throws: StorageKitErrors.Context.wrongType
    */
    func getThreadSafeEntities<T: StorageEntityType>(for destinationContext: StorageContext, originalContext: StorageContext, originalEntities: [T], completion: @escaping ([T]) -> Void) throws
}
