//
//  APIResponseViewController.swift
//  Example
//
//  Created by Ennio Masi on 16/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import UIKit
import StorageKit

class APIResponseCoreDataViewController: UIViewController {

	private static let storageType = StorageKit.StorageType.CoreData(dataModelName: "Example")
	private let storage = StorageKit.addStorage(type: storageType)
    private var users: [APIUserCoreData]?
    private var tableViewController: APIResponseTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveNewUsers { [unowned self] in
            self.tableViewController?.reloadTable()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableViewSegue", let tableViewController = segue.destination as? APIResponseTableViewController {
			tableViewController.storageType = APIResponseCoreDataViewController.storageType
            tableViewController.storage = storage

			self.tableViewController = tableViewController
        }
    }
    
    private func saveNewUsers(completion: @escaping () -> Void) {
		let usersFetcher = UsersFetcher()
		usersFetcher.fetchUser { [unowned self] usersJSON in
			guard let usersJSON = usersJSON else { return }

			self.storage.performBackgroundTask { context in
				guard let context = context else { return }

				try? context.deleteAll(APIUserCoreData.self)

				let users: [APIUserCoreData] = usersJSON.flatMap { userJSON in
					do {
						guard let apiUser: APIUserCoreData = try context.create() else { return nil }
						apiUser.username = userJSON["username"] as? String
						apiUser.fullname = userJSON["fullname"] as? String
						return apiUser
					} catch { return nil }
				}

				try? context.addOrUpdate(users)

				DispatchQueue.main.async {
					completion()
				}
			}
		}
    }
}
