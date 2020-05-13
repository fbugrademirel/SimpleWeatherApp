//
//  FavoriteCityCellTableViewCell.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 11.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit
import SwipeCellKit

final class FavoriteCityTableViewCell: SwipeTableViewCell {

    static let nibName = "FavoriteCityCellTableViewCell"

    @IBOutlet private var cityName: UILabel!
    @IBOutlet private var temperature: UILabel!
    @IBOutlet private var conditionView: UIImageView!

    var viewModel: FavoriteCityTableViewCellViewModel! {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        cityName.text = nil
        temperature.text = nil
        imageView?.image = nil
    }

    private func configure() {
        cityName.text = viewModel.cityName
        temperature.text = viewModel.temperatureString
        conditionView.image = UIImage(systemName: viewModel.conditionNameForSFIcons)
    }
}
