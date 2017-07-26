//
//  SpyRealm.swift
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

import Realm
import RealmSwift

final class SpyRealm {

	fileprivate(set) var isInitCalled = false
	fileprivate(set) var initConfigurationArgument: Realm.Configuration?

	fileprivate(set) var isWriteCalled = false

	fileprivate(set) var deleteCallsCount = 0
	fileprivate(set) var deleteObjectArguments: [Object]?

	fileprivate(set) var isObjectsCalled = false
	fileprivate(set) var objectsTypeArgument: Any?

	fileprivate(set) var addCallsCount = 0
	fileprivate(set) var addObjectArguments: [Object]?
	fileprivate(set) var addUpdatesArguments: [Bool]?

	var isInWriteTransaction = false

	let forcedResult = SpyRealmResult()

	init(configuration: Realm.Configuration) throws {
		deleteObjectArguments = []
		addObjectArguments = []
		addUpdatesArguments = []

		isInitCalled = true
		initConfigurationArgument = configuration
	}
}

extension SpyRealm: RealmType {

	func write(_ block: (() throws -> Void)) throws {
		isWriteCalled = true

		try block()
	}

	func add(_ object: Object, update: Bool) {
		addCallsCount += 1
		addObjectArguments?.append(object)
		addUpdatesArguments?.append(update)
	}

	func objects<T>(type: T.Type) -> RealmResultType {
		isObjectsCalled = true
		objectsTypeArgument = type
		
		return forcedResult
	}

	func delete(_ object: Object) {
		deleteCallsCount += 1

		deleteObjectArguments?.append(object)
	}

	func resolve<Confined>(_ reference: ThreadSafeReference<Confined>) -> Confined? {

		return nil
	}
}
