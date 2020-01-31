//
//  FoodConsumedScene.swift
//  FoodDiary
//
//  Created by Roman Rezinkin on 2019-11-26.
//  Copyright © 2019 SICT. All rights reserved.
//

import UIKit
@available(iOS 12.0, *)

class FoodConsumedScene: UIViewController {
    
    // MARK: - Public properties (instance variables)
    
    var m: FoodDMM!
    // Passed-in object, if necessary
    var item: FoodConsumed!
    
    // MARK: - Outlets (user interface)
    
    @IBOutlet weak var sodiumLvlLbl: UILabel!
    @IBOutlet weak var ownerNameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var calLbl: UILabel!
    @IBOutlet weak var fatLbl: UILabel!
    @IBOutlet weak var proteinLbl: UILabel!
    @IBOutlet weak var carbsLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = item.descr!
        sodiumLvlLbl.text? = "\(Int(item.nsodium))"
        ownerNameLbl.text? = item.brandOwner!
        descLbl.text? = item.descr!
        calLbl.text? = "\(Int(item.ncals))"
        fatLbl.text? = "\(Int(item.nfat))"
        proteinLbl.text? = "\(Int(item.nprotein))"
        carbsLbl.text? = "\(Int(item.ncarbs))"
        imageView.image = UIImage(data: item.photo!)
    }
}
