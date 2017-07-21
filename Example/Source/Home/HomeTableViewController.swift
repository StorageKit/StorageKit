//
//  HomeTableViewController.swift
//  Example
//
//  Created by Masi, Ennio (Senior iOS Developer) on 18/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import UIKit
import StorageKit

class HomeTableViewController: UITableViewController {

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let identifier = segue.identifier, let controller = segue.destination as? ToDoAppViewController {
            switch identifier {
            case "todo_coredata":
                controller.storageType = .CoreData(dataModelName: "Example")
            case "todo_realm":
                controller.storageType = StorageKit.StorageType.Realm
            default:
                print("Nothing to do")
            }
        }
    }

}
