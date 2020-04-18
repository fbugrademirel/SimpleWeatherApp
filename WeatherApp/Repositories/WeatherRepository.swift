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

    private(set) var currentWeathers = [WeatherDataAPI.WeatherData]()
    //private(set) var weatherForecast = [WeatherDataAPI.WeatherData]()
    /// Singleton
    static let shared = WeatherRepository()

    func getCurrentWeatherInfo(by locationInformation: LocationInformation, completion: @escaping (WeatherDataAPI.WeatherData?) -> Void) {

        var isOutOfDate: Bool = false

        switch locationInformation {
        case .cityName(let cityName):
            for (index, each) in currentWeathers.enumerated() {
                if each.name == cityName && (Date().timeIntervalSince1970 - each.dt) > 10 {
                    currentWeathers.remove(at: index)
                    isOutOfDate = true
                } else if each.name == cityName {
                    completion(each)
                }
            }
        case .coordinates(let coordinates):
            for (index, each) in currentWeathers.enumerated() {
                if (each.coord.lat.rounded(.down) == coordinates.coordinate.latitude.rounded(.down))
                && (each.coord.lon.rounded(.down) == coordinates.coordinate.longitude.rounded(.down))
                && (Date().timeIntervalSince1970 - each.dt) > 10 {
                    currentWeathers.remove(at: index)
                    isOutOfDate = true
                } else if (each.coord.lat.rounded(.down) == coordinates.coordinate.latitude.rounded(.down))
                        && (each.coord.lon.rounded(.down) == coordinates.coordinate.longitude.rounded(.down)) {
                    completion(each)
                }
            }
        }
        if currentWeathers.isEmpty || isOutOfDate {
            switch locationInformation {
            case .cityName(let cityName):
                WeatherDataAPI().getCurrentWeatherInfo(by: .cityName(cityName)) { (result) in
                               switch result {
                               case .success(let weatherInfo):
                                   self.currentWeathers.append(weatherInfo)
                                   DispatchQueue.main.async {
                                       completion(weatherInfo)
                                   }
                               case .failure(let error):
                                   print(error.localizedDescription)
                                   completion(nil)
                               }
                           }
            case .coordinates(let coordinates):
                WeatherDataAPI().getCurrentWeatherInfo(by: .coordinates(coordinates)) { (result) in
                    switch result {
                    case .success(let weatherInfo):
                        self.currentWeathers.append(weatherInfo)
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
    }
}
//    private func parseToNSManagedObject(_ weatherDataFromAPI: WeatherDataAPI.WeatherData) -> WeatherData {
//        let toBeSaved = WeatherData(context: context)
//        toBeSaved.dt = weatherDataFromAPI.dt
//        toBeSaved.name = weatherDataFromAPI.name
//
//        toBeSaved.coord = Coord(context: context)
//        toBeSaved.coord?.lat = weatherDataFromAPI.coord.lat
//        toBeSaved.coord?.lon = weatherDataFromAPI.coord.lon
//
//        toBeSaved.main = Main(context: context)
//        toBeSaved.main?.temp = weatherDataFromAPI.main.temp
//
//        toBeSaved.weather = Weather(context: context)
//        toBeSaved.weather?.id = Int64(weatherDataFromAPI.weather[0].id)
//        toBeSaved.weather?.desc = weatherDataFromAPI.weather[0].description
//        toBeSaved.weather?.main = weatherDataFromAPI.weather[0].main
//
//        toBeSaved.wind = Wind(context: context)
//        toBeSaved.wind?.deg = Int64(weatherDataFromAPI.wind.deg)
//        toBeSaved.wind?.speed = weatherDataFromAPI.wind.speed
//
//        return toBeSaved
//    }


       /// parseToNSManagedObject returns an NSManagedObject WeatherData initiated with contex of persistent container viewContext
//                let _ = self.parseToNSManagedObject(weatherInfo)
//
//                do {
//                    try context.save()
//                    print("saved with success")
//                } catch {
//                    print("Error writing core data: \(error)")
//                }

extension WeatherRepository {
    enum LocationInformation {
        case coordinates(CLLocation)
        case cityName(String)
    }
}
