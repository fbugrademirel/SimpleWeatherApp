//
//  WeatherRepository.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 16.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import UIKit

private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

final class WeatherRepository {

    private var currentWeathers = [WeatherDataAPI.CurrentWeatherData]()
    private var currentForecasts = [WeatherDataAPI.ForecastData]()

    static let shared = WeatherRepository()

    func getCurrentWeatherInfo(with locationInformation: LocationInformation, for completion: @escaping (WeatherDataAPI.CurrentWeatherData?) -> Void) {

        var isOutOfDate: Bool = false
        var isNotFound: Bool = false

      //  print("Current Weathers: \(currentWeathers)")

        if !currentWeathers.isEmpty {
            switch locationInformation {
            case .id(let id):
                for (index, each) in currentWeathers.enumerated() {
                    let isEqual: Bool = each.id == id //ids are equal
                    let isEqualandUptoDate: Bool = isEqual && (Date().timeIntervalSince1970 - each.dt) > 600  //600 seconds = 10 minutes
                    if isEqualandUptoDate {
                        currentWeathers.remove(at: index)
                        isOutOfDate = true
                        break
                    } else if isEqual {
                        DispatchQueue.main.async {
                            completion(each)
                        }
                        return
                    }
                }
            case .coordinates(let coordinates):
                for (index, each) in currentWeathers.enumerated() {
                    let isEqual = (each.coord.lat.rounded() == coordinates.coordinate.latitude.rounded()) && (each.coord.lon.rounded() == coordinates.coordinate.longitude.rounded()) // Coordinates are equal
                    let isEqualandUptoDate: Bool = isEqual && (Date().timeIntervalSince1970 - each.dt) > 600 //600 seconds = 10 minutes
                    if isEqualandUptoDate {
                        currentWeathers.remove(at: index)
                        isOutOfDate = true
                        break
                    } else if (each.coord.lat.rounded() == coordinates.coordinate.latitude.rounded())
                            && (each.coord.lon.rounded() == coordinates.coordinate.longitude.rounded()) {
                        DispatchQueue.main.async {
                            completion(each)
                        }
                        return
                    }
                }
            }
            isNotFound = true
        }

        if currentWeathers.isEmpty || isOutOfDate || isNotFound {
            switch locationInformation {
            case .id(let id):
                WeatherDataAPI().getCurrentWeatherInfo(by: .id(id)) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let weatherInfo):
                        self.currentWeathers.append(weatherInfo)
                        DispatchQueue.main.async {
                            completion(weatherInfo)
                        }
                    case .failure(let error):
                        print("Error getting current weather from Weather Data API by ID \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            case .coordinates(let coordinates):
                WeatherDataAPI().getCurrentWeatherInfo(by: .coordinates(coordinates)) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let weatherInfo):
                        self.currentWeathers.append(weatherInfo)
                        DispatchQueue.main.async {
                            completion(weatherInfo)
                        }
                    case .failure(let error):
                         print("Error getting current weather from Weather Data API by coordinates \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            }
        }
    }

    func getForecastWeatherInfo(with locationInformation: LocationInformation, for completion: @escaping (WeatherDataAPI.ForecastData?) -> Void) {

        var isOutOfDate: Bool = false
        var isNotFound: Bool = false

//        print("Current Forecasts: \(currentForecasts)")

        if !currentForecasts.isEmpty {
            switch locationInformation {
            case .id(let id):
                for (index, each) in currentForecasts.enumerated() {
                    let isEqual: Bool = each.city.id == id //ids are equal
                    let isEqualandUptoDate: Bool = isEqual && (Date().timeIntervalSince1970 - each.list[0].dt) > 6000  //6000 seconds = 100 minutes
                    if isEqualandUptoDate {
                        currentForecasts.remove(at: index)
                        isOutOfDate = true
                        break
                    } else if isEqual {
                        DispatchQueue.main.async {
                            completion(each)
                        }
                        return
                    }
                }
            case .coordinates(let coordinates):
                for (index, each) in currentForecasts.enumerated() {
                    let isEqual = (each.city.coord.lat.rounded() == coordinates.coordinate.latitude.rounded()) && (each.city.coord.lon.rounded() == coordinates.coordinate.longitude.rounded()) // Coordinates are equal
                    let isEqualandUptoDate: Bool = isEqual && (Date().timeIntervalSince1970 - each.list[0].dt) > 6000 //6000 seconds = 100 minutes
                    if isEqualandUptoDate {
                        currentForecasts.remove(at: index)
                        isOutOfDate = true
                        break
                    } else if (each.city.coord.lat.rounded() == coordinates.coordinate.latitude.rounded())
                        && (each.city.coord.lon.rounded() == coordinates.coordinate.longitude.rounded()) {
                        DispatchQueue.main.async {
                            completion(each)
                        }
                        return
                    }
                }
            }
            isNotFound = true
        }

        if currentForecasts.isEmpty || isOutOfDate || isNotFound {
            switch locationInformation {
            case .id(let id):
                WeatherDataAPI().getForecastWeatherInfo(by:.id(id)) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let weatherForecastInfo):
                        self.currentForecasts.append(weatherForecastInfo)
                        DispatchQueue.main.async {
                            completion(weatherForecastInfo)
                        }
                    case .failure(let error):
                        print("Error getting current weather from Weather Data API by ID \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            case .coordinates(let coordinates):
                WeatherDataAPI().getForecastWeatherInfo(by: .coordinates(coordinates)) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let weatherForecastInfo):
                        self.currentForecasts.append(weatherForecastInfo)
                        DispatchQueue.main.async {
                            completion(weatherForecastInfo)
                        }
                    case .failure(let error):
                         print("Error getting current weather from Weather Data API by coordinates \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            }
        }
    }
}

extension WeatherRepository {
    enum LocationInformation {
        case coordinates(CLLocation)
        case id(Int)
    }
}
