//
//  CityListRepository.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 18.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation
import UIKit

private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

final class CityListRepository {

    var cityList = [ListItem]()

    init() {
        if let path = Bundle.main.path(forResource: "city.list", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decodedData = try JSONDecoder().decode(CityList.self, from: data)
                for each in decodedData.list {
                    let coord = Coord(lon: each.coord.lon, lat: each.coord.lat)
                    cityList.append(ListItem(id: each.id, name: each.name, country: each.country, coord: coord))
                }
            } catch {
                print("Json file could not be read: \(error.localizedDescription)")
            }
        }
    }
}

extension CityListRepository {

    struct CityList: Decodable {
        let list: [ListItem]
    }

    struct ListItem: Decodable {
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

//"id": 5174,
//"name": "‘Arīqah",
//"state": "",
//"country": "SY",
//"coord": {
//  "lon": 36.48336,
//  "lat": 32.889809
//}
