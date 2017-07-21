//
//  APIUser.swift
//  Example
//
//  Created by Marco Santarossa on 16/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

protocol APIUser: class {
	var username: String? { get set }
	var fullname: String? { get set }
}

extension APIUserCoreData: APIUser {}
extension APIUserRealm: APIUser {}
