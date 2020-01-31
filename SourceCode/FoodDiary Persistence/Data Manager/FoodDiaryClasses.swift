//
//  FoodDiaryClasses.swift
//  FoodDiary
//
//  Created by Roman Rezinkin on 2019-11-26.
//  Copyright © 2019 SICT. All rights reserved.
//

// To get proper structures, used a website https://app.quicktype.io/ which lets me take my postman results json, and it creates a swift version

import Foundation

// MARK: - FoodSearch
struct FoodSearch: Codable {
    let foodSearchCriteria: FoodSearchCriteria
    let foods: [Food]
}

// MARK: - FoodSearchCriteria
struct FoodSearchCriteria: Codable {
    let includeDataTypes: IncludeDataTypes
    let generalSearchInput: String
    let brandOwner: String?
    let requireAllWords: Bool
}

// MARK: - IncludeDataTypes
struct IncludeDataTypes: Codable {
    let Branded: Bool

    enum CodingKeys: String, CodingKey {
        case Branded
    }
}

// MARK: - Food
struct Food: Codable {
    var fdcID: Int
    let foodDescription: String
    let dataType: String
    let publishedDate: String
    let brandOwner: String?
    let ingredients: String?
    let allHighlightFields: String?
    let score: Double

    enum CodingKeys: String, CodingKey {
        case fdcID = "fdcId"
        case foodDescription = "description"
        case brandOwner
        case dataType, publishedDate, ingredients, allHighlightFields, score
    }
}

// MARK: FOOD DETAILS STRUCTURES
class FoodDetails: Codable {
    let foodClass, foodDetailsDescription, brandOwner, ingredients: String
    let servingSize: Float
    let labelNutrients: LabelNutrients
    let brandedFoodCategory: String
    let fdcID: Int

    enum CodingKeys: String, CodingKey {
        case foodClass
        case foodDetailsDescription = "description"
        case brandOwner, ingredients, servingSize, labelNutrients, brandedFoodCategory
        case fdcID = "fdcId"
    }
}

// MARK: - LabelNutrients
class LabelNutrients: Codable {
    let fat, saturatedFat, transFat, cholesterol: Calories?
    let sodium, carbohydrates, fiber, sugars: Calories?
    let protein, calories: Calories?
}

// MARK: - Calories
class Calories: Codable {
    let value: Float
}

