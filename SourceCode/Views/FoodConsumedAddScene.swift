//
//  FoodConsumedAddScene.swift
//  FoodDiary
//
//  Created by Roman Rezinkin on 2019-11-26.
//  Copyright © 2019 SICT. All rights reserved.
//

import UIKit
import Network

// Add new Consumed Delegate Protocol
protocol AddFoodConsumedDelegate: class {
    func addTaskDidCancel(_ controller: UIViewController)
    func addTaskDidSave(_ controller: UIViewController)
}

@available(iOS 12.0, *)
class FoodConsumedAddScene: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, SelectItemDelegate {
    
    // MARK: Local Variables
    weak var delegate: AddFoodConsumedDelegate?
    var m: FoodDMM!
    var foodItem: Food!
    var foodDetail: FoodDetails!
    var theMeal: Meal!
    var nutrients: LabelNutrients!
    var localQuantity: Float = 0
    var isLoad: Bool = false
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    var isConnected: Bool = false;

    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var BrandOwnerTxtFieldOutlet: UITextField!
    @IBOutlet weak var ItemDescTextFieldOutlet: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var quantityStepper: UISegmentedControl!
    @IBOutlet weak var servingSizeLbl: UILabel!
    @IBOutlet weak var nutritionTxtView: UITextView!
    @IBOutlet weak var ingredientsTxtView: UITextView!
    
    // viewDidLoad Function
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add new Food Consumed"
        errorLbl.text = ""
        nutritionTxtView.text = ""
        ingredientsTxtView.text = ""
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Application is connected to Wifi!")
                self.isConnected = true;
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        // Do any additional setup after loading the view.
    }
    
    // Save Bar Button
    @IBAction func save(_ sender: UIBarButtonItem) {
        // get Quantity
        if (quantityStepper.selectedSegmentIndex == 0) {
            localQuantity = 25
        } else if (quantityStepper.selectedSegmentIndex == 1) {
            localQuantity = 50
        } else if (quantityStepper.selectedSegmentIndex == 2) {
            localQuantity = 100
        } else if (quantityStepper.selectedSegmentIndex == 3) {
            localQuantity = 125
        } else if (quantityStepper.selectedSegmentIndex == 4) {
            localQuantity = 250
        } else {
            localQuantity = 500
        }
        if (isLoad) {
            let cals: Float = m.foodDetailsFood.labelNutrients.calories?.value ?? 0
            let carbs: Float = m.foodDetailsFood.labelNutrients.carbohydrates?.value ?? 0
            let fat: Float = m.foodDetailsFood.labelNutrients.fat?.value ?? 0
            let protein: Float = m.foodDetailsFood.labelNutrients.protein?.value ?? 0
            let sodium: Float = m.foodDetailsFood.labelNutrients.sodium?.value ?? 0
            let servingSize: Float = m.foodDetailsFood?.servingSize ?? 0
            let newConsumedFood = FoodConsumed(context: m.ds_context)
            newConsumedFood.brandOwner = foodItem.brandOwner
            newConsumedFood.descr = foodItem.foodDescription
            newConsumedFood.fdcId = "\(foodItem.fdcID)"
            newConsumedFood.ncals = (localQuantity / servingSize) * (cals)
            newConsumedFood.ncarbs = (localQuantity / servingSize) * (carbs)
            newConsumedFood.nfat = (localQuantity / servingSize) * (fat)
            newConsumedFood.nprotein = (localQuantity / servingSize) * (protein)
            newConsumedFood.nsodium = (localQuantity / servingSize) * (sodium)
            newConsumedFood.quantity = Double(localQuantity)
            newConsumedFood.meal = theMeal
            newConsumedFood.photo = imageView.image!.pngData()
            m.ds_save()
        } else {
            // Add a Notification if its loaded or not
            print(isLoad)
        }
        delegate?.addTaskDidSave(self)
    }
    
    @IBAction func getPhoto(_ sender: UIButton) {
        // Create the image picker controller
        let c = UIImagePickerController()
        // Determine what we can use...
        // Prefer the camera, but can use the photo library
        c.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        c.delegate = self
        c.allowsEditing = false
        // Show the controller
        present(c, animated: true, completion: nil)
    }
    
    // Get or take photo task was cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Save the photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Attempt to get the image from the "info" object
        if let image = info[.originalImage] as? UIImage {
            // If successful, display it in the UI
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    // Cancel Bar Button"
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        delegate?.addTaskDidCancel(self)
    }
    
    // Search Button
    @IBAction func SearchBtn(_ sender: UIButton) {
        BrandOwnerTxtFieldOutlet.resignFirstResponder()
        ItemDescTextFieldOutlet.resignFirstResponder()
        if (ItemDescTextFieldOutlet.text!.isEmpty) {
            errorLbl.text = "Please Enter Item Description"
            return
        }
    }
    // Function that adapts selectionLists protocol
    func selectTaskDidCancel(_ controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Function that adapts selectionLists protocol
    func selectTaskDidSelect(_ controller: UIViewController, didSelect item: Food) {
        
        BrandOwnerTxtFieldOutlet.text = item.brandOwner
        ItemDescTextFieldOutlet.text = item.foodDescription

        foodItem = item
        
        NotificationCenter.default.addObserver(self, selector: #selector(didGetData), name: Notification.Name("foodDetailGetAll"), object: nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    // Method that runs when the notification happens
    @objc func didGetData() {
        foodDetail = m.foodDetailsFood
        servingSizeLbl.text! += "\(foodDetail.servingSize)"
        nutritionTxtView.text! = "Calories: \(foodDetail.labelNutrients.calories?.value ?? 0), Carbohydrates: \(foodDetail.labelNutrients.carbohydrates?.value ?? 0), Cholestrol: \(foodDetail.labelNutrients.cholesterol?.value ?? 0), Fat: \(foodDetail.labelNutrients.fat?.value ?? 0), Fiber: \(foodDetail.labelNutrients.fiber?.value ?? 0), Protein: \(foodDetail.labelNutrients.protein?.value ?? 0), SaturatedFat: \(foodDetail.labelNutrients.saturatedFat?.value ?? 0)"
        ingredientsTxtView.text! = "\(foodDetail.ingredients)"
        isLoad = true;
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectionList" {

            guard let nav = segue.destination as? UINavigationController else {
                return
            }
            let vc = nav.viewControllers[0] as! SelectionTableScene
            vc.m = m
            vc.delegate = self
            if (BrandOwnerTxtFieldOutlet.text != "") {
                vc.brandName = BrandOwnerTxtFieldOutlet.text!
            } else {
                vc.brandName = ""
            }
            vc.itemDesc = ItemDescTextFieldOutlet.text!
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Validate data...
        let alert2 = UIAlertController(title: "Alert!", message: "Cannot Fetch, Not Connected To Internet", preferredStyle: UIAlertController.Style.alert)
        alert2.addAction(UIAlertAction(title: "Ok", style:UIAlertAction.Style.default, handler: {(action: UIAlertAction!) in
        }))
        if identifier == "toSelectionList" {
            if (isConnected) {
                // Validate network connectivity
                return true;
            } else {
                self.present(alert2, animated: true, completion: nil)
                return false
            }
            // If all is good, return true
            // Otherwise, return false
        }
        return true
    }
}
