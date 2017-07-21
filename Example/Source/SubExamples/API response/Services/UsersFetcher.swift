//
//  UsersInteractor.swift
//  Example
//
//  Created by Marco Santarossa on 16/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import Foundation

final class UsersFetcher {

	private let httpClient = HTTPClient()

	func fetchUser(completion: @escaping ([[String: Any]]?) -> Void) {

		guard let url = URL(string: "http://www.mocky.io/v2/596e3fbd0f000062052b8129") else {
			completion(nil)
			return
		}

		httpClient.get(at: url) { data in
			let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
			let users = json?["users"] as? [[String: Any]]
			completion(users)
		}
	}
}
