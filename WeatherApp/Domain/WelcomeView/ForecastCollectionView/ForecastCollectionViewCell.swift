//
//  ForecastCollectionViewCell.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 6.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit



class ForecastCollectionViewCell: UICollectionViewCell {

    static let nibName = "ForecastCollectionViewCell"

    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.backgroundColor = AppColor.primary
    }
}
