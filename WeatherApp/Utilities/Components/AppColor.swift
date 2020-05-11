//
//  AppColor.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 6.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

struct AppColor {
    static let primary = UIColor(named: "primary")
    static let secondary = UIColor(named: "secondary")
}

private extension UIColor {
    convenience init(_ named: String) {
        // Crash if doesn't exist
        self.init(named: named)!
    }
}
