//
//  ViewController.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 15.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit
import CoreLocation

class WelcomeViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: - Properties
    @IBOutlet private var cityNameLabel: UILabel!
    @IBOutlet private var forecastTimeLabel: UILabel!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var weatherImage: UIImageView!
    @IBOutlet private var weatherDescriptionLabel: UILabel!
    @IBOutlet private var windSpeed: UILabel!
    @IBOutlet private var windDirection: UIImageView!
    @IBOutlet weak var stackView: UIStackView!

    var viewModel: WelcomeViewModel!

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didReceiveAction = { [weak self] action in
            self?.handle(action: action)
        }
        viewModel.viewDidLoad()
    }

    private func handle(action: WelcomeViewModel.Action) {
        switch action {
        case .updateLabels(weatherInfo: let info):
            updateLabels(with: info)
        }
    }

    private func updateLabels(with info: WelcomeViewModel.WeatherModel) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.stackView.alpha = 0
            }) { _ in
                self.updateUI(info: info)
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                    self.stackView.alpha = 1
                }, completion: nil)
            }
        }
    }

    private func updateUI(info: WelcomeViewModel.WeatherModel) {

        self.cityNameLabel.text = info.cityName
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd-MMM HH:mm"
        self.forecastTimeLabel.text = dateFormatter.string(from: info.date)
        self.temperatureLabel.text = info.temperatureString
        self.weatherImage.image = UIImage(systemName: info.conditionNameForSFIcons)
        self.weatherDescriptionLabel.text = info.conditionDescription
        self.windSpeed.text = info.windSpeedString
        self.windDirection.image = UIImage(systemName: info.windDirectionString)
    }

    @IBAction func locationBarButtonItemPressed(_ sender: UIBarButtonItem) {
        viewModel.weatherInfoRequired()
    }

}

// MARK: - Storyboard Instantiable

extension WelcomeViewController: StoryboardInstantiable {
    static var storyboardName: String {
        return "WelcomeView"
    }

    public static func instantiate(with viewModel: WelcomeViewModel) -> WelcomeViewController {
        let viewController = instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}


//UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
//    self.cityNameLabel.alpha = 0
//    self.forecastTimeLabel.alpha = 0
//    self.temperatureLabel.alpha = 0
//    self.weatherImage.alpha = 0
//    self.weatherDescriptionLabel.alpha = 0
//    self.windSpeed.alpha = 0
//    self.windDirection.alpha = 0
//}) { (bool) in
//    self.cityNameLabel.text = info.cityName
//    let dateFormatter = DateFormatter()
//    dateFormatter.locale = NSLocale.current
//    dateFormatter.dateFormat = "dd-MMM HH:mm"
//    self.forecastTimeLabel.text = dateFormatter.string(from: info.date)
//    self.temperatureLabel.text = info.temperatureString
//    self.weatherImage.image = UIImage(systemName: info.conditionNameForSFIcons)
//    self.weatherDescriptionLabel.text = info.conditionDescription
//    self.windSpeed.text = info.windSpeedString
//    self.windDirection.image = UIImage(systemName: info.windDirectionString)
//
//    UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
//        self.cityNameLabel.alpha = 1
//        self.forecastTimeLabel.alpha = 1
//        self.temperatureLabel.alpha = 1
//        self.weatherImage.alpha = 1
//        self.weatherDescriptionLabel.alpha = 1
//        self.windSpeed.alpha = 1
//        self.windDirection.alpha = 1
//    }, completion: nil)
