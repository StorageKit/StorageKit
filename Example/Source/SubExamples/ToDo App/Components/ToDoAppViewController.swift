//
//  ToDoAppViewController.swift
//  Example
//
//  Created by Marco Santarossa on 16/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import UIKit
import StorageKit

class ToDoAppViewController: UIViewController {
    internal var storage: Storage?
    var storageType: StorageKit.StorageType?
    
    @IBOutlet weak var todoTV: UITableView!
    
    internal var tasks: [Task] = []
    internal var doneTasks: [Task] = []
    
    private let sortDescriptor = SortDescriptor(key: "added", ascending: false)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        customizeUI()
        fetchAndUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let type = storageType {
            storage = StorageKit.addStorage(type: type)
        }
    }
    
    func fetchToDoTasks(storage: Storage, context: StorageContext, storageType: StorageKit.StorageType, dispatchGroup: DispatchGroup) {

        dispatchGroup.enter()

        storage.performBackgroundTask {[weak self] bckContext in
            guard let strongSelf = self, let backgroundContext = bckContext else { return }

            switch storageType {
            case .CoreData:
                do {
                    try backgroundContext.fetch(predicate: NSPredicate(format: "done == false"), sortDescriptors: [strongSelf.sortDescriptor], completion: {[weak self] (fetchedTasks: [ToDoTask]?) in

                        guard self != nil else {
                            dispatchGroup.leave()
                            return
                        }

                        guard let fetchedTasks = fetchedTasks else { return }
                        do {
                            try storage.getThreadSafeEntities(for: context, originalContext: backgroundContext, originalEntities: fetchedTasks, completion: { safeFetchedTaks in

                                self?.tasks = safeFetchedTaks

                                DispatchQueue.main.async {
                                    dispatchGroup.leave()
                                }
                            })
                        } catch {}
                    })
                } catch {}
            case .Realm:
                do {
                    try backgroundContext.fetch(predicate: <#T##NSPredicate?#>, sortDescriptors: <#T##[SortDescriptor]?#>, completion: <#T##([StorageEntityType]?) -> Void#>)
                    
                    try backgroundContext.fetch(predicate: NSPredicate(format: "done == false"), sortDescriptors: [strongSelf.sortDescriptor], completion: {[weak self] (fetchedTasks: [RTodoTask]?) in

                        guard self != nil else {
                            dispatchGroup.leave()
                            return
                        }

                        guard let fetchedTasks = fetchedTasks else { return }
                        do {
                            try storage.getThreadSafeEntities(for: context, originalContext: backgroundContext, originalEntities: fetchedTasks, completion: { safeFetchedTaks in

                                self?.tasks = safeFetchedTaks

                                DispatchQueue.main.async {
                                    dispatchGroup.leave()
                                }
                            })
                        } catch {}
                    })
                } catch {}
            }
        }
    }
    
    func fetchDoneTasks(storage: Storage, context: StorageContext, storageType: StorageKit.StorageType, dispatchGroup: DispatchGroup) {

        dispatchGroup.enter()
        storage.performBackgroundTask {[weak self] bckContext in
            guard let strongSelf = self, let backgroundContext = bckContext else { return }
            
            switch storageType {
            case .CoreData:
                do {
                    try backgroundContext.fetch(predicate: NSPredicate(format: "done == true"), sortDescriptors: [strongSelf.sortDescriptor], completion: {[weak self] (fetchedTasks: [ToDoTask]?) in

                        guard self != nil else {
                            dispatchGroup.leave()
                            return
                        }

                        guard let fetchedTasks = fetchedTasks else { return }

                        do {
                            try storage.getThreadSafeEntities(for: context, originalContext: backgroundContext, originalEntities: fetchedTasks, completion: { safeFetchedTaks in

                                self?.doneTasks = safeFetchedTaks

                                DispatchQueue.main.async {
                                    dispatchGroup.leave()
                                }
                            })
                        } catch {}
                    })
                } catch {}
            case .Realm:
                do {
                    try backgroundContext.fetch(predicate: NSPredicate(format: "done == true"), sortDescriptors: [strongSelf.sortDescriptor], completion: {[weak self] (fetchedTasks: [RTodoTask]?) in

                        guard self != nil else {
                            dispatchGroup.leave()
                            return
                        }

                        guard let fetchedTasks = fetchedTasks else { return }

                        do {
                            try storage.getThreadSafeEntities(for: context, originalContext: backgroundContext, originalEntities: fetchedTasks, completion: { safeFetchedTaks in

                                self?.doneTasks = safeFetchedTaks

                                DispatchQueue.main.async {
                                    dispatchGroup.leave()
                                }
                            })
                        } catch {}
                    })
                } catch {}
            }
        }
    }

    func fetchAndUpdate() {
        if let storage = storage, let context = storage.mainContext, let storageType = storageType {
            let dispatchGroup = DispatchGroup()
            
            self.fetchToDoTasks(storage: storage, context: context, storageType: storageType, dispatchGroup: dispatchGroup)
            self.fetchDoneTasks(storage: storage, context: context, storageType: storageType, dispatchGroup: dispatchGroup)
            
            dispatchGroup.notify(queue: .main, execute: {
                self.todoTV.reloadData()
            })
        }
    }
    
    private func customizeUI() {
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ToDoAppViewController.navigateToAddView))
        self.navigationItem.setRightBarButton(addBtn, animated: false)
    }
    
    func navigateToAddView() {
        self.performSegue(withIdentifier: "goToAddTaskViewController", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? AddToDoViewController {
            controller.storage = self.storage
            controller.storageType = self.storageType
        }
    }
}

// MARK: - UITableViewDataSource
extension ToDoAppViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.tasks.count
        } else {
            return self.doneTasks.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "ToDo"
        } else if section == 1 {
            return "Done"
        }
        
        return ""
    }
}

// MARK: - UITableViewDelegate
extension ToDoAppViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? ToDoCell {
            if indexPath.section == 0 {
                cell.task = self.tasks[indexPath.row]
            } else {
                cell.task = self.doneTasks[indexPath.row]
            }
            
            return cell
        }
        
        return UITableViewCell()
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 { // ToDo Tasks
            let done = UITableViewRowAction(style: .normal, title: "Done") { _, index in
                
                if let storage = self.storage, let context = storage.mainContext, let storageType = self.storageType {
                    do {
                        
                        switch storageType {
                        case .CoreData:
                            guard let task = self.tasks[index.row] as? ToDoTask else { return }
                            
                            try context.update {
                                task.done = true
                            }
                            
                            self.fetchAndUpdate()
                        case .Realm:
                            guard let task = self.tasks[index.row] as? RTodoTask else { return }
                            
                            storage.performBackgroundTask { bckContext in
                                guard let backgroundContext = bckContext else { return }
                                do {
                                    try storage.getThreadSafeEntities(for: backgroundContext, originalContext: context, originalEntities: [task]) { safeTask in
                                        do {
                                            try backgroundContext.update {
                                                safeTask.first?.done = true
                                            }

                                            DispatchQueue.main.async {
                                                self.fetchAndUpdate()
                                            }
                                        } catch {}
                                    }
                                } catch {}
                            }
                        }
                    } catch {
                        
                    }
                }
            }
            done.backgroundColor = UIColor.darkGray
            
            return [done]
        } else if indexPath.section == 1 { // Done Tasks
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { _, index in
                
                if let storage = self.storage, let context = storage.mainContext, let storageType = self.storageType {
                    do {
                        switch storageType {
                        case .CoreData:
                            if let task = self.doneTasks[index.row] as? ToDoTask {
                                try context.delete(task)
                            }
                        case .Realm:
                            if let task = self.doneTasks[index.row] as? RTodoTask {
                                try context.delete(task)
                            }
                        }
                        
                        self.fetchAndUpdate()
                    } catch {
                        
                    }
                }
            }
            
            return [delete]
        }
        
        return []
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
