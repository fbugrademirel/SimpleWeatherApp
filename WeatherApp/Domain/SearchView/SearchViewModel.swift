//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 2.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation

final class SearchViewModel {

    enum Request {
        case updateWithData(WeatherDataAPI.WeatherData)
    }

    enum Action {
        case reload
    }

    let weatherRepo = WeatherRepository.shared
    let cityRepo = CityListRepository.shared

    var cityList: [CityListRepository.City] = []
    var cityTableViewCellModels: [CityTableViewCellViewModel] = [] {
        didSet {
            didReceiveAction?(.reload)
        }
    }

    var didReceiveAction: ((Action)->())?

    func handle(_ action: CityTableViewCellViewModel.Action) {
        switch action {
        case .selectCity:
            print("handled by search view model")
        }
    }

    func cityListRequired(for string: String) {
        cityRepo.getCityInfo(by: string) { [weak self] cities in
            self?.cityList = cities
            let cityCellviewModels = cities.map { city -> CityTableViewCellViewModel in //cities.sorted(by: {$1.name > $0.name})
                let viewModel = CityTableViewCellViewModel(city: city)
                viewModel.didReceiveAction = { [weak self] action in
                    self?.handle(action)
                }
                return viewModel
            }
            self?.cityTableViewCellModels = cityCellviewModels
        }
    }
}


