//
//  WelcomeViewModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 16.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation
import CoreLocation

class WelcomeViewModel: NSObject {

    enum Action {
        case updateLabels(weatherInfo: WeatherModel)
    }

    let weatherRepo = WeatherRepository.shared
    var locationManager = CLLocationManager()
    var location: CLLocation? = nil {
        didSet {
            if let _ = location {
                updateWeatherInfo()
            }
        }
    }
    var weatherInfo: WeatherModel? = nil {
        didSet {
            if let weatherInfo = weatherInfo {
                didReceiveAction?(.updateLabels(weatherInfo: weatherInfo))
            }
        }
    }

    var didReceiveAction: ((Action)-> Void)? = nil

    override init() {
        super.init()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.requestLocation()
    }

    func viewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }


    func weatherInfoRequired() {
        locationManager.requestLocation()
    }

    private func updateWeatherInfo() {
        guard let location = location else { return }
        weatherRepo.getCurrentWeatherInfo(with: .coordinates(location)) { [weak self] data in
            guard let self = self else { return }
            if let data = data {
                self.weatherInfo = WeatherModel(date: Date(timeIntervalSince1970: data.dt),
                                                conditionID: data.weather[0].id,
                                                conditionDescription: data.weather[0].description,
                                                cityName: data.name,
                                                windSpeedDouble: data.wind.speed,
                                                windDirectionInt: data.wind.deg,
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
            case 338 ... 22:
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

