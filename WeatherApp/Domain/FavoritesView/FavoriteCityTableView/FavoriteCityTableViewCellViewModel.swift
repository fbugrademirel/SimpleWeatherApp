//
//  FavoriteCityCellModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 11.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation

final class FavoriteCityTableViewCellViewModel {

    let id: Int
    let conditionID: Int
    let cityName: String
    let temperatureDouble: Double
    var temperatureString: String {
        return String(format: "%.0f", temperatureDouble)
    }

    var conditionNameForSFIcons: String {
        WelcomeViewModel.CommonWeatherModelOpearaions.getSFIconsForWeatherCondition(conditionID)
    }

    init(id: Int, cityName: String, temperature: Double, conditionID: Int) {
        self.id = id
        self.cityName = cityName
        self.temperatureDouble = temperature
        self.conditionID = conditionID
    }
    
}
