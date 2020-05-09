//
//  WeatherModelAPI.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 15.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation
import CoreLocation

private let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=0a4f004ec035e586cf9fa1bff7bb191d&units=metric&id="
private let forecastURL = "https://api.openweathermap.org/data/2.5/forecast?appid=0a4f004ec035e586cf9fa1bff7bb191d&units=metric&id="

struct WeatherDataAPI {

    private let networkingService = NetworkingService()

    func getCurrentWeatherInfo(by locationInformation: LocationInformation, with completion: @escaping (Result<CurrentWeatherData, Error>) -> Void) {

        let url = setURL(locationInformation: locationInformation, forecastType: .current)

        print("Current forecast url: \(url)")

        networkingService.dispatchRequest(urlString: url, method: .get) { result in
            switch result {
            case .success(let data):
                do {
                    let weather = try JSONDecoder().decode(CurrentWeatherData.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(weather))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func getForecastWeatherInfo(by locationInformation: LocationInformation, completion: @escaping ((Result<ForecastData, Error>) -> Void)) {

        let url = setURL(locationInformation: locationInformation, forecastType: .fiveDays)

        print("5 days forecast url: \(url)")

        networkingService.dispatchRequest(urlString: url, method: .get) { result in
            switch result {
            case .success(let data):
                do {
                    let weather = try JSONDecoder().decode(ForecastData.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(weather))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    private func setURL(locationInformation: LocationInformation, forecastType: ForecastType) -> String {

        var url = ""

        switch (locationInformation, forecastType) {
        case (.id(let id), .current):
            url = "\(weatherURL)\(String(id))"
        case (.id(let id), .fiveDays):
            url = "\(forecastURL)\(String(id))"
        case (.coordinates(let location), .current):
            url = "\(weatherURL)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
        case (.coordinates(let location), .fiveDays):
            url = "\(forecastURL)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
        }
        return url
    }
}

//MARK: - Weather Data Decodable
extension WeatherDataAPI {

    enum LocationInformation {
        case coordinates(CLLocation)
        case id(Int)
    }

    enum ForecastType {
        case current
        case fiveDays
    }

    // Forecast Weather
    struct ForecastData: Decodable {
        let list: [ForecastWeatherData]
        let city: CityListRepository.City
    }

    struct ForecastWeatherData: Decodable {
        let dt: Double
        let main: Main
        let weather: [Weather]
        let wind: Wind
    }

    //Current Weather
    struct CurrentWeatherData: Decodable {
        let coord: Coord
        let dt: Double
        let name: String
        let id: Int
        let main: Main
        let weather: [Weather]
        let wind: Wind
    }

    struct Main: Decodable {
        let temp: Double
    }

    struct Weather: Decodable {
        let id: Int
        let main: String
        let description: String
    }

    struct Wind: Decodable {
        let speed: Double
        let deg: Int?
    }

    struct Coord: Decodable {
        let lon: Double
        let lat: Double
    }
}

//        func fetchWeatherInfoByCityName(_ cityName: String) {
//            let url = "\(weatherURL)\(cityName)"
//            performRequest(with: url, for: .weatherData)
//        }
//
//        func fetchWeatherInfoByLocation(_ location: CLLocation) {
//            let url = "\(weatherURL)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
//            performRequest(with: url, for: .weatherData)
//        }
//
//        func fetchForeastInfoByCityName(_ cityName: String) {
//            let url = "\(forecastURL)\(cityName)"
//            performRequest(with: url, for: .forecastData)
//        }
//
//        func fetchForecastInfoByLocation(_ location: CLLocation) {
//            let url = "\(forecastURL)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
//            performRequest(with: url, for: .forecastData)
//        }
