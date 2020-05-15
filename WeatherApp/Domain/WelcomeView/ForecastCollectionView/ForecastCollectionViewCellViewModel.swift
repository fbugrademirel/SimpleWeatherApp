//
//  ForecastCollectionViewModel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 6.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import Foundation

final class ForecastCollectionViewCellViewModel {

    ///Not in use for now
    enum ActionToParent {
        case toMain
    }

    enum ActionToView {
        case setTemp(TemperatureSettingsManager.TempUnit)
    }

    var tempUnit: TemperatureSettingsManager.TempUnit {
        didSet {
            didReceiveActionForView?(.setTemp(tempUnit))
        }
    }
    let imageString: String
    let temperature: String
    let date: Date
    let windSpeed: String
    let windAngle: Int
    let windDirectionStringForSGIcon: String
    let temperatureSettingsManager = TemperatureSettingsManager()

    var didReceiveActionForParent: ((ActionToParent) -> Void)?
    var didReceiveActionForView: ((ActionToView) -> Void)?

    init(imageString: String, temperature: String, date: Date, windSpeed: String, windDirectionStringForSFIcon: String, windAngle: Int, tempUnit: TemperatureSettingsManager.TempUnit) {
        self.imageString = imageString
        self.temperature = temperature
        self.date = date
        self.windSpeed = windSpeed
        self.windDirectionStringForSGIcon = windDirectionStringForSFIcon
        self.windAngle = windAngle
        self.tempUnit = tempUnit
    }
}

