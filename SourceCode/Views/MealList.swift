//
//  ExampleList.swift
//  Purpose - Shows content for a collection, in a table view
//  This is a table view controller
//  Can be used anywhere in the navigation workflow (start, mid, end)
//

// ############################################################
// R E P L A C E this controller
// It exists only to prove that this app will build and run successfully
// Your app's FIRST controller must replace this one
// Do the replacement in the app delegate and storyboard
// ############################################################

import UIKit
import CoreData

// Adopt the protocols that are appropriate for this controller
// For example... detail, add, edit, add+edit
@available(iOS 12.0, *)

class MealList: ListBaseCD, AddDelegate {
    // MARK: - Private internal instance variables
    
    // Configure the desired entity type in the frc
    //private var frc2: NSFetchedResultsController<Example>!
    private var frc: NSFetchedResultsController<Meal>!
    
    // MARK: - Public properties (instance variables)
    
    //var m2: DataModelManager!
    var m: FoodDMM!
    // Passed-in object, if necessary
    var meal: Meal!
    var sectionName: String!
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure nav items
        title = "Meals"
        // If desired, configure the table view edit capability
        navigationItem.leftBarButtonItem = editButtonItem
        // Configure the frc for the desired entity type, sort is case-insensitive
        frc = m.ds_frcForEntityNamed("Meal", withPredicateFormat: nil, predicateObject: nil, sortDescriptors: [NSSortDescriptor(key: "date", ascending: false), NSSortDescriptor(key: "name", ascending: true)], andSectionNameKeyPath: "sectionDate")
        //selector: #selector(NSString.caseInsensitiveCompare(_:)))
        // This controller will be the frc delegate
        frc.delegate = self;
        
        // Perform fetch, and if there's an error, log it
        do {
            try frc.performFetch()
        } catch let error {
            print(error.localizedDescription)
        }
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
    
    // What is the section title?
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Get a reference to the section object in the frc
        // And make sure there is a section name
        if let s = self.frc.sections?[section], s.name.count > 0 {
            return "Meal's Consumed on: \(s.name)"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.frc.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
        let item = frc.object(at: indexPath) 
        cell.textLabel!.text = item.name
        cell.detailTextLabel?.text = "Location is \(item.locName!)"
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
            m.meal_DeleteItem(item: item)
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
        if segue.identifier == "toMealScene" {
            let vc = segue.destination as! MealScene
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            let selectedData = frc.object(at: indexPath!)
            vc.item = selectedData
            vc.title = selectedData.name
            vc.m = m
        }
        if segue.identifier == "toMealAdd" {
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers[0] as! MealAddScene
            vc.m = m
            vc.delegate = self
        }
    }
}
extension Meal {
    @objc var sectionDate: String {
        get {
            // Create a date formatter object (e.g. "df")
            // Set its format to something you like
            let df = DateFormatter()
            df.dateFormat = "MM-dd-yyyy"
            return df.string(from: self.date!)
        }
    }
}
