//
//  ForecastCollectionViewCell.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 6.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

final class ForecastCollectionViewCell: UICollectionViewCell {

    static let nibName = "ForecastCollectionViewCell"

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var forecastImage: UIImageView!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var windDirection: UIImageView!
    @IBOutlet private var windSpeed: UILabel!

    var viewModel: ForecastCollectionViewCellModel! {
        didSet {
            configure()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = AppColor.primary
    }

    override func prepareForReuse() {
        temperatureLabel.text = nil
        forecastImage.image = nil
        timeLabel.text = nil
    }

    func configure() {
        forecastImage.image = UIImage(systemName: viewModel.imageString)
        temperatureLabel.text = viewModel.temperature
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm"
        timeLabel.text = dateFormatter.string(from: viewModel.date)
        windDirection.image = UIImage(systemName: viewModel.windDirection)
        windSpeed.text = viewModel.windSpeed
    }
}
