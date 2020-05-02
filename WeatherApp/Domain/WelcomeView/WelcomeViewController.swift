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
            updateLabels(info: info)
        }
    }

    private func updateLabels(info: WelcomeViewModel.WeatherModel) {
        cityNameLabel.text = info.cityName
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM dd HH:mm"
        forecastTimeLabel.text = dateFormatter.string(from: info.date)
        temperatureLabel.text = info.temperatureString
        weatherImage.image = UIImage(systemName: info.conditionNameForSFIcons)
        weatherDescriptionLabel.text = info.conditionDescription
    }

    @IBAction func locationBarButtonItemPressed(_ sender: UIBarButtonItem) {

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


