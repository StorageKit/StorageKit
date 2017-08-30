//
//  APIResponseTableViewController.swift
//  Example
//
//  Created by Santarossa, Marco (iOS Developer) on 17/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import StorageKit
import UIKit

class APIResponseTableViewController: UITableViewController {

    weak var storage: Storage?
	var storageType: StorageKit.StorageType?

    private var apiUsers: [APIUser]?
    
    func reloadTable() {
        storage?.performBackgroundTask { [unowned self] context in
            guard let context = context, let storageType = self.storageType, let storage = self.storage, let mainContext = storage.mainContext else { return }

			let sort = SortDescriptor(key: "username", ascending: true)
			switch storageType {
			case .CoreData:
				context.fetch(sortDescriptors: [sort]) { [unowned self] (users: [APIUserCoreData]?) in
					guard let users = users else { return }

					storage.getThreadSafeEntities(for: mainContext, originalContext: context, originalEntities: users) { [unowned self] safeUsers in
						DispatchQueue.main.async {
							self.apiUsers = safeUsers
							self.tableView.reloadData()
						}
					}
				}
			case .Realm:
				context.fetch(sortDescriptors: [sort]) { [unowned self] (users: [APIUserRealm]?) in
					guard let users = users else { return }

					storage.getThreadSafeEntities(for: mainContext, originalContext: context, originalEntities: users) { [unowned self] safeUsers in
						DispatchQueue.main.async {
							self.apiUsers = safeUsers
							self.tableView.reloadData()
						}
					}
				}
			}
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiUsers?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if let user = apiUsers?[indexPath.row] {
            cell.textLabel?.text = user.username
            cell.detailTextLabel?.text = user.fullname
        }
        
        return cell
    }

}
