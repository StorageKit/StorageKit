//
//  RealmContext.swift
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

protocol RealmContextType: StorageContext {
    var realm: RealmType { get }
	
    init?(realmType: RealmType.Type)
}

class RealmContext: StorageContext, RealmContextType {
    private(set) var realm: RealmType

    required init?(realmType: RealmType.Type = Realm.self) {
        do {
            try self.realm = realmType.init(configuration: Realm.Configuration.defaultConfiguration)
        } catch {
            return nil
        }
    }

    func safeWriteAction(_ block: (() throws -> Void)) throws {
        if realm.isInWriteTransaction {
            try block()
        } else {
            try realm.write(block)
        }
    
    }
    
    func resolve<Confined>(_ reference: ThreadSafeReference<Confined>) -> Confined? {
        return realm.resolve(reference)
    }
}
