//
//  StorageKit.swift
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

/**
	Main class of the library `StorageKit`. It provides a static method to create a new `Storage` object.
	You don't need an istance of this class since has just a static method.
	This is a `final` class. It means that you cannot override it. You shouldn't need it.
*/
public final class StorageKit {

	/**
		Type of storage supported by StorageKit. You must use this enum to create a new `Storage` object
		with the method `addStorage(type:)`
	*/
	public enum StorageType {
		/**
			CoreData storage. It has as associated value the data model name.
			Example:

			```
			.CoreData("myDataModel")
			```
		*/
        case CoreData(dataModelName: String)

		/**
			Realm storage type
		*/
        case Realm
    }

	/**
		This method is the entry point of `StorageKit`. It allows you to create a new `Storage` object.
		The type of storage to create is specified as parameter of the method.
		Since it's a static method, you don't need an istance of `StorageKit`.

	
		Example:
	
		```
		let storage = StorageKit.addStorage(type: .Realm)
		```

		- Parameter type: Type of storage to create
		- Returns: `Storage` object
	*/
	public static func addStorage(type: StorageKit.StorageType) -> Storage {
        switch type {
        case .CoreData(let dataModelName):
            return createCoreDataStorage(for: dataModelName)
        case .Realm:
            return createRealmStorage()
        }
        
    }
    
}

// MARK: - Storage method factories
fileprivate extension StorageKit {
    static func createCoreDataStorage(for dataModelName: String) -> CoreDataStorage {
        var configuration = CoreDataConfiguration()
        configuration.dataModelName = dataModelName
        return CoreDataStorage(configuration: configuration)
    }
    
    static func createRealmStorage() -> RealmDataStorage {
        return RealmDataStorage()
    }
}
