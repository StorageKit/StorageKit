//
//  SpyContextRepo.swift
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

final class SpyContextRepo {
	fileprivate(set) static var isInitCalled = false
	fileprivate(set) static var initCleaningIntervalArgumet: Double?

	fileprivate(set) static var isStoreCalled = false
	fileprivate(set) static var storeContextArgumet: StorageContext?
	fileprivate(set) static var storeQueueArgumet: DispatchQueue?

	fileprivate(set) static var isRetrieveQueueCalled = false
	fileprivate(set) static var retrieveQueueContextArgumet: StorageContext?

	init(cleaningTimerInterval: Double?) {
		SpyContextRepo.isInitCalled = true
		SpyContextRepo.initCleaningIntervalArgumet = cleaningTimerInterval
	}

	static func clean() {
		isInitCalled = false
		initCleaningIntervalArgumet = nil

		isStoreCalled = false
		storeContextArgumet = nil
		storeQueueArgumet = nil

		isRetrieveQueueCalled = false
		retrieveQueueContextArgumet = nil
	}
}

extension SpyContextRepo: ContextRepoType {
	func store(context: StorageContext?, queue: DispatchQueue) {
		SpyContextRepo.isStoreCalled = true
		SpyContextRepo.storeContextArgumet = context
		SpyContextRepo.storeQueueArgumet = queue
	}

	func retrieveQueue(for context: StorageContext) -> DispatchQueue? {
		SpyContextRepo.isRetrieveQueueCalled = true
		SpyContextRepo.retrieveQueueContextArgumet = context

		return DispatchQueue(label: "com.StorageKit.realmDataStorage")
	}
}
