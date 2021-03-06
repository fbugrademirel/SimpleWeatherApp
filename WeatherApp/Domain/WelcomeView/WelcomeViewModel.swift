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
        case setTempLabel(to: TemperatureSettingsManager.TempUnit)
        case setUnitSegmentController(to: TemperatureSettingsManager.TempUnit)
        case setActivityIndicator(to: ActivityIndicatorSetting)
    }

    //MARK: - Properties
    var tempUnit: TemperatureSettingsManager.TempUnit = .celcius {
        didSet {
            didReceiveAction?(.setTempLabel(to: tempUnit))
            forecastColletionViewCellModels.forEach { (model) in
                model.tempUnit = tempUnit
            }
        }
    }

    let settingsManager = TemperatureSettingsManager()
    var lastCityOnWelcomeScreen: Int?
    private let cityRepo = CityListRepository.shared
    private let weatherRepo = WeatherRepository.shared
    private var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        return lm
    }()

    private var location: CLLocation? = nil {
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
                isUpdatingWeather = false
                didReceiveAction?(.updateUI(with: (weatherInfo)))
            }
        }
    }

    var forecastColletionViewCellModels: [ForecastCollectionViewCellViewModel] = [] {
        didSet {
            didReceiveAction?(.reloadCollectionView)
        }
    }

    var isUpdatingWeather: Bool = false {
        didSet {
            if isUpdatingWeather {
                didReceiveAction?(.setActivityIndicator(to: .start))
            } else {
               didReceiveAction?(.setActivityIndicator(to: .stop))
            }
        }
    }

    var didReceiveAction: ((Action)-> Void)?

    //MARK: - Handle
    //TODO: - For future use
    func handle(action: ForecastCollectionViewCellViewModel.ActionToParent) {
        switch action {
        case .toMain:
            print("Handled by WelcomeViewModel")
        }
    }

    //MARK: - Operations
    func viewDidLoad() {
        lastCityOnWelcomeScreen = UserDefaults.standard.object(forKey: "LastCity") as? Int
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if lastCityOnWelcomeScreen == nil {
            locationManager.requestLocation()
        } else if let lastCity = lastCityOnWelcomeScreen {
            weatherInfoByCityIdRequired(with: lastCity, saveAsFavorite: false)
        }
        settingsManager.delegate = self
        let unit = TemperatureSettingsManager.TempUnit(rawValue: UserDefaults.standard.object(forKey: "Unit") as? TemperatureSettingsManager.TempUnit.RawValue ?? TemperatureSettingsManager.TempUnit.celcius.rawValue)
        settingsManager.setUnit(to: unit)
        if let unit = unit {
            didReceiveAction?(.setUnitSegmentController(to: unit))
        }
    }

    func weatherInfoByLocationRequired() {
        isUpdatingWeather = true
        locationManager.requestLocation()
    }

    func weatherInfoByCityIdRequired(with id: Int, saveAsFavorite: Bool = true) {
        updateCurrentWeatherInfo(with: .id(id))
        updateForecastWeatherInfo(with: .id(id))
        if saveAsFavorite {
            cityRepo.saveAsFavoriteCity(with: id)
        }
    }

    func citySearchRequired(){
        didReceiveAction?(.presentSearchView(viewModel: SearchViewModel()))
    }

    func saveAsLastCityOnWelcomeScreen(id: Int) {
        lastCityOnWelcomeScreen = id
        UserDefaults.standard.set(id, forKey: "LastCity")
    }

    private func updateCurrentWeatherInfo(with requestInfo: WeatherRepository.LocationInformation) {
        weatherRepo.getCurrentWeatherInfo(with: requestInfo) { [weak self] data in
            guard let self = self else { return }
            if let data = data {
                self.currentWeatherInfo = CurrentWeatherModel(id: data.id,
                                                date: Date(timeIntervalSince1970: data.dt),
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

            let forecastCellViewModels = forecastData.list.map { forecastWeatherData -> ForecastCollectionViewCellViewModel in
                let forecast = Forecast(date: Date(timeIntervalSince1970: forecastWeatherData.dt),
                                        temperatureDouble: forecastWeatherData.main.temp,
                                        conditionID: forecastWeatherData.weather[0].id,
                                        windSpeed: forecastWeatherData.wind.speed,
                                        windDirection: forecastWeatherData.wind.deg ?? 0)
                let viewModel = ForecastCollectionViewCellViewModel(imageString: forecast.conditionNameForSFIcons,
                                                                temperature: forecast.temperatureString,
                                                                date: forecast.date,
                                                                windSpeed: forecast.windSpeedString,
                                                                windDirectionStringForSFIcon: forecast.windDirectionStringForSFImage,
                                                                windAngle: forecast.windDirection,
                                                                tempUnit: self.tempUnit)
                viewModel.didReceiveActionForParent = { [weak self] action in
                    self?.handle(action: action)
                }
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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            weatherInfoByLocationRequired()
        }
    }
}

//MARK: - TemperatureSettingsManagerDelegate
extension WelcomeViewModel: TemperatureSettingsManagerDelegate {
    func tempUnitDidSet(_ temperatureSettingsManager: TemperatureSettingsManager, unit: TemperatureSettingsManager.TempUnit) {
        tempUnit = unit
    }
}

//MARK: - Weather Models
extension WelcomeViewModel {

    enum ActivityIndicatorSetting {
        case start
        case stop
    }

    enum ModelType {
        case currentWeather (CurrentWeatherModel)
        case fiveDaysForecast (FiveDayForecastModel)
    }

    struct CurrentWeatherModel {
        let id: Int
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
    }
}

