//
//  AddToDoViewController.swift
//  Example
//
//  Created by Ennio Masi on 16/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import UIKit
import StorageKit

class AddToDoViewController: UIViewController {
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    var storage: Storage?
    var storageType: StorageKit.StorageType?
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Add a new Task"
        
        self.updateUI(textPresent: false)
    }
    
    internal func updateUI(textPresent: Bool) {
        DispatchQueue.main.async {
            self.saveBtn.isEnabled = textPresent
            
            if textPresent {
                self.saveBtn.alpha = 1
            } else {
                self.saveBtn.alpha = 0.5
            }
        }
    }
    
    @IBAction func save() {
        guard let storage = self.storage, let storageType = self.storageType else { return }

        storage.performBackgroundTask({ [unowned self] (bckcontext, _) in
            guard let backgroundContext = bckcontext else { return }
            
            do {
                switch storageType {
                case .CoreData:
                    let todoTask: ToDoTask? = try backgroundContext.create()
                    
                    if let task = todoTask, let name = self.taskNameTextField.text {
                        task.name = name
                        task.added = NSDate()
                        try backgroundContext.add(task)
                    }
                case .Realm:
                    let todoTask: RTodoTask? = try backgroundContext.create()
                    
                    if let task = todoTask, let name = self.taskNameTextField.text {
                        task.name = name
                        task.added = NSDate()
                        try backgroundContext.add(task)
                    }
                }
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
}

extension AddToDoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let composedText = textFieldText.replacingCharacters(in: range, with: string)
        
        updateUI(textPresent: composedText.characters.count > 0)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
