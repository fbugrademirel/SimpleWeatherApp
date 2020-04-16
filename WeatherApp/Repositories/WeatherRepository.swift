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

    private(set) var currentWeather: WeatherDataAPI.WeatherData? = nil
    private(set) var weatherForecast = [WeatherDataAPI.WeatherData]()

    func getWeatherInfo(completion: @escaping (WeatherDataAPI.WeatherData?) -> Void) {

        WeatherDataAPI().getWeatherInfo { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let weatherInfo):
                self.currentWeather = weatherInfo
                let weatherTobeSaved = WeatherData(context: context)
                weatherTobeSaved.dt = weatherInfo.dt
                weatherTobeSaved.name = weatherInfo.name
                
                weatherTobeSaved.coord?.lat = weatherInfo.coord.lat
                weatherTobeSaved.coord?.lon = weatherInfo.coord.lon

                weatherTobeSaved.main?.temp = weatherInfo.main.temp

                weatherTobeSaved.weather?.desc = weatherInfo.weather[0].description
                weatherTobeSaved.weather?.id = Int64(weatherInfo.weather[0].id)
                weatherTobeSaved.weather?.main = weatherInfo.weather[0].main

                weatherTobeSaved.wind?.deg = Int64(weatherInfo.wind.deg)
                weatherTobeSaved.wind?.speed = weatherInfo.wind.speed

                do {
                    try context.save()
                    print("saved with success")
                } catch {
                    print("Error writing core data: \(error)")
                }

                DispatchQueue.main.async {
                    completion(weatherInfo)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
}


