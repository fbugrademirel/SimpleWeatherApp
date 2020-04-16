//
//  ViewController.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 15.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    var viewModel: WelcomeViewModel!
    let weatherRepo = WeatherRepository()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)


        weatherRepo.getWeatherInfo { [weak self] (data) in
            guard let self = self else { return }
            self.view.backgroundColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
            if let data = data {
                print(data.dt)
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

