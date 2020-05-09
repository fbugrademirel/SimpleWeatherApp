//
//  ForecastCollectionViewModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 6.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation

class ForecastCollectionViewCellModel {

    let imageString: String
    let temperature: String
    let date: Date

    init(imageString: String, temperature: String, date: Date) {
        self.imageString = imageString
        self.temperature = temperature
        self.date = date
    }

}
