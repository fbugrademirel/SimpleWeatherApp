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

    init(city: CityListRepository.City) {
        self.city = city
    }

    var didReceiveAction: ((Action) -> Void)?
}
