//
//  WeatherModelAPI.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 15.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation

struct WeatherDataAPI {

    private let networkingService = NetworkingService()
    private let weatherURL = "https://samples.openweathermap.org/data/2.5/weather?id=2172797&appid=439d4b804bc8187953eb36d2a8c26a02"

    func getWeatherInfo(completion: @escaping (Result<WeatherData, Error>) -> Void) {
        networkingService.dispatchRequest(urlString: weatherURL, method: .get) { result in
            switch result {
            case .success(let data):
                do {
                    let weather = try JSONDecoder().decode(WeatherData.self, from: data)
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
}

//MARK: - Weather Data Decodable
extension WeatherDataAPI {

    struct WeatherData: Decodable {
        let coord: Coord
        let dt: Double
        let name: String
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
        let deg: Int
    }

    struct Coord: Decodable {
        let lon: Double
        let lat: Double
    }

}
