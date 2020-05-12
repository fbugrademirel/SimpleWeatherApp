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

    private weak var cityRepo = CityListRepository.shared
    private weak var weatherRepo = WeatherRepository.shared

    var favoriteCities: [FavoriteCityModel] = CityListRepository.shared.fetchFavoriteCities().map { cityListItem -> FavoriteCityModel in
        let model = FavoriteCityModel(id: Int(cityListItem.id))
        return model
    }

    var testArray: [FavoriteCityCellTableViewCellViewModel] = []

    var favoriteCityCellViewModels: [FavoriteCityCellTableViewCellViewModel] = [] {
        didSet {
            didReceivedAction?(.reload)
        }
    }

    var didReceivedAction: ((Action) -> Void)?

    init() {
        for eachCity in favoriteCities {
            guard let weatherRepo = weatherRepo else { return }
            weatherRepo.getCurrentWeatherInfo(with: .id(eachCity.id )) { [weak self] (data) in
            guard let data = data else { return }
            let viewModel = FavoriteCityCellTableViewCellViewModel(cityName: data.name, temperature: data.main.temp, conditionID: data.weather[0].id)
                self?.favoriteCityCellViewModels.append(viewModel)
            }
        }
    }


    func updateFavoriteCities(id: Int) {
        guard let cityRepo = cityRepo else { return }
        cityRepo.saveAsFavoriteCity(with: id)
    }
}

extension FavoritesViewModel {
    struct FavoriteCityModel {
        let id: Int
    }
}
