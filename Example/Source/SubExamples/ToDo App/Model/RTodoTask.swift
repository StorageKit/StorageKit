//
//  RTodoTask.swift
//  Example
//
//  Created by Ennio Masi on 16/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import Foundation

import RealmSwift

protocol Task: class {
    var name: String? { get set }
    var done: Bool { get set }
    var added: NSDate? { get }
}

final class RTodoTask: Object {
    var taskID = UUID().uuidString
    dynamic var name: String?
    dynamic var done: Bool = false
    var added: NSDate?
    
    override static func primaryKey() -> String? {
        return "taskID"
    }
}

extension RTodoTask: Task {}
extension ToDoTask: Task {}
