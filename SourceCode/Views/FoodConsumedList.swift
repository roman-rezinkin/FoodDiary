//
//  ExampleList.swift
//  Purpose - Shows content for a collection, in a table view
//  This is a table view controller
//  Can be used anywhere in the navigation workflow (start, mid, end)
//

import UIKit
import CoreData
@available(iOS 12.0, *)

class FoodConsumedList: ListBaseCD, AddFoodConsumedDelegate {
    
    // MARK: - Private internal instance variables
    private var frc: NSFetchedResultsController<FoodConsumed>!
    
    // MARK: - Public properties (instance variables)
    var m: FoodDMM!
    var items: [FoodConsumed]!
    var theMeal: Meal!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        frc = m.ds_frcForEntityNamed("FoodConsumed", withPredicateFormat: "meal == %@", predicateObject: [theMeal], sortDescriptors: [NSSortDescriptor(key: "brandOwner", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))], andSectionNameKeyPath: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch let error  {
            print(error.localizedDescription)
        }
        title = "Food Consumed"
    }
    
    // MARK: - Actions (user interface)
    // Disable the right bar button (the + "Add" button) during table edits
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Must call super, then set the right bar button state
        super.setEditing(editing, animated: animated)
        navigationItem.rightBarButtonItem?.isEnabled = !isEditing
    }
    
    // MARK: - Table view building
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.frc.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.frc.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
        let item = frc.object(at: indexPath)
        cell.textLabel!.text = item.descr!
        cell.detailTextLabel?.text = "Consumed \(item.quantity) grams"
        if let photo = item.photo {
            cell.imageView?.image = UIImage(data: photo)
        } else {
            cell.imageView?.image = UIImage(named: "placeholder.png")
        }
        return cell
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let item = frc.object(at: indexPath)
            m.foodC_DeleteItem(item: item)
        }
    }
    
    func addTaskDidCancel(_ controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addTaskDidSave(_ controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFoodConsumedScene" {
            let vc = segue.destination as! FoodConsumedScene
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            let selectedData = frc.object(at: indexPath!)
            vc.m = m
            vc.item = selectedData
        }
        if segue.identifier == "toAddFoodConsumed" {
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers[0] as! FoodConsumedAddScene
            vc.m = m
            vc.delegate = self
            vc.theMeal = theMeal
        }
    }
}

