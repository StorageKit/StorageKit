//
//  StubManagedObjectContext.swift
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

final class StubManagedObjectContext: NSManagedObjectContext {
    
    private(set) var isExecuteCalled = false
    private(set) var isSaveCalled = false

	private(set) var deleteCallsCount = 0
	private(set) var objectWithIDCallsCount = 0

    private(set) var executeRequestArgument: NSAsynchronousFetchRequest<NSFetchRequestResult>?
	private(set) var deleteRequestArguments: [NSManagedObject]?
	private(set) var objectWithIDArguments: [NSManagedObjectID]?

    var forcedHasChanges = false
    
    override var hasChanges: Bool {
        return forcedHasChanges
    }
    
    override func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
        isExecuteCalled = true
        executeRequestArgument = request as? NSAsynchronousFetchRequest<NSFetchRequestResult>
        
        return NSPersistentStoreResult()
    }

    override func delete(_ object: NSManagedObject) {
        deleteCallsCount += 1
        
        if deleteRequestArguments == nil {
            deleteRequestArguments = []
        }
        deleteRequestArguments?.append(object)
    }
    
    override func save() throws {
        isSaveCalled = true
    }

	override func object(with objectID: NSManagedObjectID) -> NSManagedObject {
		objectWithIDCallsCount += 1

		if objectWithIDArguments == nil {
			objectWithIDArguments = []
		}
		objectWithIDArguments?.append(objectID)

		return NSManagedObject()
	}
}
