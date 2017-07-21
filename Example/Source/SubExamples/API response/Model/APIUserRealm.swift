//
//  APIUserRealm.swift
//  Example
//
//  Created by Marco Santarossa on 16/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import Foundation
import RealmSwift

final class APIUserRealm: Object {
	dynamic var username: String?
	dynamic var fullname: String?
}
