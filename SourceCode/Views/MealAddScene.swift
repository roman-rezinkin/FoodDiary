//
//  MealAddScene.swift
//  FoodDiary
//
//  Created by Roman Rezinkin on 2019-11-26.
//  Copyright © 2019 SICT. All rights reserved.
//

import UIKit
import CoreLocation

protocol AddDelegate: class {
    func addTaskDidCancel(_ controller: UIViewController)
    func addTaskDidSave(_ controller: UIViewController)
}
@available(iOS 12.0, *)

class MealAddScene: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate,UITextFieldDelegate {
    
    weak var delegate: AddDelegate?
    
    var m: FoodDMM!
    var mealName: String = ""
    var locName: String = ""
    var placemarkText = "(location not available)"
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var locationRequests: Int = 0
    var geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    @IBOutlet weak var mealTxtField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var NotesField: UITextView!
    @IBOutlet weak var locationString: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var errLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errLbl.text = ""
        locationString.text = ""
        getLocation()
        title = "Add new Meal"

        // Do any additional setup after loading the view.
    }
    // Finish editing button
    @IBAction func finishEditing(_ sender: UIButton) {
        NotesField.resignFirstResponder()
        mealTxtField.resignFirstResponder()
    }
    
    @IBAction func mealNameAction(_ sender: UITextField) {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == mealTxtField) {
            textField.resignFirstResponder()
            NotesField.becomeFirstResponder()
        }
        if (textField == NotesField) {
            textField.resignFirstResponder()
        }
        return true
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
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        view.endEditing(false)
        errLbl.text?.removeAll()
        let alert = UIAlertController(title: "Alert!", message: "Incorrect Input!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) in
        }))
        let passedAlert = UIAlertController(title: "Success!", message: "Attempting to Save", preferredStyle: UIAlertController.Style.alert)
        passedAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) in
        }))
        if (mealTxtField.text!.isEmpty) {
            errLbl.text = "Invalid Meal Name"
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (errLbl.text == "") {
            self.present(passedAlert, animated: true, completion: nil)
            errLbl.text = "Attempting to save..."
            if let newItem = m.meal_CreateItem() {
                newItem.name = mealName
                newItem.date = datePicker.date
                newItem.locName = locationString.text
                newItem.notes = NotesField.text
                if (imageView.image?.pngData() == nil) {
                    newItem.photo = UIImage(named: "placeholder.png")?.pngData()
                } else {
                    newItem.photo = imageView.image!.pngData()
                }
                newItem.locLat = (location?.coordinate.latitude)!
                newItem.locLong = (location?.coordinate.longitude)!
                m.ds_save()
            }
            delegate?.addTaskDidSave(self)
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        delegate?.addTaskDidCancel(self)
    }
    
    @IBAction func mealNameInput(_ sender: UITextField) {
        mealName = sender.text!
    }
    
    //MARK: Location Finder Code
    private func getLocation() {
        // These two statements setup and configure the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10.0
        // Determine whether the app can use location services
        let authStatus = CLLocationManager.authorizationStatus()
        // If the app user has never been asked before, then ask
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        // If the app user has previously denied location services, do this
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        // If we are here, it means that we can use location services
        // This statement starts updating its location
        locationManager.startUpdatingLocation()
    }
    
    // Respond to a previously-denied request to use location services
    private func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in the Settings app.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Build a nice string from a placemark
    // If you want a different format, do it
    private func makePlacemarkText(from placemark: CLPlacemark) -> String {
        var s = ""
        if let subThoroughfare = placemark.subThoroughfare {
            s.append(subThoroughfare)
        }
        if let thoroughfare = placemark.thoroughfare {
            s.append(" \(thoroughfare)")
        }
        if let locality = placemark.locality {
            s.append(", \(locality)")
        }
        if let administrativeArea = placemark.administrativeArea {
            s.append(" \(administrativeArea)")
        }
        if let postalCode = placemark.postalCode {
            s.append(", \(postalCode)")
        }
        if let country = placemark.country {
            s.append(" \(country)")
        }
        return s
    }
    
    // MARK: - Delegate methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // When location services is requested for the first time,
        // the app user is asked for permission to use location services
        // After the permission is determined, this method is called by the location manager
        // If the permission is granted, we want to start updating the location
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\nUnable to use location services: \(error)")
    }
    
    // This is called repeatedly by the iOS runtime,
    // as the location changes and/or the accuracy improves
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Here is how you can configure an arbitrary limit to the number of updates
        if locationRequests > 10 { locationManager.stopUpdatingLocation() }
        // Save the new location to the class instance variable
        location = locations.last!
        // Info to the programmer
        print("\nUpdate successful: \(location!)")
        print("\nLatitude \(location?.coordinate.latitude ?? 0)\nLongitude \(location?.coordinate.longitude ?? 0)")
        // Do the reverse geocode task
        // It takes a function as an argument to completionHandler
        geocoder.reverseGeocodeLocation(location!, completionHandler: { placemarks, error in
            // We're looking for a happy response, if so, continue
            if error == nil, let p = placemarks, !p.isEmpty {
                // "placemarks" is an array of CLPlacemark objects
                // For most geocoding requests, the array has only one value,
                // so we will use the last (most recent) value
                // Format and save the text from the placemark into the class instance variable
                self.placemarkText = self.makePlacemarkText(from: p.last!)
                // Info to the display
                self.locationString.text = self.placemarkText
                // Info to the programmer
                print("\n\(self.placemarkText)")
            }
        })
        locationRequests += 1
    }
}
