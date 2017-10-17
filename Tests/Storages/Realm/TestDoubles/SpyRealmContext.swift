//
//  SpyRealmContext.swift
//  StorageKit
//
//  Created by Marco Santarossa on 27/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

@testable import StorageKit

final class SpyRealmContext: RealmContextType {

	fileprivate(set) static var isInitCalled = false
	fileprivate(set) static var initRealmTypeArgument: RealmType.Type?

	var realm: RealmType = {
		//swiftlint:disable force_try
		return try! SpyRealm()
	}()

	init?(realmType: RealmType.Type = SpyRealm.self) {
		SpyRealmContext.isInitCalled = true
		SpyRealmContext.initRealmTypeArgument = realmType
	}

	static func clean() {
		isInitCalled = false
		initRealmTypeArgument = nil
	}
}

extension SpyRealmContext {
	func delete<T: StorageEntityType>(_ entity: T, cascading: Bool) throws {}
    func delete<T: StorageEntityType>(_ entities: [T], cascading: Bool) throws {}
	func deleteAll<T: StorageEntityType>(_ entityType: T.Type) throws {}
    func fetch<T: StorageEntityType>(completion: @escaping ([T]?) -> Void) throws {}
	func fetch<T: StorageEntityType>(predicate: NSPredicate?, sortDescriptors: [SortDescriptor]? , completion: @escaping FetchCompletionClosure<T>) {}
	func update(transform: @escaping () -> Void) throws {}
    func addOrUpdate<T: StorageEntityType>(_ entities: [T]) throws {}

    func addOrUpdate<T: StorageEntityType>(_ entity: T) throws {}

	func create<T: StorageEntityType>() -> T? {
		return nil
	}
}
