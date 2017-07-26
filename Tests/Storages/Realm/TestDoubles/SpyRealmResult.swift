//
//  SpyRealmResult.swift
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

final class SpyRealmResult {
	var toArray = [Object]()

	fileprivate(set) var isFilterCalled = false
	fileprivate(set) var filterPredicateArgument: NSPredicate?

	fileprivate(set) var sortedCallsCount = 0
	fileprivate(set) var sortedKeyPathArguments = [String]()
	fileprivate(set) var sortedAscendingArguments = [Bool]()
}

extension SpyRealmResult: RealmResultType {

	func filter(predicate: NSPredicate) -> RealmResultType {
		isFilterCalled = true
		filterPredicateArgument = predicate
		return self
	}

	func sorted(keyPath: String, ascending: Bool) -> RealmResultType {
		sortedCallsCount += 1
		sortedKeyPathArguments.append(keyPath)
		sortedAscendingArguments.append(ascending)

		return self
	}
}
