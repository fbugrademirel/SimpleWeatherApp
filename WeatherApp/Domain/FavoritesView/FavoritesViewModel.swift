//
//  FavoritesViewModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 11.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation

class FavoritesViewModel {


    enum Action {
        case reload
    }

    let cityRepo = CityListRepository.shared
    let weatherRepo = WeatherRepository.shared

    var favoriteCities: [FavoriteCityModel] = []
    var favoriteCityCellViewModels: [FavoriteCityCellTableViewCellViewModel] = [] {
        didSet {
            didReceivedAction?(.reload)
        }
    }

    var didReceivedAction: ((Action) -> Void)?

    init() {
        let cities = cityRepo.favoriteCities.map { cityListItem -> FavoriteCityModel in
            let model = FavoriteCityModel(id: Int(cityListItem.id))
            return model
        }
        self.favoriteCities = cities
        //FIXME: - ADD EVERYTHIG AT ONCE
        for eachCity in favoriteCities {
            weatherRepo.getCurrentWeatherInfo(with: .id(eachCity.id )) { [weak self] (data) in
            guard let data = data else { return }
            let viewModel = FavoriteCityCellTableViewCellViewModel(cityName: data.name, temperature: data.main.temp, conditionID: data.weather[0].id)
                self?.favoriteCityCellViewModels.append(viewModel)
            }
        }
    }

//    for eachCity in favoriteCities {
//        weatherRepo.getCurrentWeatherInfo(with: .id(eachCity.id )) { [weak self] (data) in
//        guard let data = data else { return }
//        let viewModel = FavoriteCityCellTableViewCellViewModel(cityName: data.name, temperature: data.main.temp, conditionID: data.weather[0].id)
//            self?.favoriteCityCellViewModels.append(viewModel)
//        }
//    }

    func updateFavoriteCities(id: Int) {
        cityRepo.saveAsFavoriteCity(with: id)
    }
}

extension FavoritesViewModel {
    struct FavoriteCityModel {
        let id: Int
    }
}
