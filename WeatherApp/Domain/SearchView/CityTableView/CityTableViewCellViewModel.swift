//
//  CityTableViewCellModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 3.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation

final class CityTableViewCellViewModel {

    enum Action {
        case selectCity
    }

    let city: CityListRepository.City
    var searchString: String? = nil

    init(city: CityListRepository.City, searchString: String) {
        self.city = city
        self.searchString = searchString
    }

    var didReceiveAction: ((Action) -> Void)?
}
