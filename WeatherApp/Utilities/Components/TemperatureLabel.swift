//
//  TemperatureLabel.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 13.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

public class TemperatureLabel: UILabel {

    @IBInspectable var temperature: Double

    init(frame: CGRect, temp: Double) {
        self.temperature = temp
        super.init(frame: frame)
        self.text = String(temperature)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
