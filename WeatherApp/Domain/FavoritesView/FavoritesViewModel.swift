//
//  FavoritesViewModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 11.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation

final class FavoritesViewModel {

    enum Action {
        case reload
        case presentSearchView(with: SearchViewModel)
    }

    private weak var cityRepo = CityListRepository.shared
    private weak var weatherRepo = WeatherRepository.shared

    var favoriteCityCellViewModels: [FavoriteCityTableViewCellViewModel] = [] {
        didSet {
            didReceivedAction?(.reload)
        }
    }

    var didReceivedAction: ((Action) -> Void)?

    func fetchFavoriteCityWeathers() {

        let favoriteCities = CityListRepository.shared.fetchFavoriteCities().map { cityListItem -> FavoriteCityModel in
            let model = FavoriteCityModel(id: Int(cityListItem.id))
            return model
        }
        favoriteCityCellViewModels = []
        for eachCity in favoriteCities {
            guard let weatherRepo = weatherRepo else { return }
            weatherRepo.getCurrentWeatherInfo(with: .id(eachCity.id )) { [weak self] (data) in
            guard let data = data else { return }
                let viewModel = FavoriteCityTableViewCellViewModel(id: data.id, cityName: data.name, temperature: data.main.temp, conditionID: data.weather[0].id)
                self?.favoriteCityCellViewModels.append(viewModel)
            }
        }
    }

    func updateFavoriteCities(id: Int, updateType: UpdateType ) {

        guard let cityRepo = cityRepo else { return }
        switch updateType {
        case .selectAsFavorite:
            cityRepo.saveAsFavoriteCity(with: id)
            fetchFavoriteCityWeathers()

        case .selectAsUnfavorite:
            cityRepo.saveAsUnfavoriteCity(with: id)
        }
    }

    func searchViewConrollerRequired() {
        didReceivedAction?(.presentSearchView(with: SearchViewModel()))
    }
}

extension FavoritesViewModel {
    struct FavoriteCityModel {
        let id: Int
    }

    enum UpdateType {
        case selectAsFavorite
        case selectAsUnfavorite
    }
}
