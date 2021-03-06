//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 2.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation

final class SearchViewModel {

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

    // TODO: - For future use
    func handle(_ action: CityTableViewCellViewModel.Action) {
        switch action {
        case .select:
            print("handled by search view model")
        }
    }

    func cityListRequired(for string: String) {
        cityRepo.getCityInfo(by: string) { [weak self] cities in
            self?.cityList = cities
            let cityCellviewModels = cities.map { city -> CityTableViewCellViewModel in
                let viewModel = CityTableViewCellViewModel(city: city, searchString: string)
                viewModel.didReceiveAction = { [weak self] action in
                    self?.handle(action)
                }
                return viewModel
            }
            self?.cityTableViewCellModels = cityCellviewModels
        }
    }
}


