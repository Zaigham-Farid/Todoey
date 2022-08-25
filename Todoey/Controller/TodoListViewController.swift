//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    
    var  selectedCategory: Catagory?{
        didSet{
            loadData()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    var Items = [Item]()
    //    let filedatapath = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadData()
        searchBar.delegate = self
        //        self.userDefaults.set(self.Items, forKey: "TodoListArray")
        //        if let items = userDefaults.array(forKey: "TodoListArray") as? [item]{
        //            Items = items
        //        }
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"MyCell",for: indexPath)
        let temp=Items[indexPath.row]
        cell.textLabel?.text = temp.name
        cell.accessoryType =  temp.done ? .checkmark : .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(Items[indexPath.row])
        let temp = Items[indexPath.row]
        Items[indexPath.row].done = !temp.done
        
        
        
        self.savedata()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action =  UIAlertAction(title: "Add Item", style: .default) { action in
            
            
            let temp = Item(context: self.context)
            
            temp.name = textField.text!
            temp.done = false
            temp.parantcatagory = self.selectedCategory
            self.Items.append(temp)
            self.savedata()
            
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func savedata()
    {
        
        //let encoder = PropertyListEncoder()
        
        do {
            //let data = try encoder.encode(self.Items)
            //try data.write(to: self.filedatapath! )
            try context.save()
        }catch{
            print("Error Encoding item Array, \(error)")
        }
        //self.userDefaults.set(self.Items, forKey: "TodoListArray")
        self.tableView.reloadData()
    }
    func loadData(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil ){
        //        if let data = try? Data(contentsOf: filedatapath!){
        //            let decoder = PropertyListDecoder()
        //            do {
        //                Items = try decoder.decode([item].self, from: data)
        //            }catch{
        //                print("Error in decoding data : \(error)")
        //            }
        //        }
        
        let categoryPredicate = NSPredicate(format: "parantcatagory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        
        do {
            
            Items = try context.fetch(request)
        }catch{
            
            print("Error While Fetching Data! : \(error)")
        }
        tableView.reloadData()
    }
    
}

extension ViewController:UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate  = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key:"name",ascending: true)]
        loadData(with: request ,predicate: predicate )
        
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}
