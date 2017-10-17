//
//  Realm+RealmType.swift
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

//  Cascade deletion implementation
//  Thanks to: https://gist.github.com/krodak/b47ea81b3ae25ca2f10c27476bed450c

import RealmSwift
import Realm

extension RealmType {
    func delete<Entity>(_ list: List<Entity>, cascading: Bool) {
        list.forEach { delete($0, cascading: cascading) }
    }

    func delete<Entity>(_ results: Results<Entity>, cascading: Bool) {
        results.forEach { delete($0, cascading: cascading) }
    }

    func delete<Entity: Object>(_ entity: Entity, cascading: Bool) {
        cascading == true ? cascadeDelete(entity): delete(entity)
    }
}

// MARK: - Cascade Delete
extension RealmType {
    fileprivate func cascadeDelete(_ entity: RLMObjectBase) {
        guard let entity = entity as? Object else { return }

        var deletableEntities = Set<RLMObjectBase>()
        deletableEntities.insert(entity)
        var deleteComplete = false
        while !deleteComplete { //}!deletableEntities.isEmpty {
            guard let element = deletableEntities.removeFirst() as? Object, !element.isInvalidated else { continue }

            deletableEntities = deletableEntities.union(self.retrieveCascadingElements(from: element))
            delete(element)
            
            deleteComplete = deletableEntities.isEmpty
        }
    }
    
    private func retrieveCascadingElements(from object: Object) -> Set<RLMObjectBase> {
        var retrievedObjects = Set<RLMObjectBase>()

        object.objectSchema.properties.lazy
            .flatMap { object.value(forKey: $0.name) }
            .forEach { value in
                if let entity = value as? RLMObjectBase {
                    retrievedObjects.insert(entity)
                } else if let list = value as? RealmSwift.ListBase {
                    for index in 0..<list._rlmArray.count {
                        retrievedObjects.insert(list._rlmArray.object(at: index))
                    }
                }
        }
        return retrievedObjects
    }
}
