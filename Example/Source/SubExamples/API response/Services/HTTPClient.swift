//
//  HTTPClient.swift
//  Example
//
//  Created by Marco Santarossa on 16/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import Foundation

final class HTTPClient {

	private let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)

	private var dataTask: URLSessionDataTask?

	func get(at url: URL, completionHandler: @escaping (Data) -> Void) {

		dataTask = session.dataTask(with: url) { (data, _, error) in
			if let error = error {
				print("Get error \(error)")
				return
			}

			guard let data = data else { return }

			completionHandler(data)
		}
		dataTask?.resume()
	}

	func cancel() {
		dataTask?.cancel()
	}
}
