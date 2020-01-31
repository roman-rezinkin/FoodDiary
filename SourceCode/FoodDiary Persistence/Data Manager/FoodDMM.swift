//
//  DataModelManager.swift
//  Purpose - Manages data model tasks for all modules in the app
//

import CoreData

class FoodDMM {
    
    // MARK: - Private internal instance variables
    
    private var cdStack: FoodCDStack!
    
    // MARK: - Public properties (instance variables)
    
    var ds_context: NSManagedObjectContext!
    var ds_model: NSManagedObjectModel!
    var foodSearchFood = [Food]()
    var foodDetailsFood: FoodDetails!
    // MARK: - Lifecycle
    
    
    init() {
        // Initialize the Core Data stack
        cdStack = FoodCDStack(model: self)
        ds_context = cdStack.persistentContainer.viewContext
        ds_model = cdStack.persistentContainer.managedObjectModel
    }
    
    // MARK: - Public methods
    
    func ds_frcForEntityNamed<T>(_ entityName: String, withPredicateFormat predicate: String?, predicateObject: [AnyObject]?, sortDescriptors: [NSSortDescriptor]?, andSectionNameKeyPath sectionName: String?) -> NSFetchedResultsController<T> {
        
        return cdStack.createFetchedResultsControllerForEntityNamed(entityName, withPredicateFormat: predicate, predicateObject: predicateObject, sortDescriptors: sortDescriptors, andSectionNameKeyPath: sectionName)
    }
    
    // Save changes, if any
    func ds_save() {
        cdStack.save()
    }
    
    
    // MARK: Functions
    
    // Get all cats from restdb.io
    func foodSearchGetAll(gsi: String, bo: String) {
        // Create a request object (and configure it if necessary)
        let request = FetchFactory()
        request.httpMethod = "POST"
        //request.headerContentType = "application/json"

        let dataTypes = IncludeDataTypes(Branded: true)
        let theBody = FoodSearchCriteria(includeDataTypes: dataTypes, generalSearchInput: gsi, brandOwner: bo, requireAllWords: true)
        //dump(theBody)
        let jsonData = try? JSONEncoder().encode(theBody)
        
        request.httpBody = jsonData
        // Send the request, and write a completion method to pass to the request
        request.sendRequest(toUrlPath: "https://api.nal.usda.gov/fdc/v1/search?api_key=gofA5eUuUeEned8nq2mEePeSzuSI4Ny2tDiHXwBF") { (result: FoodSearch) in
            //dump(result)
            // Save the result in the mnager property
            self.foodSearchFood = result.foods
            NotificationCenter.default.post(name: Notification.Name("FoodSearchGetAll"), object: nil)
        }
    }
    
    func foodDetailGetAll(someId: String) {
        let request = FetchFactory()
        request.sendRequest(toUrlPath: "https://api.nal.usda.gov/fdc/v1/\(someId)?api_key=gofA5eUuUeEned8nq2mEePeSzuSI4Ny2tDiHXwBF") { (result: FoodDetails) in
            // Save the result in the mnager property
            self.foodDetailsFood = result
            // Post a notification
            NotificationCenter.default.post(name: Notification.Name("foodDetailGetAll"), object: result)
        }
    }
}

// Then...

// The code below must be pasted into the app delegate class
// There are two versions:
// 1. When the first scene is managed by a navigation controller
// 2. When the first scene is a standard view controller

// Copy the code below, and REPLACE the app delegate method
// application(didFinishLaunchingWithOptions:)

/*
 // For use when a navigation controller manages the first scene
 // In this situation, the storyboard entry point is a navigation controller
 // and the first controller is typically a table view controller
 
 // Create the data model manager
 let m = DataModelManager()
 
 // MARK: - Lifecycle
 
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
 
 // Get a reference to the navigation controller
 let nav = window!.rootViewController as! UINavigationController
 
 // Get a reference to the (table view) controller
 let vc = nav.viewControllers[0] as! XXX-FirstControllerName-XXX
 
 // Pass the model object to the (table view) controller
 vc.m = m
 
 return true
 }
 */

/*
 // For use when a standard view controller manages the first scene
 // In this situation, the storyboard entry point is NOT a navigation controller
 
 // Create the data model manager
 let m = DataModelManager()
 
 // MARK: - Lifecycle
 
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
 
 // Get a reference to the (standard view) controller
 let vc = nav.rootViewController as! XXX-FirstControllerName-XXX
 
 // Pass the model object to the (standard view) controller
 vc.m = m
 
 return true
 }
 */
