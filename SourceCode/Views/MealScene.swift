//
//  MealScene.swift
//  FoodDiary
//
//  Created by Roman Rezinkin on 2019-11-25.
//  Copyright © 2019 SICT. All rights reserved.
//

import UIKit
import MapKit
@available(iOS 12.0, *)

class MealScene: UIViewController, MKMapViewDelegate {

    // MARK: - Public properties (instance variables)
    var m: FoodDMM!
    // Passed-in object, if necessary
    var item: Meal!
    var mapAnnotations = [MapAnnotation]()
    var userLocationTitle: String?
    var userLocationSubtitle: String?
    
    // MARK: - Outlets (user interface)
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var NotesLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        super.viewDidLoad()
        NameLbl.text? = item.name!
        NotesLbl.text? = item.notes!
        dateLbl.text? = dateFormatter.string(from: item.date!)
        imageView.image = UIImage(data: item.photo!)
        mapView.delegate = self
    }
    
    @IBAction func toAllMacronutrients(_ sender: UIButton) {}
    
    // MARK: - Navigation
    @IBAction func toFoodItemListBtn(_ sender: UIButton) {}
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: item.locLat, longitude: item.locLong)
        // Prepare the map's visible region
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 2000, longitudinalMeters: 2000)
        // Prepare the callout
        mapView.userLocation.title = userLocationTitle
        mapView.userLocation.subtitle = userLocationSubtitle
        // Show the map
        mapView.setRegion(region, animated: true)
        // Add annotations
        if mapAnnotations.count > 0 {
            mapView.addAnnotations(mapAnnotations)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFoodConsumedList" {
            let vc = segue.destination as! FoodConsumedList
            //let selectedData = item
            vc.items = item.foodConsumed?.sortedArray(using: [NSSortDescriptor(key: "descr", ascending: true)]) as? [FoodConsumed]
            vc.m = m
            vc.theMeal = item
        }
        if segue.identifier == "toAllNutrients" {
            let vc = segue.destination as! AllNutrientsScene
            vc.items = item.foodConsumed?.sortedArray(using: [NSSortDescriptor(key: "descr", ascending: true)]) as? [FoodConsumed]
            vc.m = m
            vc.item = item
        }
    }
}

// Defines a map annotation object
class MapAnnotation: NSObject, MKAnnotation {
    // Initializer
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    // This property must be key-value observable, which the "`"@objc dynamic"`" attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var title: String?
    var subtitle: String?
}
