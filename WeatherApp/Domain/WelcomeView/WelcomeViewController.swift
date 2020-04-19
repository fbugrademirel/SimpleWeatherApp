//
//  ViewController.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 15.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit
import CoreLocation

class WelcomeViewController: UIViewController {

    @IBOutlet private var textField: UITextField!
    var viewModel: WelcomeViewModel!
    let weatherRepo = WeatherRepository.shared
    let cityRepo = CityListRepository.shared


    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cityName: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        //refreshWeather()
    }

    @IBAction func searchPressed(_ sender: UIButton) {
        if let text = textField.text {
            cityRepo.getCityInfo(by: text) { [weak self] (data) in
                guard let _ = self else {return}
                DispatchQueue.main.async {
                    print(data)
                }
            }
        }
    }
    
    @IBAction func refreshPressed(_ sender: UIButton) {
        refreshWeather()
    }

    func refreshWeather() {
        weatherRepo.getCurrentWeatherInfo(by:.cityName("Trabzon")) { [weak self] (data) in
            guard let self = self else { return }
            self.view.backgroundColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
            if let data = data {
                DispatchQueue.main.async {
                    let formatter = DateFormatter()
                    formatter.locale = NSLocale.current
                    formatter.dateFormat = "MMM dd HH:mm"
                    if let timeInterval = TimeInterval(exactly: Double(data.dt)) {
                        let date = Date(timeIntervalSince1970: timeInterval)
                        self.label.text = formatter.string(from: date)
                        self.cityName.text = data.name
                    }
                }
            }
        }
    }
}

// MARK: - StoryboardInstantiable
extension WelcomeViewController: StoryboardInstantiable {
    static var storyboardName: String {
        return "Main"
    }

    public static func instantiate(with viewModel: WelcomeViewModel) -> WelcomeViewController {
        let viewController = instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}


