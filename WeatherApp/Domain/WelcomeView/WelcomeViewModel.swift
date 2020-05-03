//
//  WelcomeViewModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 16.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation
import CoreLocation

final class WelcomeViewModel: NSObject {

    enum Action {
        case updateUI(weatherInfo: WeatherModel)
        case presentSearchView(viewModel: SearchViewModel)
    }

    let cityRepo = CityListRepository.shared
    let weatherRepo = WeatherRepository.shared
    var locationManager = CLLocationManager()
    var location: CLLocation? = nil {
        didSet {
            if let location = location {
                updateWeatherInfo(with: .coordinates(location))
            }
        }
    }
    var weatherInfo: WeatherModel? = nil {
        didSet {
            if let weatherInfo = weatherInfo {
                didReceiveAction?(.updateUI(weatherInfo: weatherInfo))
            }
        }
    }

    var didReceiveAction: ((Action)-> Void)? = nil

    func viewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func weatherInfoByLocationRequired() {
        locationManager.requestLocation()
    }

    func weatherInfoByCityIdRequired(with id: Int) {
        updateWeatherInfo(with: .id(id))
    }

    func citySearchRequired(){
        didReceiveAction?(.presentSearchView(viewModel: SearchViewModel()))
    }

    private func updateWeatherInfo(with requestInfo: WeatherRepository.LocationInformation) {
        weatherRepo.getCurrentWeatherInfo(with: requestInfo) { [weak self] data in
            guard let self = self else { return }
            if let data = data {
                self.weatherInfo = WeatherModel(date: Date(timeIntervalSince1970: data.dt),
                                                conditionID: data.weather[0].id,
                                                conditionDescription: data.weather[0].description,
                                                cityName: data.name,
                                                windSpeedDouble: data.wind.speed,
                                                windDirectionInt: data.wind.deg ?? 0,
                                                temperatureDouble: data.main.temp)
            }
        }
    }
}

//MARK: - Location Manager
extension WelcomeViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            self.location = location
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

//MARK: - Weather Model
extension WelcomeViewModel {
    struct WeatherModel {
        let date: Date
        let conditionID: Int
        let conditionDescription: String
        let cityName: String
        let windSpeedDouble: Double
        var windSpeedString: String {
            return String(format: "%.0f", windSpeedDouble * 3.6) // in km/h
        }
        let windDirectionInt: Int
        var windDirectionString: String {

            switch windDirectionInt {
            case 23 ... 68:
                return "arrow.down.left"
            case 69 ... 112:
                return "arrow.left"
            case 113 ... 157:
                return "arrow.up.left"
            case 158 ... 202:
                return "arrow.up"
            case 203 ... 247:
                return "arrow.up.right"
            case 248 ... 293:
                return "arrow.right"
            case 294 ... 337:
                return "arrow.down.right"
            case (338 ... 359), (0 ... 23):
                return "arrow.down"
            default:
                return "arrow.down"
            }
        }
        let temperatureDouble: Double
        var temperatureString: String {
            return String(format: "%.0f", temperatureDouble)
        }
        var conditionNameForSFIcons: String {
            switch conditionID {
            case 200 ... 232:
                return "cloud.bolt.rain"
            case 300 ... 321:
                return "cloud.drizzle"
            case 500 ... 531:
                return "cloud.rain"
            case 600 ... 622:
                return "cloud.snow"
            case 700 ... 781:
                return "cloud.fog"
            case 800:
                return "sun.max"
            case 801:
                return "cloud.sun"
            case 802:
                return "cloud.sun"
            case 803:
                return "cloud.sun"
            case 804:
                return "cloud"
            default:
                return "cloud"
            }
        }
    }
}

