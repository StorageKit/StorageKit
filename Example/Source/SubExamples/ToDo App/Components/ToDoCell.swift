//
//  ToDoCell.swift
//  Example
//
//  Created by Ennio Masi on 24/07/2017.
//  Copyright © 2017 MarcoSantaDev. All rights reserved.
//

import UIKit

import Foundation

class ToDoCell: UITableViewCell {

    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskAddedLabel: UILabel!
    
    private let dateFormatter = DateFormatter()

    public var task: Task? {
        didSet {
            self.taskNameLabel.text = task?.name ?? "Task without name"
            
            DispatchQueue.main.async {
                if let added = self.task?.added {
                    self.taskAddedLabel.text = self.dateFormatter.string(from: added as Date)
                } else {
                    self.taskAddedLabel.text = "No task date"
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        dateFormatter.dateFormat = "yyyy'/'MM'/'dd' 'HH':'mm'"
    }
}
