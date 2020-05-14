//
//  SettingsManager.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 13.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

protocol TemperatureSettingsManagerDelegate: class {
    func tempUnitDidSet(_ temperatureSettingsManager: TemperatureSettingsManager, unit: TemperatureSettingsManager.TempUnit)
}

final class TemperatureSettingsManager {

    enum TempUnit {
        case fahrenheit
        case celcius
    }

    weak var delegate: TemperatureSettingsManagerDelegate?

    private var currentSetting: TempUnit = .celcius {
        didSet {
            delegate?.tempUnitDidSet(self, unit: currentSetting)
        }
    }

    func convertTemp(temp: String, to: TempUnit) -> String {
        guard let current = Double(temp) else { return "-" }
        switch to {
        case .celcius:
            let converted = Int(((current - 32) * 5/9).rounded(.toNearestOrAwayFromZero))
            return String(converted)
        case .fahrenheit:
            let converted = Int(((current * 9/5) + 32).rounded(.toNearestOrAwayFromZero))
            return String(converted)
        }
    }

    func setUnit(to: TempUnit) {
        currentSetting = to
    }
}

class WeakRef<T> where T: AnyObject {

    private(set) weak var value: T?

    init(value: T?) {
        self.value = value
    }
}
