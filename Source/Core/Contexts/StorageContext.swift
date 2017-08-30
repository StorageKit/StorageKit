//
//  StorageContext.swift
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

struct AssociatedKeys {
    static var identifier: UInt8 = 0
}

/// This protocol provides an identifier for the context.
public protocol StorageIdentifiableContext: class {
    
    /// Context identifier. By default it's an unique UUID string by default implemented in a protocol extension.
    var identifier: String { get }
}

extension StorageIdentifiableContext {
    private(set) var _identifier: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.identifier) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.identifier, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var identifier: String {
        guard let identifier = _identifier else {
            let uuid = UUID().uuidString
            _identifier = uuid
            return uuid
        }

        return identifier
    }
}

/// This protocol adds the functionality to create and add entities in the database.
public protocol StorageWritableContext: class {
    
    /**
        Use this method to create a new entity.

        Example:
        ```
        do {
            try let entity: MyEntity = context.create()
        } catch {}
        ```
        **Note:** 

        Since the return value of this method is a generic, you must specify the entity type
        to let the compiler infer the type. As you can see in the example above, you must add an explicit
        type for the variable `entity`

        - Returns: The entity created.
        - Throws: The error depends on database used (CoreData and Realm).
    */
    func create<T: StorageEntityType>() throws -> T?
    
    /**
        Use this method to add a entity in the database.

        Example:
        ```
        do {
            try let entity: MyEntity = context.create()
            entity.myProperty = "Hello"
            
            try context.add(entity)
        } catch {}
        ```

        - Parameter entity: Entity to add in the database.
        - Throws: The error depends on database used (CoreData and Realm).
    */
    func add<T: StorageEntityType>(_ entity: T) throws
    
    /**
        Use this method to add an array of entities in the database.

        Example:
        ```
        do {
            try let entity: MyEntity = context.create()
            entity.myProperty = "Hello"
            try let entity2: MyEntity = context.create()
            entity.myProperty = "Hello 2"
            try let entity3: MyEntity = context.create()
            entity.myProperty = "Hello 3"

            try context.add([entity, entity2, entity3])
        } catch {}
        ```

        - Parameter entities: Array of entities to add in the database.
        - Throws: The error depends on database used (CoreData and Realm).
    */
    
    func add<T: StorageEntityType>(_ entities: [T]) throws
}

/// This protocol adds the functionality to fetch entities from the database.
public protocol StorageReadableContext: class {
    typealias FetchCompletionClosure<T> = ([T]?) -> Void
    
    /**
        Use this method to fetch entities from the database.
        You can also specify a predicate to filter the entity to fetch and an array of sort descriptors to order the result.
        By default, `predicate` and `sortDescriptors` are `nil`

        Example:
        ```
        context.fetch { (result: [MyEntity]?) in
     
        }
        ```
        **Note:**

        Since the return is a generic optional array, you must add the type of entities which you want to fetch explicitly. As you can see in the example above, we have specified the type `[MyEntity]?` as result type. Remember to use `?` since it may be an optional array.
     
        - Parameter predicate: `NSPredicate` object to filter the entity to fetch. Pass `nil` if you don't want any filter applied.
        - Parameter transform: Array of `SortDescriptor` to order the result. Pass `nil` if you don't want any order applied.
        - Parameter completion: Closure which contains the entity fetched. It has as parameter an optional array which contains the fetch result.
    */

    func fetch<T: StorageEntityType>(predicate: NSPredicate?, sortDescriptors: [SortDescriptor]?, completion: @escaping FetchCompletionClosure<T>) throws
}

public extension StorageReadableContext {
    func fetch<T: StorageEntityType>(predicate: NSPredicate? = nil, sortDescriptors: [SortDescriptor]? = nil, completion: @escaping FetchCompletionClosure<T>) throws {
        fatalError("fetch method not implemented")
    }
}

/// This protocol adds the functionality to update entities in the database.
public protocol StorageUpdatableContext: class {
    
    /**
        Use this method to update entities in the database.
        You can update the entity data inside the closure to allow StorageKit to keep the persistence of these changes.

        Example:
        ```
        do {
            try context.update {
                entity.myProperty = "Hello"
                entity2.myProperty = "Hello 2"
            }
        } catch {}
        ```
        
        **Note:**
        
        Realm: This method doesn't have any effects if used with entities not added in the database with the method `add`
     
        - Parameter transform: Closure which must contain your implementation to update the entity data.
        - Throws: The error depends on database used (CoreData and Realm).
    */
    func update(transform: @escaping () -> Void) throws
}

/// This protocol adds the functionality to delete entities from the database.
public protocol StorageDeletableContext: class {
    
    /**
        Use this method to remove an entity from the database.

        Example:
        ```
        do {
            try let entity: MyEntity = context.create()
            entity.myProperty = "Hello"

            try context.delete(entity)
        } catch {}
        ```

        - Parameter entity: Entity to remove from the database.
        - Throws: The error depends on database used (CoreData and Realm).
    */
    func delete<T: StorageEntityType>(_ entity: T) throws
    
    /**
        Use this method to remove an array of entities from the database.

        Example:
        ```
        do {
            try let entity: MyEntity = context.create()
            entity.myProperty = "Hello"
            try let entity2: MyEntity = context.create()
            entity.myProperty = "Hello 2"
            try let entity3: MyEntity = context.create()
            entity.myProperty = "Hello 3"

            try context.delete([entity, entity2, entity3])
        } catch {}
        ```

        - Parameter entities: Array of entities to remove from the database.
        - Throws: The error depends on database used (CoreData and Realm).
    */
    func delete<T: StorageEntityType>(_ entities: [T]) throws
    
    /**
        Use this method to remove all the entities of a specific type from the database.

        Example:
        ```
        do {
            try context.delete(MyEntity.self)
        } catch {}
        ```

        - Parameter entityType: Type of entity to remove from the database.
        - Throws: The error depends on database used (CoreData and Realm).
    */
    func deleteAll<T: StorageEntityType>(_ entityType: T.Type) throws
}
