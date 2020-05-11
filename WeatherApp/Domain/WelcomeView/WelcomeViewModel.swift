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
        case reloadCollectionView
        case updateUI(with: CurrentWeatherModel)
        case presentSearchView(viewModel: SearchViewModel)
    }

    var isFetchingCiy: Bool = true
    let cityRepo = CityListRepository.shared
    let weatherRepo = WeatherRepository.shared
    var locationManager = CLLocationManager()
    var location: CLLocation? = nil {
        didSet {
            if let location = location {
                updateCurrentWeatherInfo(with: .coordinates(location))
                updateForecastWeatherInfo(with: .coordinates(location))
            }
        }
    }
    var currentWeatherInfo: CurrentWeatherModel? = nil {
        didSet {
            if let weatherInfo = currentWeatherInfo {
                didReceiveAction?(.updateUI(with: (weatherInfo)))
            }
        }
    }
    var forecastColletionViewCellModels: [ForecastCollectionViewCellModel] = [] {
        didSet {
            didReceiveAction?(.reloadCollectionView)
        }
    }
    var didReceiveAction: ((Action)-> Void)?

    func viewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func weatherInfoByLocationRequired() {
        locationManager.requestLocation()
    }

    func weatherInfoByCityIdRequired(with id: Int) {
        updateCurrentWeatherInfo(with: .id(id))
        updateForecastWeatherInfo(with: .id(id))
        cityRepo.saveAsFavoriteCity(with: id)
    }

    func weatherForecastByCityIdRequired(with id: Int) {
        locationManager.requestLocation()
    }

    func citySearchRequired(){
        didReceiveAction?(.presentSearchView(viewModel: SearchViewModel()))
    }

    private func updateCurrentWeatherInfo(with requestInfo: WeatherRepository.LocationInformation) {
        weatherRepo.getCurrentWeatherInfo(with: requestInfo) { [weak self] data in
            guard let self = self else { return }
            if let data = data {
                self.currentWeatherInfo = CurrentWeatherModel(date: Date(timeIntervalSince1970: data.dt),
                                                conditionID: data.weather[0].id,
                                                conditionDescription: data.weather[0].description,
                                                cityName: data.name,
                                                windSpeedDouble: data.wind.speed,
                                                windDirectionInt: data.wind.deg ?? 0,
                                                temperatureDouble: data.main.temp)
            }
        }
    }

    private func updateForecastWeatherInfo(with requestInfo: WeatherRepository.LocationInformation) {
        weatherRepo.getForecastWeatherInfo(with: requestInfo) { [weak self] forecastData in
            guard let self = self, let forecastData = forecastData else { return }

            let forecastCellViewModels = forecastData.list.map { forecastWeatherData -> ForecastCollectionViewCellModel in
                let forecast = Forecast(date: Date(timeIntervalSince1970: forecastWeatherData.dt),
                                        temperatureDouble: forecastWeatherData.main.temp,
                                        conditionID: forecastWeatherData.weather[0].id,
                                        windSpeed: forecastWeatherData.wind.speed,
                                        windDirection: forecastWeatherData.wind.deg ?? 0)
                let viewModel = ForecastCollectionViewCellModel(imageString: forecast.conditionNameForSFIcons,
                                                                temperature: forecast.temperatureString,
                                                                date: forecast.date,
                                                                windSpeed: forecast.windSpeedString,
                                                                windDirectionStringForSFIcon: forecast.windDirectionStringForSFImage,
                                                                windAngle: forecast.windDirection)
                return viewModel
            }
            self.forecastColletionViewCellModels = forecastCellViewModels
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

//MARK: - Weather Models
extension WelcomeViewModel {

    enum ModelType {
        case currentWeather (CurrentWeatherModel)
        case fiveDaysForecast (FiveDayForecastModel)
    }

    struct CurrentWeatherModel {
        let date: Date
        let conditionID: Int
        let conditionDescription: String
        let cityName: String
        let windSpeedDouble: Double
        var windSpeedString: String {
            return String(format: "%.0f", windSpeedDouble * 3.6) // in km/h
        }
        let windDirectionInt: Int
        let windDirectionStringForSFImage = "arrow.up"

        let temperatureDouble: Double
        var temperatureString: String {
            return String(format: "%.0f", temperatureDouble)
        }

        var conditionNameForSFIcons: String {
            CommonWeatherModelOpearaions.getSFIconsForWeatherCondition(conditionID)
        }
    }

    struct FiveDayForecastModel {
        let forecastList: [Forecast]
        let cityName: String
    }

    struct Forecast {
        let date: Date
        let temperatureDouble: Double
        var temperatureString: String {
            return String(format: "%.0f", temperatureDouble)
        }
        let conditionID: Int
        var conditionNameForSFIcons: String {
            CommonWeatherModelOpearaions.getSFIconsForWeatherCondition(conditionID)
        }
        let windSpeed: Double
        var windSpeedString: String {
            return String(format: "%.0f", windSpeed * 3.6) // in km/h
        }
        let windDirection: Int
        let windDirectionStringForSFImage = "arrow.up"
    }

    struct CommonWeatherModelOpearaions {
        static func getSFIconsForWeatherCondition(_ conditionID: Int) -> String {
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
//        static func getSFIconsForWindDirection(_ degree: Int) -> String {
//            switch degree {
//            case 23 ... 68:
//                return "arrow.down.left"
//            case 69 ... 112:
//                return "arrow.left"
//            case 113 ... 157:
//                return "arrow.up.left"
//            case 158 ... 202:
//                return "arrow.up"
//            case 203 ... 247:
//                return "arrow.up.right"
//            case 248 ... 293:
//                return "arrow.right"
//            case 294 ... 337:
//                return "arrow.down.right"
//            case (338 ... 359), (0 ... 23):
//                return "arrow.down"
//            default:
//                return "arrow.down"
//            }
//        }
    }
}

