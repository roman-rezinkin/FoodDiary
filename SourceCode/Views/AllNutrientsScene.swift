//
//  AllNutrientsScene.swift
//  FoodDiary
//
//  Created by Roman Rezinkin on 2019-11-28.
//  Copyright © 2019 SICT. All rights reserved.
//
// sodium, cals, fat, protein, carbs
import UIKit
@available(iOS 12.0, *)

class AllNutrientsScene: UIViewController {
    var m: FoodDMM!
    var item: Meal!
    var items: [FoodConsumed]!
    var sodium: Float = 0
    var cals: Float = 0
    var fat: Float = 0
    var protein: Float = 0
    var carbs: Float = 0
    @IBOutlet weak var sodiumLbl: UILabel!
    @IBOutlet weak var calsLbl: UILabel!
    @IBOutlet weak var fatLbl: UILabel!
    @IBOutlet weak var proteinLbl: UILabel!
    @IBOutlet weak var carbsLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Total Macronutrients"
        for i in items {
            sodium += i.nsodium
            cals += i.ncals
            fat += i.nfat
            protein += i.nprotein
            carbs += i.ncarbs
        }
        sodiumLbl.text = "\(sodium)"
        calsLbl.text = "\(cals)"
        fatLbl.text = "\(fat)"
        proteinLbl.text = "\(protein)"
        carbsLbl.text = "\(carbs)"

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
