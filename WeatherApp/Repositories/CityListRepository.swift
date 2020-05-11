//
//  CityListRepository.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 18.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit
import CoreData

private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

final class CityListRepository {

    static let shared = CityListRepository()

    /// Initializer reads and saves the json file to coredata if the core data is empty.
    init() {
        var isEmpty: Bool {
            do {
                let request = NSFetchRequest<CityListItem>(entityName: "CityListItem")
                let count = try context.count(for: request)
                return count == 0
            } catch {
                return true
            }
        }
        if isEmpty {
            print("initializing city repo")
            if let path = Bundle.main.path(forResource: "citylist", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    print("Starting to read json")
                    let decodedData = try JSONDecoder().decode([City].self, from: data)
                    print("finished reading json")
                    for each in decodedData {
                        let coord = Coord(lon: each.coord.lon, lat: each.coord.lat)
                        //parse to core data classes
                        let city = CityListItem(context: context)
                        city.name = each.name
                        city.id = Int64(each.id)
                        city.country = each.country

                        city.coord = CityCoord(context: context)
                        city.coord?.lat = coord.lat
                        city.coord?.lon = coord.lon
                    }
                    print("starting to save to core data")
                      try context.save()
                    print("finished saving to core data")
                } catch {
                    print("Json file could not be read: \(error.localizedDescription)")
                }
            }
        }
        print("ending init of city repo")
    }

    func getCityInfo(by string: String, completion: @escaping ([CityListRepository.City]) -> Void ) {

        let request: NSFetchRequest<CityListItem> = CityListItem.fetchRequest()
        let predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", string)
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 10
        do {
            let cities = try context.fetch(request)
            var cityData = [CityListRepository.City]()
            for city in cities {
                guard let name = city.name, let country = city.country, let lon = city.coord?.lon, let lat = city.coord?.lat else {
                    completion(cityData)
                    return
                }
                cityData.append(CityListRepository.City(id: Int(city.id), name: name, country: country, coord: Coord(lon: lon, lat: lat)))
            }
            completion(cityData)
        } catch {
            print("Error getting city info from core data \(error.localizedDescription)")
            completion([])
        }
    }

    func fetchFavoriteCities() {
        do {
            let request: NSFetchRequest<CityListItem> = CityListItem.fetchRequest()
            let predicate = NSPredicate(format: "isFavorite == YES")
            request.predicate = predicate
            let favorites = try context.fetch(request)
            favorites.forEach { (favoriteCity) in
                print(favoriteCity)
            }
        } catch {
            print(error)
        }
    }

    func saveAsFavoriteCity(with id: Int) {
        do {
            let request: NSFetchRequest<CityListItem> = CityListItem.fetchRequest()
            let predicate = NSPredicate(format: "id == %i", id)
            request.predicate = predicate
            let city = try context.fetch(request)
            city[0].setValue(true, forKey: "isFavorite")
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

}

extension CityListRepository {

    struct City: Decodable {
        let id: Int
        let name: String
        let country: String
        let coord: Coord
    }

    struct Coord: Decodable {
        let lon: Double
        let lat: Double
    }
}

