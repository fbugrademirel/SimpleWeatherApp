//
//  FavoritesViewModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 11.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation

class FavoritesViewModel {

    let cityRepo = CityListRepository.shared

    enum Action {
        case reload
    }
    var didReceivedAction: ((Action) -> Void)?
    var favoriteCities: [CityListRepository.City] = []

    func updateFavoriteCities(id: Int) {
        cityRepo.saveAsFavoriteCity(with: id)
    }
}
