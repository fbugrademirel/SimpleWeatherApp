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

    var viewModel: ForecastCollectionViewCellViewModel! {
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

    func handle(action: ForecastCollectionViewCellViewModel.ActionToView) {
        switch action {
        case .setTemp(let unit):
            setTempLabel(with: unit)
        }
    }

    func setTempLabel(with: TemperatureSettingsManager.TempUnit) {
        if let text = temperatureLabel.text {
            DispatchQueue.main.async {
                self.temperatureLabel.text = self.viewModel.temperatureSettingsManager.convertTemp(temp: text ,to: with)
            }
        }
    }

    func configure() {
        forecastImage.image = UIImage(systemName: viewModel.imageString)
        let temp = viewModel.temperature
        switch viewModel.tempUnit {
              case .celcius:
                  self.temperatureLabel.text = temp
              case .fahrenheit:
                  self.temperatureLabel.text = viewModel.temperatureSettingsManager.convertTemp(temp: temp, to: .fahrenheit)
              }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm"
        timeLabel.text = dateFormatter.string(from: viewModel.date)
        windDirection.image = UIImage(systemName: viewModel.windDirectionStringForSGIcon)
        windDirection.transform = CGAffineTransform(rotationAngle: CGFloat(viewModel.windAngle))
        windSpeed.text = viewModel.windSpeed
        viewModel.didReceiveActionForView = { [weak self] action in
            self?.handle(action: action)
        }
    }
}
