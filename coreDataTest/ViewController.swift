//
//  ViewController.swift
//  coreDataTest
//
//  Created by Digital-02 on 9/23/19.
//  Copyright © 2019 Digital-02. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    var items: [NSManagedObject] = []
    let cellId = "cellid"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.gray
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addItem))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
        
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch let err as NSError {
            print("FAild to fetch items", err)
        }
        
    }

    @objc func addItem(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Add New Item", message: "Please fill in the textField below", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned alertController] _ in
            guard let textField = alertController.textFields?.first, let itemToAdd = textField.text else { return }
            self.save(itemToAdd)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func save(_ itemName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate  else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        item.setValue(itemName, forKey: "itemName")
        
        do {
            try managedContext.save()
            items.append(item)
        } catch let err as NSError {
            print("Faild to save an item", err)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.value(forKeyPath: "itemName") as? String
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = items[indexPath.row]
            guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(commit)
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    
}

