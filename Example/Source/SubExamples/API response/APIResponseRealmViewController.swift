//
//  APIResponseViewController.swift
//  Example
//
//  Created by Ennio Masi on 16/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import UIKit
import StorageKit

class APIResponseRealmViewController: UIViewController {

	private static let storageType = StorageKit.StorageType.Realm
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
			tableViewController.storageType = APIResponseRealmViewController.storageType
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
				let users: [APIUserRealm] = usersJSON.flatMap { userJSON in
					do {
						guard let apiUser: APIUserRealm = try context.create() else { return nil }
						apiUser.username = userJSON["username"] as? String
						apiUser.fullname = userJSON["fullname"] as? String
						return apiUser
					} catch { return nil }
				}

				do {
					try context.deleteAll(APIUserRealm.self)
					try context.addOrUpdate(users)
				} catch {
					print(error)
				}
				
				DispatchQueue.main.async {
					completion()
				}
			}
		}
    }
}
