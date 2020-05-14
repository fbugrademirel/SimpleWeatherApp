//
//  SettingsManager.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 13.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

final class SettingsManager {

    enum TempUnit {
        case fahrenheit
        case celcius
    }

    private var labels:[UILabel] = []
    private var currentSetting: TempUnit = .celcius {
        didSet {
            convertTemperature()
        }
    }
    static let shared = SettingsManager()


    func addToLabels(label: UILabel) {
        labels.append(label)
    }

    func addToLabels(label: [UILabel]) {
        labels.append(contentsOf: label)
    }

    func setCurrentSetting(to: TempUnit) {
        currentSetting = to
    }

    private func convertTemperature() {
        switch currentSetting {
             case .celcius:
                setLabels(to: .celcius)
             case .fahrenheit:
                setLabels(to: .fahrenheit)
        }
    }
    private func setLabels(to: TempUnit) {
        labels.forEach { label in
            if let textInLabel = label.text {
                if let current = Int(textInLabel) {
                    switch to {
                    case .celcius:
                        let converted = (current * 9/5) + 32
                        label.text = String(converted)
                    case .fahrenheit:
                        let converted = (current - 32) * 5/9
                        label.text = String(converted)
                    }
                }
            }
        }
    }
}
