//
//  SelectionTableScene.swift
//  FoodDiary
//
//  Created by Roman Rezinkin on 2019-11-27.
//  Copyright © 2019 SICT. All rights reserved.
//

import UIKit

protocol SelectItemDelegate: class {
    func selectTaskDidCancel(_ controller: UIViewController)
    func selectTaskDidSelect(_ controller: UIViewController, didSelect item: Food)
}
@available(iOS 12.0, *)

class SelectionTableScene: UITableViewController {
    weak var delegate: SelectItemDelegate?
    var m: FoodDMM!
    var foods = [Food]()
    var detail: FoodDetails!
    var brandName: String = ""
    var itemDesc: String = ""
    override func viewDidLoad() {
        let alert = UIAlertController(title: "Alert!", message: "Found no Results!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) in
            self.delegate?.selectTaskDidCancel(self)
        }))
        super.viewDidLoad()
        m.foodSearchGetAll(gsi: itemDesc, bo: brandName)
        NotificationCenter.default.addObserver(forName: Notification.Name("FoodSearchGetAll"), object: nil, queue: OperationQueue.main, using: { notification in
            self.foods = self.m.foodSearchFood
            self.tableView.reloadData()
            if (self.foods.count == 0) {
                self.present(alert, animated: true, completion: nil)
                return
            }
        })
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        delegate?.selectTaskDidCancel(self)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return foods.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
        cell.textLabel?.text = foods[indexPath.row].foodDescription
        cell.detailTextLabel?.text = foods[indexPath.row].brandOwner
        // Configure the cell...
        return cell
    }
    
    // Responds to a row selection event
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Work with the selected item
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            // Show a check mark
            selectedCell.accessoryType = .checkmark
            // Fetch the data for the selected item
            let data = foods[indexPath.row]
            m.foodDetailGetAll(someId: "\(data.fdcID)")
            NotificationCenter.default.addObserver(forName: Notification.Name("foodDetailGetAll"), object: nil, queue: OperationQueue.main, using: { notification in
                self.detail = self.m.foodDetailsFood
                //self.nutrients = self.m.foodDetailsFood.labelNutrients
            })
            // Call back into the delegate
            delegate?.selectTaskDidSelect(self, didSelect: data)
        }
    }
}
